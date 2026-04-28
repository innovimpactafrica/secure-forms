import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/features/auth/data/services/auth_service.dart';

class ResumeRegistrationScreen extends StatefulWidget {
  const ResumeRegistrationScreen({super.key});

  @override
  State<ResumeRegistrationScreen> createState() =>
      _ResumeRegistrationScreenState();
}

class _ResumeRegistrationScreenState extends State<ResumeRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _service = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _service.resumeSetupRequestOtp(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        AppRoutes.resumeRegistrationOtp,
        arguments: {'email': _emailController.text.trim()},
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.statusRejected,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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

            // Contenu scrollable
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
                        'resume_registration.title'.tr(),
                        style: const TextStyle(
                          fontFamily: AppConstants.fontFamilySofiaSans,
                          fontSize: AppConstants.fontSizeTitle,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'resume_registration.subtitle'.tr(),
                        style: const TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontSize: AppConstants.fontSizeMedium,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email
                      Text(
                        'resume_registration.field_label'.tr(),
                        style: const TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontSize: AppConstants.fontSizeMedium,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.text,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'login.required_field'.tr();
                          }
                          return null;
                        },
                        style: const TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontSize: AppConstants.fontSizeMedium,
                          color: AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'resume_registration.field_hint'.tr(),
                          hintStyle: const TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            color: AppColors.hintText,
                            fontSize: AppConstants.fontSizeMedium,
                          ),
                          prefixIcon: const Icon(Icons.person_outline,
                              color: AppColors.textSecondary,
                              size: AppConstants.iconSizeMedium),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusRound),
                            borderSide:
                                const BorderSide(color: AppColors.borderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusRound),
                            borderSide:
                                const BorderSide(color: AppColors.borderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusRound),
                            borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: AppConstants.borderWidthMedium),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusRound),
                            borderSide: const BorderSide(
                                color: AppColors.statusRejected),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusRound),
                            borderSide: const BorderSide(
                                color: AppColors.statusRejected),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'resume_registration.email_hint'.tr(),
                        style: const TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontSize: AppConstants.fontSizeRegular,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bouton + lien
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
                      onPressed: _isLoading ? null : _onSend,
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
                                  strokeWidth: 2, color: AppColors.white),
                            )
                          : Text(
                              'resume_registration.send_button'.tr(),
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
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'resume_registration.already_account'.tr(),
                            style: const TextStyle(
                              fontFamily: AppConstants.fontFamilyInter,
                              fontSize: AppConstants.fontSizeMedium,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text: 'resume_registration.login_link'.tr(),
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
}
