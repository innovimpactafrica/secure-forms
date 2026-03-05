import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/features/auth/presentation/pages/otp_verification_screen.dart';
import 'package:secure_link/features/auth/presentation/pages/register_screen.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // TODO: API — remplacer par AuthBloc + LoginRequested event
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              email: _emailController.text.trim(),
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // Bouton retour — cercle
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: AppConstants.avatarSizeSmall,
                      height: AppConstants.avatarSizeSmall,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textDark,
                        size: AppConstants.iconSizeMedium,
                      ),
                    ),
                  ),
                  // Logo image
                  Image.asset(
                    'assets/images/securelink.png',
                    height: AppConstants.logoHeight,
                    fit: BoxFit.contain,
                  ),
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

                      // Email
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
                      const SizedBox(height: AppConstants.paddingXLarge),

                      // Mot de passe
                      _FieldLabel(label: 'login.password_label'.tr()),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: (v) =>
                            v!.isEmpty ? 'login.required_field'.tr() : null,
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
                  // Bouton Se connecter
                  SizedBox(
                    width: double.infinity,
                    height: AppConstants.logoutButtonHeight,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        disabledBackgroundColor:
                            AppColors.primaryDark.withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusRound),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
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

                  // Lien S'inscrire souligné
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
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