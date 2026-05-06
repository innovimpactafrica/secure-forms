import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';
import 'package:quick_forms/core/utils/app_routes.dart';
import 'package:quick_forms/core/utils/user_session.dart';
import 'package:quick_forms/core/utils/session_storage.dart';
import 'package:quick_forms/features/auth/domain/bloc/auth_bloc.dart';
import 'package:quick_forms/features/auth/domain/bloc/auth_event.dart';
import 'package:quick_forms/features/auth/domain/bloc/auth_state.dart';
import 'package:quick_forms/features/auth/domain/bloc/user_bloc.dart';
import 'package:quick_forms/features/auth/domain/bloc/user_event.dart';
import 'package:quick_forms/features/client/domain/bloc/notifications_bloc.dart';
import 'package:quick_forms/features/client/domain/bloc/notifications_event.dart';
import 'package:quick_forms/features/auth/presentation/pages/register_screen.dart';
import 'package:quick_forms/features/client/domain/bloc/demandes_bloc/demandes_bloc.dart';
import 'package:quick_forms/features/client/domain/bloc/demandes_bloc/demandes_event.dart';
import 'package:quick_forms/features/client/domain/bloc/profile_bloc.dart';
import 'package:quick_forms/features/client/domain/bloc/profile_event.dart';
import 'package:quick_forms/features/home/domain/bloc/home_bloc.dart';
import 'package:quick_forms/features/home/domain/bloc/home_event.dart';
import 'package:quick_forms/core/services/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:quick_forms/features/client/data/services/subscription_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  late final AuthBloc _authBloc;
  late final TabController _tabController;
  String _fullPhone = '';

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _tabController.dispose();
    _authBloc.close();
    super.dispose();
  }

  void _onLogin(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final isPhone = _tabController.index == 1;
    _authBloc.add(
      LoginRequested(
        email: isPhone ? null : _emailController.text.trim(),
        phone: isPhone ? _fullPhone : null,
        password: _passwordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            UserSession.instance.accessToken = state.accessToken;
            UserSession.instance.refreshToken = state.refreshToken;
            UserSession.instance.userId =
                _extractUserIdFromJwt(state.accessToken);
            SessionStorage.instance.save(
              token: state.accessToken,
              refreshToken: state.refreshToken,
              name: '${state.firstName} ${state.lastName}'.trim(),
            );
            // Récupérer les références AVANT tout gap async
            final homeBloc = context.read<HomeBloc>();
            final demandesBloc = context.read<DemandesBloc>();
            final userBloc = context.read<UserBloc>();
            final notifBloc = context.read<NotificationsBloc>();
            final profileBloc = context.read<ProfileBloc>();
            // Réinitialiser tous les BLoCs pour effacer les données de l'ancien utilisateur
            homeBloc.add(const ResetHomeEvent());
            demandesBloc.add(const ResetDemandesEvent());
            userBloc.add(ResetUserEvent());
            notifBloc.add(const ResetNotificationsEvent());
            profileBloc.add(const ResetProfileEvent());
            // Vérifier l'abonnement AVANT de naviguer
            _checkSubscriptionAndNavigate(
              context,
              accessToken: state.accessToken,
              userBloc: userBloc,
              notifBloc: notifBloc,
            );
          } else if (state is LoginIncomplete) {
            _showIncompleteDialog(context, state.email);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('login.invalid_credentials'.tr()),
                backgroundColor: AppColors.statusRejected,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(
              child: Column(
                children: [
                  // ── Header ──
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingLarge,
                      vertical: AppConstants.paddingLarge,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: AppConstants.avatarSizeSmall,
                            height: AppConstants.avatarSizeSmall,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.backCircleColor,
                                  width: 1.26),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: AppColors.backArrowColor, size: 20.6),
                          ),
                        ),
                        Image.asset('assets/images/qfwithtext.png',
                            height: 82, fit: BoxFit.contain),
                      ],
                    ),
                  ),

                  // ── Formulaire scrollable ──
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.paddingLarge,
                        AppConstants.paddingLarge,
                        AppConstants.paddingLarge,
                        AppConstants.paddingXLarge,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Titre
                            Text(
                              'login.login_title'.tr(),
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilySofiaSans,
                                fontSize: AppConstants.fontSizeTitle,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'login.login_subtitle_new'.tr(),
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Tabs Email / Téléphone ──
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusRound),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: AnimatedBuilder(
                                animation: _tabController,
                                builder: (_, __) => Row(
                                  children: [
                                    _LoginTabOption(
                                      label: 'login.tab_email'.tr(),
                                      isSelected: _tabController.index == 0,
                                      onTap: () => setState(
                                          () => _tabController.animateTo(0)),
                                    ),
                                    _LoginTabOption(
                                      label: 'login.tab_phone'.tr(),
                                      isSelected: _tabController.index == 1,
                                      onTap: () => setState(
                                          () => _tabController.animateTo(1)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ── Champ Email ou Téléphone selon tab ──
                            AnimatedBuilder(
                              animation: _tabController,
                              builder: (_, __) {
                                if (_tabController.index == 0) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _FieldLabel(
                                          label: 'login.email_label'.tr()),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (v) {
                                          if (_tabController.index != 0)
                                            return null;
                                          if (v == null || v.isEmpty)
                                            return 'login.required_field'.tr();
                                          if (!v.contains('@'))
                                            return 'login.invalid_email'.tr();
                                          return null;
                                        },
                                        style: const TextStyle(
                                          fontFamily:
                                              AppConstants.fontFamilyInter,
                                          fontSize: AppConstants.fontSizeMedium,
                                          color: AppColors.textDark,
                                        ),
                                        decoration: _inputDecoration(
                                          hint: 'login.email_hint'.tr(),
                                          prefixIcon: Icons.email_outlined,
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _FieldLabel(
                                          label: 'login.phone_label'.tr()),
                                      const SizedBox(height: 6),
                                      IntlPhoneField(
                                        controller: _phoneController,
                                        initialCountryCode: 'SN',
                                        keyboardType: TextInputType.phone,
                                        style: const TextStyle(
                                          fontFamily:
                                              AppConstants.fontFamilyInter,
                                          fontSize: AppConstants.fontSizeMedium,
                                          color: AppColors.textDark,
                                        ),
                                        decoration: InputDecoration(
                                          hintText:
                                              'login.phone_hint_field'.tr(),
                                          hintStyle: const TextStyle(
                                            fontFamily:
                                                AppConstants.fontFamilyInter,
                                            color: AppColors.hintText,
                                            fontSize:
                                                AppConstants.fontSizeMedium,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 14),
                                          filled: true,
                                          fillColor: AppColors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppConstants.radiusRound),
                                            borderSide: const BorderSide(
                                                color: AppColors.borderLight),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppConstants.radiusRound),
                                            borderSide: const BorderSide(
                                                color: AppColors.borderLight),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppConstants.radiusRound),
                                            borderSide: const BorderSide(
                                                color: AppColors.primary,
                                                width: AppConstants
                                                    .borderWidthMedium),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppConstants.radiusRound),
                                            borderSide: const BorderSide(
                                                color:
                                                    AppColors.statusRejected),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppConstants.radiusRound),
                                            borderSide: const BorderSide(
                                                color:
                                                    AppColors.statusRejected),
                                          ),
                                        ),
                                        validator: (phone) {
                                          if (_tabController.index != 1)
                                            return null;
                                          if (phone == null ||
                                              phone.number.isEmpty)
                                            return 'login.required_field'.tr();
                                          return null;
                                        },
                                        onChanged: (phone) {
                                          _fullPhone = phone.completeNumber;
                                        },
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // ── Mot de passe ──
                            _FieldLabel(label: 'login.password_label'.tr()),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'login.required_field'.tr();
                                return null;
                              },
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                color: AppColors.textDark,
                              ),
                              decoration: _inputDecoration(
                                hint: 'login.password_hint'.tr(),
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                  child: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textSecondary,
                                    size: AppConstants.iconSizeMedium,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .pushNamed(AppRoutes.forgotPassword),
                                child: Text(
                                  'forgot_password.title'.tr(),
                                  style: const TextStyle(
                                    fontFamily: AppConstants.fontFamilyInter,
                                    fontSize: AppConstants.fontSizeRegular,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Bouton + lien collés en bas ──
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppConstants.paddingLarge,
                      right: AppConstants.paddingLarge,
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                      top: 12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: AppConstants.logoutButtonHeight,
                          child: ElevatedButton(
                            onPressed:
                                isLoading ? null : () => _onLogin(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              disabledBackgroundColor:
                                  AppColors.primaryDark.withValues(alpha: 0.6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusRound),
                              ),
                            ),
                            child: isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.white),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Connexion en cours...',
                                        style: const TextStyle(
                                          fontFamily:
                                              AppConstants.fontFamilySofiaSans,
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: AppConstants.fontSizeLarge,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'login.login_button'.tr(),
                                    style: const TextStyle(
                                      fontFamily:
                                          AppConstants.fontFamilySofiaSans,
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: AppConstants.fontSizeLarge,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Lien S'inscrire
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'login.no_account'.tr(),
                                  style: const TextStyle(
                                    fontFamily: AppConstants.fontFamilyInter,
                                    fontSize: AppConstants.fontSizeMedium,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextSpan(
                                  text: 'login.register'.tr(),
                                  style: const TextStyle(
                                    fontFamily: AppConstants.fontFamilyInter,
                                    fontSize: AppConstants.fontSizeMedium,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Lien Continuer mon inscription
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.resumeRegistration),
                          child: Text(
                            'login.continue_registration'.tr(),
                            style: const TextStyle(
                              fontFamily: AppConstants.fontFamilyInter,
                              fontSize: AppConstants.fontSizeMedium,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _checkSubscriptionAndNavigate(
    BuildContext context, {
    required String accessToken,
    required UserBloc userBloc,
    required NotificationsBloc notifBloc,
  }) async {
    try {
      final sub = await SubscriptionService()
          .getEffectiveSubscription(accessToken: accessToken);
      debugPrint('[LoginScreen] Abonnement: isActive=${sub?.isActive} planCode=${sub?.planCode}');
      if (!mounted) return;
      userBloc.add(LoadUserProfile(accessToken));
      notifBloc.add(const LoadNotificationsEvent());
      _sendFcmTokenAfterLogin();
      if (sub == null || !sub.isActive) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.activationRequise,
          (route) => false,
        );
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.clientHome,
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('[LoginScreen] Erreur vérif abonnement: $e');
      if (!mounted) return;
      // En cas d'erreur réseau, on laisse passer vers l'accueil
      userBloc.add(LoadUserProfile(accessToken));
      notifBloc.add(const LoadNotificationsEvent());
      _sendFcmTokenAfterLogin();
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.clientHome,
        (route) => false,
      );
    }
  }

  // 👇 NOUVEAU — Récupère le token FCM et l'envoie au backend
  void _showIncompleteDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
        title: Row(children: [
          const Icon(Icons.info_outline,
              color: AppColors.primary, size: AppConstants.iconSizeLarge),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'login.incomplete_title'.tr(),
              style: const TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontWeight: FontWeight.w700,
                  fontSize: AppConstants.fontSizeLarge,
                  color: AppColors.textDark),
            ),
          ),
        ]),
        content: Text('login.incomplete_message'.tr(),
            style: const TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontSize: AppConstants.fontSizeMedium,
                color: AppColors.textSecondary,
                height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('login.incomplete_later'.tr(),
                style: const TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamed(AppRoutes.resumeRegistration);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusRound))),
            child: Text('login.incomplete_action'.tr(),
                style: const TextStyle(
                    fontFamily: AppConstants.fontFamilySofiaSans,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendFcmTokenAfterLogin() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await FcmService.sendTokenToBackend(fcmToken);
      }
    } catch (e) {
      print('[LoginScreen] Erreur envoi token FCM: $e');
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool isPassword = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: AppConstants.fontFamilyInter,
        color: isPassword ? AppColors.hintPassword : AppColors.hintText,
        fontSize: AppConstants.fontSizeMedium,
      ),
      prefixIcon: Icon(prefixIcon,
          color: AppColors.textSecondary, size: AppConstants.iconSizeMedium),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        borderSide: const BorderSide(
            color: AppColors.primary, width: AppConstants.borderWidthMedium),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        borderSide: const BorderSide(color: AppColors.statusRejected),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        borderSide: const BorderSide(color: AppColors.statusRejected),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: AppConstants.fontFamilyInter,
        fontSize: AppConstants.fontSizeMedium,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
    );
  }
}

class _LoginTabOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LoginTabOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppConstants.fontFamilySofiaSans,
              fontSize: AppConstants.fontSizeMedium,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.textDark : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Extrait le sub (userId) depuis le JWT
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

/// Utilisé uniquement depuis le deep link KYC.
class LoginScreenDeepLink extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreenDeepLink({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreenDeepLink> createState() => _LoginScreenDeepLinkState();
}

class _LoginScreenDeepLinkState extends State<LoginScreenDeepLink> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ));
  }

  // 👇 NOUVEAU — Même logique que LoginScreen
  Future<void> _sendFcmTokenAfterLogin() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await FcmService.sendTokenToBackend(fcmToken);
      }
    } catch (e) {
      print('[LoginScreenDeepLink] Erreur envoi token FCM: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            UserSession.instance.accessToken = state.accessToken;
            UserSession.instance.refreshToken = state.refreshToken;
            UserSession.instance.userId =
                _extractUserIdFromJwt(state.accessToken);
            SessionStorage.instance.save(
              token: state.accessToken,
              refreshToken: state.refreshToken,
              name: '${state.firstName} ${state.lastName}'.trim(),
            );
            context.read<UserBloc>().add(LoadUserProfile(state.accessToken));
            context
                .read<UserBloc>()
                .add(LoadProfilePictureEvent(state.accessToken));
            context
                .read<NotificationsBloc>()
                .add(const LoadNotificationsEvent());

            // 👇 NOUVEAU — Envoyer le token FCM au backend après login
            _sendFcmTokenAfterLogin();

            // Seule différence : callback au lieu de pushNamedAndRemoveUntil
            widget.onLoginSuccess();
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.statusRejected,
            ));
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingLarge,
                        vertical: AppConstants.paddingLarge),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: AppConstants.avatarSizeSmall,
                            height: AppConstants.avatarSizeSmall,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.backCircleColor,
                                  width: 1.26),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: AppColors.backArrowColor, size: 20.6),
                          ),
                        ),
                        Image.asset('assets/images/qfwithtext.png',
                            height: 82, fit: BoxFit.contain),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                          AppConstants.paddingLarge,
                          AppConstants.paddingLarge,
                          AppConstants.paddingLarge,
                          AppConstants.paddingXLarge),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('login.login_title'.tr(),
                                style: const TextStyle(
                                  fontFamily: AppConstants.fontFamilySofiaSans,
                                  fontSize: AppConstants.fontSizeTitle,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                )),
                            const SizedBox(height: 6),
                            Text('login.login_subtitle'.tr(),
                                style: const TextStyle(
                                  fontFamily: AppConstants.fontFamilyInter,
                                  fontSize: AppConstants.fontSizeMedium,
                                  color: AppColors.textSecondary,
                                )),
                            const SizedBox(height: 32),
                            _FieldLabel(label: 'login.email_label'.tr()),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v!.isEmpty)
                                  return 'login.required_field'.tr();
                                if (!v.contains('@'))
                                  return 'login.invalid_email'.tr();
                                return null;
                              },
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                color: AppColors.textDark,
                              ),
                              decoration: _inputDecorationDL(
                                hint: 'login.email_hint'.tr(),
                                prefixIcon: Icons.email_outlined,
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),
                            _FieldLabel(label: 'login.password_label'.tr()),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'login.required_field'.tr()
                                  : null,
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                color: AppColors.textDark,
                              ),
                              decoration: _inputDecorationDL(
                                hint: 'login.password_hint'.tr(),
                                prefixIcon: Icons.lock_outline,
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                  child: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textSecondary,
                                    size: AppConstants.iconSizeMedium,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppConstants.paddingLarge,
                      right: AppConstants.paddingLarge,
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                      top: 12,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: AppConstants.logoutButtonHeight,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _onLogin(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          disabledBackgroundColor:
                              AppColors.primaryDark.withValues(alpha: 0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusRound)),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.white))
                            : Text('login.login_button'.tr(),
                                style: const TextStyle(
                                  fontFamily: AppConstants.fontFamilySofiaSans,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppConstants.fontSizeLarge,
                                )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecorationDL({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: AppConstants.fontFamilyInter,
        color: AppColors.hintText,
        fontSize: AppConstants.fontSizeMedium,
      ),
      prefixIcon: Icon(prefixIcon,
          color: AppColors.textSecondary, size: AppConstants.iconSizeMedium),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          borderSide: const BorderSide(color: AppColors.borderLight)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          borderSide: const BorderSide(color: AppColors.borderLight)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          borderSide: const BorderSide(
              color: AppColors.primary, width: AppConstants.borderWidthMedium)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          borderSide: const BorderSide(color: AppColors.statusRejected)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          borderSide: const BorderSide(color: AppColors.statusRejected)),
    );
  }
}
