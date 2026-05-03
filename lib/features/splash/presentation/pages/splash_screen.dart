import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:quick_forms/core/utils/app_routes.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/session_storage.dart';
import 'package:quick_forms/core/utils/authenticated_http_client.dart';
import 'package:quick_forms/features/auth/domain/bloc/user_bloc.dart';
import 'package:quick_forms/features/auth/domain/bloc/user_event.dart';
import 'package:quick_forms/features/client/domain/bloc/notifications_bloc.dart';
import 'package:quick_forms/features/client/domain/bloc/notifications_event.dart';
import 'package:quick_forms/core/utils/user_session.dart';
import 'package:quick_forms/core/services/fcm_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _logoSlide;

  late AnimationController _textController;
  late Animation<double> _textOpacity;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    // ← CHANGÉ : -90 → -55 pour que le logo ne parte pas trop loin
    _logoSlide = Tween<double>(begin: 0.0, end: -55.0).animate(
      CurvedAnimation(
          parent: _slideController,
          curve: Curves.easeInOut), // ← easeInOut comme demandé
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _fadeController.forward();
    _fadeController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await _checkSession();
      }
    });
  }

  Future<void> _checkSession() async {
    final hasSession = await SessionStorage.instance.restore();
    if (!mounted) return;

    if (!hasSession) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
      return;
    }

    final refreshToken = UserSession.instance.refreshToken;
    if (refreshToken.isNotEmpty &&
        _isTokenExpiredOrSoon(UserSession.instance.accessToken)) {
      try {
        print('[Splash] Token expiré ou bientôt → refresh proactif...');
        final freshToken =
            await AuthenticatedHttpClient.instance.ensureFreshToken();
        if (freshToken.isEmpty) {
          print('[Splash] Refresh échoué → reconnexion requise');
          await SessionStorage.instance.clear();
          if (mounted)
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          return;
        }
        print('[Splash] Token rafraîchi avec succès');
      } catch (_) {
        print(
            '[Splash] Erreur réseau lors du refresh → on continue avec le token existant');
      }
    } else {
      print('[Splash] Token encore valide → pas de refresh nécessaire');
    }

    if (!mounted) return;

    final token = UserSession.instance.accessToken;
    final userBloc = context.read<UserBloc>();
    final notifBloc = context.read<NotificationsBloc>();
    final navigator = Navigator.of(context);

    navigator.pushReplacementNamed(AppRoutes.clientHome);

    Future.microtask(() {
      notifBloc.add(const LoadNotificationsEvent());
      userBloc.add(LoadProfilePictureEvent(token));
      userBloc.add(LoadUserProfile(token));
      _sendFcmTokenOnRestore();
    });
  }

  bool _isTokenExpiredOrSoon(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = map['exp'] as int?;
      if (exp == null) return true;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now()
          .isAfter(expiry.subtract(const Duration(minutes: 5)));
    } catch (_) {
      return true;
    }
  }

  Future<void> _sendFcmTokenOnRestore() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await FcmService.sendTokenToBackend(fcmToken);
      }
    } catch (e) {
      print('[SplashScreen] Erreur envoi token FCM: $e');
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ← AJOUTÉ : on récupère la largeur réelle de l'écran
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([_logoSlide, _textOpacity, _fadeAnimation]),
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Stack(
              children: [
                // ← CHANGÉ : on positionne le logo seul au centre exact de l'écran
                // puis on le déplace avec Transform.translate
                Positioned(
                  // Centre vertical
                  top: MediaQuery.of(context).size.height / 2 - 55,
                  // Centre horizontal = milieu écran - moitié largeur logo
                  // Le logo fait 110px de large, donc left = (screenWidth/2 - 55) + slide
                  left: (screenWidth / 2 - 55) + _logoSlide.value,
                  child: SizedBox(
                    width: 110,
                    height: 110,
                    child: Image.asset(
                      'assets/images/qf.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // ← CHANGÉ : texte positionné juste à droite du logo, sans espace
                Positioned(
                  top: MediaQuery.of(context).size.height / 2 - 55,
                  // left du texte = left du logo + largeur logo (110) + slide
                  left: (screenWidth / 2 - 55) + 110 + _logoSlide.value,
                  child: Opacity(
                    opacity: _textOpacity.value,
                    child: SizedBox(
                      width: 130,
                      height: 110,
                      child: Image.asset(
                        'assets/images/textqf.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
