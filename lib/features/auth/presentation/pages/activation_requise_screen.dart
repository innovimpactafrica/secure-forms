import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';
import 'package:quick_forms/core/utils/app_routes.dart';

class ActivationRequiseScreen extends StatelessWidget {
  const ActivationRequiseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingXLarge),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Icône cloche
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusLarge),
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: AppColors.white,
                        size: AppConstants.iconSizeHuge,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingXLarge),

                    // Titre
                    Text(
                      'activation.title'.tr(),
                      style: const TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        fontSize: AppConstants.fontSizeTitle,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Sous-titre
                    Text(
                      'activation.subtitle'.tr(),
                      style: const TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontSize: AppConstants.fontSizeMedium,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'activation.description'.tr(),
                      style: const TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontSize: AppConstants.fontSizeRegular,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingXLarge * 2),

                    // Bouton Activer mon abonnement
                    SizedBox(
                      width: double.infinity,
                      height: AppConstants.logoutButtonHeight,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed(AppRoutes.plans),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusRound),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'activation.cta_button'.tr(),
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilySofiaSans,
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: AppConstants.fontSizeLarge,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward,
                                color: AppColors.white,
                                size: AppConstants.iconSizeMedium),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),

                    // Card Accès Instantané
                    Container(
                      padding:
                          const EdgeInsets.all(AppConstants.paddingLarge),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                            AppConstants.radiusMedium),
                        border: Border.all(color: AppColors.borderDivider),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowDark,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.statusPendingLight,
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusSmall),
                            ),
                            child: const Icon(
                              Icons.bolt,
                              color: AppColors.statusPending,
                              size: AppConstants.iconSizeLarge,
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'activation.instant_access_title'.tr(),
                                  style: const TextStyle(
                                    fontFamily:
                                        AppConstants.fontFamilySofiaSans,
                                    fontSize: AppConstants.fontSizeMedium,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'activation.instant_access_desc'.tr(),
                                  style: const TextStyle(
                                    fontFamily: AppConstants.fontFamilyInter,
                                    fontSize: AppConstants.fontSizeRegular,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Lien aide
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.help_outline,
                              size: AppConstants.iconSizeSmall,
                              color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            'activation.help'.tr(),
                            style: const TextStyle(
                              fontFamily: AppConstants.fontFamilyInter,
                              fontSize: AppConstants.fontSizeRegular,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Lien retour connexion
                    GestureDetector(
                      onTap: () => Navigator.of(context)
                          .pushNamedAndRemoveUntil(
                              AppRoutes.login, (route) => false),
                      child: Text(
                        'Retour à la connexion',
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontSize: AppConstants.fontSizeRegular,
                          color: AppColors.textSecondary
                              .withValues(alpha: 0.5),
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.textSecondary
                              .withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingXLarge),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
