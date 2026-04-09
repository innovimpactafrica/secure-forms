import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // 👈 NOUVEAU
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/session_storage.dart';
import 'package:secure_link/core/utils/authenticated_http_client.dart';
import 'package:secure_link/features/auth/domain/bloc/user_bloc.dart';
import 'package:secure_link/features/auth/domain/bloc/user_event.dart';
import 'package:secure_link/features/client/domain/bloc/notifications_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/notifications_event.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/core/services/fcm_service.dart'; // 👈 NOUVEAU

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.easeInOut),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _animationController.forward();
    _animationController.addStatusListener((status) async {
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

    // Refresh proactif uniquement si le token access est expiré ou proche de l'expiration
    final refreshToken = UserSession.instance.refreshToken;
    if (refreshToken.isNotEmpty && _isTokenExpiredOrSoon(UserSession.instance.accessToken)) {
      try {
        print('[Splash] Token expiré ou bientôt → refresh proactif...');
        final freshToken = await AuthenticatedHttpClient.instance.ensureFreshToken();
        if (freshToken.isEmpty) {
          print('[Splash] Refresh échoué → reconnexion requise');
          await SessionStorage.instance.clear();
          if (mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          return;
        }
        print('[Splash] Token rafraîché avec succès');
      } catch (_) {
        // Erreur réseau → on tente avec le token existant
        print('[Splash] Erreur réseau lors du refresh → on continue avec le token existant');
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

  // Retourne true si le JWT est expiré ou expire dans moins de 5 minutes
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
      // Refresh si expire dans moins de 5 minutes
      return DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 5)));
    } catch (_) {
      return true; // En cas d'erreur de décodage, on refresh par sécurité
    }
  }

  // 👇 NOUVEAU — Récupère et envoie le token FCM au backend
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Center(
              child: Image.asset(
                'assets/images/secureforms_logo.png',
                width: double.infinity,
                height: 160,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}