import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/features/auth/domain/bloc/forgot_password_bloc.dart';
import 'package:secure_link/features/auth/domain/bloc/forgot_password_event.dart';
import 'package:secure_link/features/auth/domain/bloc/forgot_password_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  late final ForgotPasswordBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ForgotPasswordBloc();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    _bloc.add(ForgotPasswordResetEvent(
      email: widget.email,
      otp: widget.otp,
      newPassword: _passwordController.text.trim(),
      confirmPassword: _confirmController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordResetSuccess) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.passwordUpdated,
              (route) => false,
            );
          } else if (state is ForgotPasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.statusRejected,
            ));
          }
        },
        builder: (context, state) {
          final isLoading = state is ForgotPasswordLoading;
          return Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(
              child: Column(
                children: [
                  // Header
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

                  // Formulaire
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
                            Text(
                              'forgot_password.new_password_title'.tr(),
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilySofiaSans,
                                fontSize: AppConstants.fontSizeTitle,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'forgot_password.new_password_subtitle'.tr(),
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Mot de passe
                            _FieldLabel(
                                label: 'forgot_password.password_label'.tr()),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'forgot_password.required_field'.tr();
                                }
                                if (v.length < 8) {
                                  return 'forgot_password.password_too_short'.tr();
                                }
                                return null;
                              },
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                color: AppColors.textDark,
                              ),
                              decoration: _passwordDecoration(
                                hint: '••••••••',
                                isObscure: _obscurePassword,
                                onToggle: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),

                            // Confirmer
                            _FieldLabel(
                                label: 'forgot_password.confirm_label'.tr()),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _confirmController,
                              obscureText: _obscureConfirm,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'forgot_password.required_field'.tr();
                                }
                                if (v != _passwordController.text) {
                                  return 'forgot_password.password_mismatch'.tr();
                                }
                                return null;
                              },
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                color: AppColors.textDark,
                              ),
                              decoration: _passwordDecoration(
                                hint: '••••••••',
                                isObscure: _obscureConfirm,
                                onToggle: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bouton bas
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
                            onPressed: isLoading ? null : _onSave,
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
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.white),
                                  )
                                : Text(
                                    'forgot_password.save_button'.tr(),
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
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushNamedAndRemoveUntil(
                                  AppRoutes.login, (route) => false),
                          child: Text(
                            'forgot_password.back_to_login'.tr(),
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

  InputDecoration _passwordDecoration({
    required String hint,
    required bool isObscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: AppConstants.fontFamilyInter,
        color: AppColors.hintText,
        fontSize: AppConstants.fontSizeMedium,
      ),
      prefixIcon: const Icon(Icons.lock_outline,
          color: AppColors.textSecondary, size: AppConstants.iconSizeMedium),
      suffixIcon: GestureDetector(
        onTap: onToggle,
        child: Icon(
          isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textSecondary,
          size: AppConstants.iconSizeMedium,
        ),
      ),
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

// ═══════════════════════════════════════════════
// ÉCRAN SUCCÈS — Mot de passe mis à jour
// ═══════════════════════════════════════════════
class PasswordUpdatedScreen extends StatelessWidget {
  const PasswordUpdatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingXLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // Logo
              Image.asset('assets/images/secureforms_logo.png',
                  height: 82, fit: BoxFit.contain),

              const SizedBox(height: 40),

              // Titre
              Text(
                'forgot_password.success_title'.tr(),
                style: const TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontSize: AppConstants.fontSizeTitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),

              // Sous-titre
              Text(
                'forgot_password.success_subtitle'.tr(),
                style: const TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              // Bouton Se connecter
              SizedBox(
                width: double.infinity,
                height: AppConstants.logoutButtonHeight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil(
                          AppRoutes.login, (route) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusRound),
                    ),
                  ),
                  child: Text(
                    'forgot_password.login_button'.tr(),
                    style: const TextStyle(
                      fontFamily: AppConstants.fontFamilySofiaSans,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: AppConstants.fontSizeLarge,
                    ),
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
            ],
          ),
        ),
      ),
    );
  }
}
