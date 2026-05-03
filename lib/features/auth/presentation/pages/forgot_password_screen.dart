import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';
import 'package:quick_forms/core/utils/app_routes.dart';
import 'package:quick_forms/features/auth/domain/bloc/forgot_password_bloc.dart';
import 'package:quick_forms/features/auth/domain/bloc/forgot_password_event.dart';
import 'package:quick_forms/features/auth/domain/bloc/forgot_password_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late final ForgotPasswordBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ForgotPasswordBloc();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onSend() {
    if (!_formKey.currentState!.validate()) return;
    _bloc.add(ForgotPasswordRequestOtpEvent(_emailController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordOtpSent) {
            Navigator.of(context).pushNamed(
              AppRoutes.forgotPasswordOtp,
              arguments: _emailController.text.trim(),
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
                              'forgot_password.title'.tr(),
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilySofiaSans,
                                fontSize: AppConstants.fontSizeTitle,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'forgot_password.subtitle'.tr(),
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            _FieldLabel(
                                label: 'forgot_password.email_label'.tr()),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'forgot_password.required_field'.tr();
                                }
                                return null;
                              },
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                color: AppColors.textDark,
                              ),
                              decoration: _inputDecoration(
                                hint: 'forgot_password.email_hint'.tr(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Boutons bas
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
                            onPressed: isLoading ? null : _onSend,
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
                                        strokeWidth: 2, color: AppColors.white),
                                  )
                                : Text(
                                    'forgot_password.send_button'.tr(),
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
                          onTap: () =>
                              Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.login,
                            (route) => false,
                          ),
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

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: AppConstants.fontFamilyInter,
        color: AppColors.hintText,
        fontSize: AppConstants.fontSizeMedium,
      ),
      prefixIcon: const Icon(Icons.email_outlined,
          color: AppColors.textSecondary, size: AppConstants.iconSizeMedium),
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
