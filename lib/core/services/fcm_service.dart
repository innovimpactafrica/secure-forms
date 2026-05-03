import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:quick_forms/core/utils/app_routes.dart';
import 'package:quick_forms/core/utils/base_url.dart';
import 'package:quick_forms/core/utils/navigator_key.dart';
import 'package:quick_forms/core/utils/user_session.dart';

// Handler top-level pour les taps sur notifications locales quand app en fond
@pragma('vm:entry-point')
void _backgroundNotificationHandler(NotificationResponse response) {
  // Ne peut pas naviguer ici (pas de context) — géré par onDidReceiveNotificationResponse au réveil
}

class FcmService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  // Canal Android — doit correspondre à AndroidManifest.xml
  static const _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notifications importantes',
    description: 'Notifications principales de Secure Link',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  // Point d'entrée — appelé dans main.dart
  static Future<void> initialize() async {
    await _createAndroidChannel();
    await _initializeLocalNotifications();
    // Forcer l'affichage des notifications FCM quand l'app est au premier plan
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    await _requestPermission();
  }

  static Future<void> _createAndroidChannel() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        // Tap sur notification locale (app ouverte au premier plan)
        _handleNavigationFromPayload(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse:
          _backgroundNotificationHandler,
    );
  }

  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _setupToken();
      _listenToMessages();
    } else {
      print('[FCM] Permission refusée');
    }
  }

  static Future<void> _setupToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      print('[FCM] ===== TON TOKEN FCM =====');
      print('[FCM] $token');
      print('[FCM] ===========================');
      await sendTokenToBackend(token);
    }
    _messaging.onTokenRefresh.listen(sendTokenToBackend);
  }

  //  Envoi du token FCM au backend + abonnement au topic utilisateur
  static Future<void> sendTokenToBackend(String fcmToken) async {
    try {
      final accessToken = UserSession.instance.accessToken;
      final userId = UserSession.instance.userId;

      if (accessToken.isEmpty) {
        print('[FCM] Pas de session active — token mis en attente');
        return;
      }

      // 1. Envoyer le token au backend
      final response = await http.post(
        Uri.parse(BaseUrl.registerFcmToken),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'fcmToken': fcmToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[FCM]  Token envoyé au backend avec succès');
      } else {
        print(
            '[FCM]  Erreur envoi token: ${response.statusCode} — ${response.body}');
      }

      // 2. S'abonner au topic utilisateur : secureform_fcm_{userId}
      if (userId.isNotEmpty) {
        final topic = 'secureform_fcm_$userId';
        await _messaging.subscribeToTopic(topic);
        print('[FCM]  Abonné au topic: $topic');
      } else {
        print('[FCM]  userId vide — abonnement topic impossible');
      }
    } catch (e) {
      print('[FCM]  Exception envoi token: $e');
    }
  }

  /// À appeler après login réussi pour s'assurer que le token est envoyé
  /// et que l'abonnement au topic est fait avec le bon userId
  static Future<void> onUserLoggedIn(String userId) async {
    print('[FCM] onUserLoggedIn userId=$userId');
    final fcmToken = await _messaging.getToken();
    if (fcmToken != null) {
      await sendTokenToBackend(fcmToken);
    }
  }

  static void _listenToMessages() {
    // App OUVERTE → afficher manuellement
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('[FCM] onMessage reçu: messageId=${message.messageId}');
      print(
          '[FCM] onMessage notification: title=${message.notification?.title} body=${message.notification?.body}');
      print('[FCM] onMessage data: ${message.data}');

      final notification = message.notification;

      // Si pas de notification block → construire depuis les data
      final title = notification?.title ??
          message.data['title'] ??
          message.data['subject'] ??
          'Secure Forms';
      final body = notification?.body ??
          message.data['body'] ??
          message.data['message'] ??
          '';

      if (title.isEmpty && body.isEmpty) {
        print('[FCM] Message sans contenu affichable — ignoré');
        return;
      }

      _localNotifications.show(
        message.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            fullScreenIntent: true,
            actions: const [],
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    });

    // App EN FOND → tap sur la notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('[FCM] onMessageOpenedApp: ${message.data}');
      _handleNavigation(message.data);
    });
  }

  // App FERMÉE → vérifier au démarrage
  static Future<void> checkInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      print('[FCM] Message initial (app fermée): ${message.data}');
      _handleNavigation(message.data);
    }
  }

  // Navigation selon les données envoyées par le backend
  static void _handleNavigation(Map<String, dynamic> data) {
    print('[FCM] data reçu pour navigation: $data');

    final relatedType = data['relatedType']?.toString() ?? '';
    final relatedId = data['relatedId']?.toString() ?? '';
    final type = data['type']?.toString() ?? '';
    final screen = data['screen']?.toString() ?? '';

    void navigate() {
      final nav = navigatorKey.currentState;
      if (nav == null) {
        // Retry si navigator pas encore prêt
        Future.delayed(const Duration(milliseconds: 300), navigate);
        return;
      }

      // Cas 1 : notification liée à une demande
      if (relatedType == 'request' && relatedId.isNotEmpty) {
        print('[FCM] → détail demande id=$relatedId');
        nav.pushNamed(AppRoutes.clientDemandeDetail,
            arguments: {'id': relatedId});
        return;
      }

      // Cas 2 : type de notification
      switch (type) {
        case 'REQUEST_VALIDATED':
        case 'REQUEST_REJECTED':
        case 'REQUEST_UPDATED':
        case 'REQUEST_PENDING':
        case 'REQUEST_IN_PROGRESS':
          if (relatedId.isNotEmpty) {
            nav.pushNamed(AppRoutes.clientDemandeDetail,
                arguments: {'id': relatedId});
          } else {
            nav.pushNamed(AppRoutes.clientDemandes);
          }
          return;

        case 'DOCUMENT_VALIDATED':
        case 'DOCUMENT_REJECTED':
        case 'DOCUMENT_EXPIRING':
        case 'KYC_VALIDATED':
        case 'KYC_REJECTED':
        case 'PROFILE_UPDATED':
          nav.pushNamed(AppRoutes.clientProfil);
          return;

        case 'NEW_MESSAGE':
        case 'SYSTEM':
          nav.pushNamed(AppRoutes.clientHome);
          return;
      }

      // Cas 3 : champ screen explicite
      switch (screen) {
        case 'demandes':
          nav.pushNamed(AppRoutes.clientDemandes);
          return;
        case 'profil':
          nav.pushNamed(AppRoutes.clientProfil);
          return;
        case 'notifications':
          nav.pushNamed(AppRoutes.clientHome);
          return;
      }

      // Fallback
      print('[FCM] Aucune navigation spécifique → home');
      nav.pushNamed(AppRoutes.clientHome);
    }

    navigate();
  }

  static void _handleNavigationFromPayload(String? payload) {
    if (payload == null) return;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _handleNavigation(data);
    } catch (e) {
      print('[FCM] Erreur parsing payload: $e');
    }
  }
}
