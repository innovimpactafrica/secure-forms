import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/core/utils/session_storage.dart';
import 'package:secure_link/features/auth/domain/bloc/auth_bloc.dart';
import 'package:secure_link/features/auth/domain/bloc/auth_event.dart';
import 'package:secure_link/features/auth/domain/bloc/auth_state.dart';
import 'package:secure_link/features/auth/domain/bloc/user_bloc.dart';
import 'package:secure_link/features/auth/domain/bloc/user_event.dart';
import 'package:secure_link/features/client/domain/bloc/notifications_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/notifications_event.dart';
import 'package:secure_link/features/auth/presentation/pages/register_screen.dart';
import 'package:secure_link/core/services/fcm_service.dart'; // 👈 NOUVEAU
import 'package:firebase_messaging/firebase_messaging.dart'; // 👈 NOUVEAU
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    context.read<AuthBloc>().add(
          LoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          ),
        );
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
            UserSession.instance.userId = _extractUserIdFromJwt(state.accessToken);
            print('[LoginScreen] Login réussi → token stocké (longueur: ${state.accessToken.length})');
            // Persister la session
            SessionStorage.instance.save(
              token: state.accessToken,
              refreshToken: state.refreshToken,
              name: '${state.firstName} ${state.lastName}'.trim(),
            );
            // Charger profil + photo en parallèle dès le login
            context.read<UserBloc>().add(LoadUserProfile(state.accessToken));
            context.read<UserBloc>().add(LoadProfilePictureEvent(state.accessToken));
            context.read<NotificationsBloc>().add(const LoadNotificationsEvent());

            // 👇 NOUVEAU — Envoyer le token FCM au backend après login
            _sendFcmTokenAfterLogin();

            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.clientHome,
              (route) => false,
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
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
                              border: Border.all(color: AppColors.borderLight),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: AppColors.textDark,
                                size: AppConstants.iconSizeMedium),
                          ),
                        ),
                        Image.asset('assets/images/secureforms_logo.png',
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
                              'login.login_subtitle'.tr(),
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // ── Email ──
                            _FieldLabel(label: 'login.email_label'.tr()),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v!.isEmpty) return 'login.required_field'.tr();
                                if (!v.contains('@')) return 'login.invalid_email'.tr();
                                return null;
                              },
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                color: AppColors.textDark,
                              ),
                              decoration: _inputDecoration(
                                hint: 'login.email_hint'.tr(),
                                prefixIcon: Icons.email_outlined,
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),

                            // ── Mot de passe ──
                            _FieldLabel(label: 'login.password_label'.tr()),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'login.required_field'.tr();
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
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
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
                            onPressed: isLoading ? null : () => _onLogin(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              disabledBackgroundColor:
                                  AppColors.primaryDark.withValues(alpha: 0.6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: AppColors.white),
                                  )
                                : Text(
                                    'login.login_button'.tr(),
                                    style: const TextStyle(
                                      fontFamily: AppConstants.fontFamilySofiaSans,
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

  // 👇 NOUVEAU — Récupère le token FCM et l'envoie au backend
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
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        borderSide: const BorderSide(
            color: AppColors.primary, width: AppConstants.borderWidthMedium),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        borderSide: const BorderSide(color: AppColors.statusRejected),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
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
            context.read<UserBloc>().add(LoadProfilePictureEvent(state.accessToken));
            context.read<NotificationsBloc>().add(const LoadNotificationsEvent());

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
                              border: Border.all(color: AppColors.borderLight),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: AppColors.textDark,
                                size: AppConstants.iconSizeMedium),
                          ),
                        ),
                        Image.asset('assets/images/secureforms_logo.png',
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
                                if (v!.isEmpty) return 'login.required_field'.tr();
                                if (!v.contains('@')) return 'login.invalid_email'.tr();
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
                                  onTap: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
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
                                width: 22, height: 22,
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
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          borderSide: const BorderSide(color: AppColors.borderLight)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          borderSide: const BorderSide(color: AppColors.borderLight)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          borderSide: const BorderSide(
              color: AppColors.primary,
              width: AppConstants.borderWidthMedium)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          borderSide: const BorderSide(color: AppColors.statusRejected)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          borderSide: const BorderSide(color: AppColors.statusRejected)),
    );
  }
}