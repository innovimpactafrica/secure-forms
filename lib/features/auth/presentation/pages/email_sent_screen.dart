import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';
import 'package:quick_forms/features/auth/presentation/pages/login_screen.dart';

class EmailSentScreen extends StatelessWidget {
  const EmailSentScreen({super.key});

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
              Image.asset(
                'assets/images/securelink.png',
                height: AppConstants.logoHeight,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 40),

              // Titre
              Text(
                'otp.account_created_title'.tr(),
                style: const TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontSize: AppConstants.fontSizeTitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 8),

              // Sous-titre coloré
              Text(
                'otp.check_email'.tr(),
                style: const TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'otp.password_link_sent'.tr(),
                style: const TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),

              const Spacer(flex: 3),

              // Bouton
              SizedBox(
                width: double.infinity,
                height: AppConstants.logoutButtonHeight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusRound),
                    ),
                  ),
                  child: Text(
                    'otp.go_to_login'.tr(),
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
