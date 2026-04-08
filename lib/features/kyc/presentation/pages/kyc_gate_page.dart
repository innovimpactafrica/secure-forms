import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/kyc/domain/bloc/kyc_bloc.dart';
import 'package:secure_link/features/kyc/presentation/pages/kyc_intro_page.dart';
import 'package:secure_link/features/auth/presentation/pages/login_screen.dart';
import 'dart:convert';
import 'package:secure_link/core/utils/session_storage.dart';

class KycGatePage extends StatefulWidget {
  final bool fromDeepLink;
  final String jwt;

  const KycGatePage({
    super.key,
    this.fromDeepLink = false,
    this.jwt = '',
  });

  @override
  State<KycGatePage> createState() => _KycGatePageState();
}

class _KycGatePageState extends State<KycGatePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.fromDeepLink) {
        _handleDeepLinkRoute();
      } else {
        // Fermer automatiquement après 3s
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });
  }

  void _handleDeepLinkRoute() {
  final deepLinkJwt = widget.jwt;
  final mobileUserId = UserSession.instance.userId;
  final deepLinkUserId = deepLinkJwt.isNotEmpty
      ? _extractUserIdFromJwt(deepLinkJwt)
      : '';

  debugPrint('[KycGatePage] mobileUserId=$mobileUserId deepLinkUserId=$deepLinkUserId');

  // Pas de JWT → comportement normal
  if (deepLinkJwt.isEmpty) {
    if (UserSession.instance.accessToken.isNotEmpty) {
      _goToKyc();
    } else {
      _goToLoginThenKyc();
    }
    return;
  }

  // Même utilisateur web et mobile → KYC direct
  if (mobileUserId.isNotEmpty && mobileUserId == deepLinkUserId) {
    debugPrint('[KycGatePage] Même utilisateur → KYC direct');
    _goToKyc();
    return;
  }

  // Utilisateur différent OU non connecté → déconnexion + login
  debugPrint('[KycGatePage] Utilisateur différent → déconnexion + login');
  _logoutAndGoToLogin(deepLinkJwt);
}

void _goToKyc() {
  final userId = UserSession.instance.userId;
  debugPrint('[KycGatePage] _goToKyc userId=$userId');
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => KycBloc(userId: userId),
        child: const KycIntroPage(),
      ),
    ),
    (route) => false, // ← efface toute la stack
  );
}

void _goToLoginThenKyc() {
  debugPrint('[KycGatePage] _goToLoginThenKyc');
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => LoginScreenDeepLink(
        onLoginSuccess: () {
          // Après login → aller au KYC en effaçant la stack
          final userId = UserSession.instance.userId;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => KycBloc(userId: userId),
                child: const KycIntroPage(),
              ),
            ),
            (route) => false,
          );
        },
      ),
    ),
    (route) => false, // ← efface toute la stack
  );
}

void _logoutAndGoToLogin(String deepLinkJwt) {
  UserSession.instance.clear();
  SessionStorage.instance.clear();

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (newContext) => LoginScreenDeepLink(
        onLoginSuccess: () {
          final loggedUserId = UserSession.instance.userId;
          final expectedUserId = _extractUserIdFromJwt(deepLinkJwt);

          debugPrint('[KycGatePage] loggedUserId=$loggedUserId expectedUserId=$expectedUserId');

          if (loggedUserId == expectedUserId) {
            // Bon utilisateur → KYC en utilisant le context du LoginScreen
            final userId = UserSession.instance.userId;
            Navigator.of(newContext).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => KycBloc(userId: userId),
                  child: const KycIntroPage(),
                ),
              ),
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(newContext).showSnackBar(
              const SnackBar(
                content: Text(
                  'Connectez-vous avec le compte utilisé sur le web.',
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
            // Re-login avec le bon context
            Navigator.of(newContext).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => LoginScreenDeepLink(
                  onLoginSuccess: () {
                    final userId = UserSession.instance.userId;
                    Navigator.of(newContext).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => KycBloc(userId: userId),
                          child: const KycIntroPage(),
                        ),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
              (route) => false,
            );
          }
        },
      ),
    ),
    (route) => false,
  );
}
 

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        // Quand l'utilisateur revient sur KycGatePage depuis KycIntroPage,
        // on la ferme immédiatement pour retourner sur home
        if (didPop) return;
        if (mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.verified_user_outlined,
                      size: 44,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Vérification d\'identité requise',
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilySofiaSans,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: AppColors.textBlack87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Text(
                  widget.fromDeepLink &&
                          UserSession.instance.accessToken.isEmpty
                      ? 'Vous devez vous connecter pour accéder à la vérification d\'identité.'
                      : 'Pour accéder à votre espace, vous devez d\'abord vérifier votre identité. Ce processus ne prend que quelques minutes.',
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Redirection en cours...',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontSize: AppConstants.fontSizeRegular,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _extractUserIdFromJwt(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return '';
    final normalized = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final map = jsonDecode(decoded) as Map<String, dynamic>;
    return map['sub']?.toString() ?? '';
  } catch (_) {
    return '';
  }
}

