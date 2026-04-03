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

    // Tenter un refresh proactif du token avant de naviguer
    final refreshToken = UserSession.instance.refreshToken;
    if (refreshToken.isNotEmpty) {
      try {
        final freshToken = await AuthenticatedHttpClient.instance.ensureFreshToken();
        if (freshToken.isEmpty) {
          // Refresh token expiré → forcer reconnexion
          await SessionStorage.instance.clear();
          if (mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          return;
        }
      } catch (_) {
        // En cas d'erreur réseau, on tente quand même avec le token existant
      }
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