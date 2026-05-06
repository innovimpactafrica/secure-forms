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
import 'package:quick_forms/features/client/data/services/subscription_service.dart';
import 'package:quick_forms/features/kyc/domain/bloc/kyc_bloc.dart';
import 'package:quick_forms/features/kyc/presentation/pages/kyc_intro_page.dart';
import 'package:quick_forms/core/utils/kyc_checker.dart';

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
    // â† CHANGÃ‰ : -90 â†’ -55 pour que le logo ne parte pas trop loin
    _logoSlide = Tween<double>(begin: 0.0, end: -55.0).animate(
      CurvedAnimation(
          parent: _slideController,
          curve: Curves.easeInOut), // â† easeInOut comme demandÃ©
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
        print('[Splash] Token expirÃ© ou bientÃ´t â†’ refresh proactif...');
        final freshToken =
            await AuthenticatedHttpClient.instance.ensureFreshToken();
        if (freshToken.isEmpty) {
          print('[Splash] Refresh Ã©chouÃ© â†’ reconnexion requise');
          await SessionStorage.instance.clear();
          if (mounted)
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          return;
        }
        print('[Splash] Token rafraÃ®chi avec succÃ¨s');
      } catch (_) {
        print(
            '[Splash] Erreur rÃ©seau lors du refresh â†’ on continue avec le token existant');
      }
    } else {
      print('[Splash] Token encore valide â†’ pas de refresh nÃ©cessaire');
    }

    if (!mounted) return;

    final token = UserSession.instance.accessToken;
    final userBloc = context.read<UserBloc>();
    final notifBloc = context.read<NotificationsBloc>();
    final navigator = Navigator.of(context);

    // VÃ©rifier l'abonnement avant de naviguer
    try {
      final sub = await SubscriptionService()
          .getEffectiveSubscription(accessToken: token);
      if (!mounted) return;
      if (sub == null || !sub.isActive) {
        navigator.pushReplacementNamed(AppRoutes.activationRequise);
        return;
      }

      // Abonnement actif â†’ vÃ©rifier KYC via API backend
      final kycDone = await KycChecker.isKycCompleted();
      if (!mounted) return;

      if (!kycDone) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => KycBloc(userId: UserSession.instance.userId),
              child: const KycIntroPage(),
            ),
          ),
          (route) => false,
        );
      } else {
        navigator.pushReplacementNamed(AppRoutes.clientHome);
      }
    } catch (_) {
      if (!mounted) return;
      navigator.pushReplacementNamed(AppRoutes.clientHome);
    }

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
  @override
@override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  // Position finale du logo après glissement
  // Logo commence au centre : screenWidth/2 - 75 (moitié de 150)
  // Logo glisse de -55px vers la gauche
  final double logoFinalLeft = screenWidth / 2 - 75 + (-55); // = screenWidth/2 - 130
  final double logoWidth = 150.0;
  final double logoHeight = 150.0;
  final double textWidth = 170.0;
  final double textHeight = 150.0;
  final double topPosition = screenHeight / 2 - 75;

  return Scaffold(
    backgroundColor: AppColors.white,
    body: AnimatedBuilder(
      animation: Listenable.merge([_logoSlide, _textOpacity, _fadeAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Stack(
            children: [
              // Logo qui glisse vers la gauche
              Positioned(
                top: topPosition,
                left: screenWidth / 2 - 75 + _logoSlide.value,
                child: SizedBox(
                  width: logoWidth,
                  height: logoHeight,
                  child: Image.asset(
                    'assets/images/qf.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Texte fixe juste à droite de la position finale du logo
              Positioned(
                top: topPosition,
                left: logoFinalLeft + logoWidth + 0, // ✅ collé au logo arrêté
                child: Opacity(
                  opacity: _textOpacity.value,
                  child: SizedBox(
                    width: textWidth,
                    height: textHeight,
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


