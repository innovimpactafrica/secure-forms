import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/core/utils/base_url.dart';
import 'package:secure_link/core/utils/navigator_key.dart';
import 'package:secure_link/core/utils/user_session.dart';

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
        _handleNavigationFromPayload(response.payload);
      },
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

  // ✅ Envoi du token FCM au backend
  static Future<void> sendTokenToBackend(String token) async {
    try {
      final accessToken = UserSession.instance.accessToken;

      // Si l'utilisateur n'est pas encore connecté, on ne fait rien
      // Le token sera renvoyé après login
      if (accessToken.isEmpty) {
        print('[FCM] Pas de session active — token mis en attente');
        return;
      }

      final response = await http.post(
        Uri.parse(BaseUrl.registerFcmToken),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'fcmToken': token}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[FCM] ✅ Token envoyé au backend avec succès');
      } else {
        print('[FCM] ⚠️ Erreur envoi token: ${response.statusCode} — ${response.body}');
      }
    } catch (e) {
      print('[FCM] ❌ Exception envoi token: $e');
    }
  }

  static void _listenToMessages() {
    // App OUVERTE → afficher manuellement
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            importance: Importance.high,
            priority: Priority.high,
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
      _handleNavigation(message.data);
    });
  }

  // App FERMÉE → vérifier au démarrage
  static Future<void> checkInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      _handleNavigation(message.data);
    }
  }

  // Navigation selon les données envoyées par le backend
  static void _handleNavigation(Map<String, dynamic> data) {
    final screen = data['screen'];
    print('[FCM] Navigation vers: $screen');

    switch (screen) {
      case 'demandes':
        navigatorKey.currentState?.pushNamed(AppRoutes.clientDemandes);
        break;
      case 'detail_demande':
        navigatorKey.currentState?.pushNamed(
          AppRoutes.detailDemande,
          arguments: data,
        );
        break;
      case 'detail_virement':
        navigatorKey.currentState?.pushNamed(
          AppRoutes.detailVirement,
          arguments: data,
        );
        break;
      case 'detail_acte_vente':
        navigatorKey.currentState?.pushNamed(
          AppRoutes.detailActeVente,
          arguments: data,
        );
        break;
      case 'detail_pret':
        navigatorKey.currentState?.pushNamed(
          AppRoutes.detailPret,
          arguments: data,
        );
        break;
      case 'detail_ouverture_compte':
        navigatorKey.currentState?.pushNamed(
          AppRoutes.detailOuvertureCompte,
          arguments: data,
        );
        break;
      case 'detail_ouverture_compte_brouillon':
        navigatorKey.currentState?.pushNamed(
          AppRoutes.detailOuvertureCompteBrouillon,
          arguments: data,
        );
        break;
      case 'profil':
        navigatorKey.currentState?.pushNamed(AppRoutes.clientProfil);
        break;
      case 'notifications':
      default:
        navigatorKey.currentState?.pushNamed(AppRoutes.clientHome);
        break;
    }
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