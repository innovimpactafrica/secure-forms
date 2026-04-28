import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/features/auth/domain/bloc/auth_bloc.dart';
import 'package:secure_link/features/auth/domain/bloc/auth_event.dart';
import 'package:secure_link/features/auth/domain/bloc/auth_state.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String token;
  const CreatePasswordScreen({super.key, required this.token});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onConfirm(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          SetupPasswordRequested(
            token: widget.token,
            password: _passwordController.text.trim(),
            confirmPassword: _confirmController.text.trim(),
          ),
        );
  }

  void _showSuccessAndRedirect(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _PasswordSuccessBottomSheet(),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordSetupSuccess) {
            _showSuccessAndRedirect(context);
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
                              border: Border.all(color: AppColors.backCircleColor, width: 1.26),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: AppColors.backArrowColor,
                                size: 20.6),
                          ),
                        ),
                        Image.asset('assets/images/qfwithtext.png',
                            height: 82, fit: BoxFit.contain),
                      ],
                    ),
                  ),

                  // ── Formulaire ──
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
                              'password.create_title'.tr(),
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilySofiaSans,
                                fontSize: AppConstants.fontSizeTitle,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'password.create_subtitle'.tr(),
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Règles du mot de passe ──
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppConstants.paddingMedium),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.info_outline,
                                          size: AppConstants.iconSizeMedium,
                                          color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        'register.password_rules_title'.tr(),
                                        style: const TextStyle(
                                          fontFamily: AppConstants.fontFamilySofiaSans,
                                          fontSize: AppConstants.fontSizeMedium,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _PasswordRule(text: 'register.password_rule_length'.tr()),
                                  _PasswordRule(text: 'register.password_rule_upper'.tr()),
                                  _PasswordRule(text: 'register.password_rule_lower'.tr()),
                                  _PasswordRule(text: 'register.password_rule_number'.tr()),
                                  _PasswordRule(text: 'register.password_rule_special'.tr()),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Nouveau mot de passe ──
                            _FieldLabel(label: 'password.new_password'.tr()),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'login.required_field'.tr();
                                if (v.length < 8) return 'password.min_length'.tr();
                                return null;
                              },
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                color: AppColors.textDark,
                              ),
                              decoration: _passwordDecoration(
                                hint: 'password.new_password_hint'.tr(),
                                isObscure: _obscurePassword,
                                onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),

                            // ── Confirmer mot de passe ──
                            _FieldLabel(label: 'password.confirm_password'.tr()),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _confirmController,
                              obscureText: _obscureConfirm,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'login.required_field'.tr();
                                if (v != _passwordController.text) return 'password.mismatch'.tr();
                                return null;
                              },
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                color: AppColors.textDark,
                              ),
                              decoration: _passwordDecoration(
                                hint: 'password.confirm_password_hint'.tr(),
                                isObscure: _obscureConfirm,
                                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Bouton Confirmer ──
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
                        onPressed: isLoading ? null : () => _onConfirm(context),
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
                                'password.confirm_button'.tr(),
                                style: const TextStyle(
                                  fontFamily: AppConstants.fontFamilySofiaSans,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppConstants.fontSizeLarge,
                                ),
                              ),
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

class _PasswordRule extends StatelessWidget {
  final String text;
  const _PasswordRule({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              size: AppConstants.iconSizeSmall,
              color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: AppConstants.fontFamilyInter,
              fontSize: AppConstants.fontSizeRegular,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// MODAL SUCCÈS — "Mot de passe défini. Bienvenue !"
// ═════════════════════════════════════════════════════════════════
class _PasswordSuccessBottomSheet extends StatelessWidget {
  const _PasswordSuccessBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppConstants.paddingLarge,
        right: AppConstants.paddingLarge,
        bottom: MediaQuery.of(context).padding.bottom + AppConstants.paddingLarge,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 20,
                offset: Offset(0, -4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primary,
                    width: AppConstants.borderWidthThick),
              ),
              child: const Icon(Icons.check,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'password.success_message'.tr(),
                style: const TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

