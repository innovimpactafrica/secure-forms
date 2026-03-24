import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/kyc/domain/bloc/kyc_bloc.dart';
import 'package:secure_link/features/kyc/presentation/pages/kyc_intro_page.dart';
import 'package:secure_link/features/auth/presentation/pages/login_screen.dart';

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
        // Comportement existant : 3s puis pop
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });
  }

  void _handleDeepLinkRoute() {
  final isLoggedIn = UserSession.instance.accessToken.isNotEmpty;
  debugPrint('[KycGatePage] fromDeepLink=true isLoggedIn=$isLoggedIn');
  
  if (isLoggedIn) {
    _goToKyc();
  } else {
    _goToLoginThenKyc();
  }
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

 

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
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

/*
class _LoginBridgeScreen extends StatelessWidget {
  final void Function(String userId) onLoginSuccess;

  const _LoginBridgeScreen({required this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    // On écoute le UserSession après login pour récupérer le userId
    return _LoginScreenWrapper(onLoginSuccess: onLoginSuccess);
  }
}

class _LoginScreenWrapper extends StatefulWidget {
  final void Function(String userId) onLoginSuccess;
  const _LoginScreenWrapper({required this.onLoginSuccess});

  @override
  State<_LoginScreenWrapper> createState() => _LoginScreenWrapperState();
}

class _LoginScreenWrapperState extends State<_LoginScreenWrapper> {
  @override
  Widget build(BuildContext context) {
    // On utilise un NotificationListener sur le Navigator pour détecter
    // quand LoginScreen a réussi et stocké le token dans UserSession
    return _PostLoginDetector(
      onLoginSuccess: widget.onLoginSuccess,
    );
  }
}

class _PostLoginDetector extends StatefulWidget {
  final void Function(String userId) onLoginSuccess;
  const _PostLoginDetector({required this.onLoginSuccess});

  @override
  State<_PostLoginDetector> createState() => _PostLoginDetectorState();
}

class _PostLoginDetectorState extends State<_PostLoginDetector>
    with WidgetsBindingObserver {
    @override
     void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    }

    @override
    void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    }

     @override
    void didChangeAppLifecycleState(AppLifecycleState state) {}

     @override
     Widget build(BuildContext context) {
      return LoginScreenDeepLink(
     onLoginSuccess: () => widget.onLoginSuccess(UserSession.instance.userId),
     );
     }
   }
   */
