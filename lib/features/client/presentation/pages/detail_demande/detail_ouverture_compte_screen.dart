import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';

class DetailOuvertureCompteScreen extends StatelessWidget {
  const DetailOuvertureCompteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: AppConstants.screenWidth,
              height: AppConstants.screenHeight,
              color: AppColors.primaryDark,
              child: Stack(
                children: [
                  // Bouton retour
                  Positioned(
                    top: 70,
                    left: AppConstants.paddingLarge + 8,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: AppConstants.backButtonSize,
                        height: AppConstants.backButtonSize,
                        decoration: BoxDecoration(
                          color: AppColors.whiteOverlay,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/ep_back.svg',
                            width: 21.428571701049805,
                            height: 21.428571701049805,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Titre "Ouverture de compte"
                  Positioned(
                    top: 78,
                    left: 90,
                    child: Text(
                      'Ouverture de compte',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: AppConstants.fontSizeXXLarge,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  // Sous-titre
                  Positioned(
                    top: 102,
                    left: 90,
                    child: Text(
                      'Banque Nationale • 18/12/2025',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: AppConstants.fontSizeRegular,
                        color: AppColors.whiteOpacity(0.6),
                      ),
                    ),
                  ),
                  // Badge "Brouillon"
                  Positioned(
                    top: 78,
                    right: AppConstants.paddingLarge + 8,
                    child: Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.statusDraftLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Center(
                        child: Text(
                          'Brouillon',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontWeight: FontWeight.w500,
                            fontSize: AppConstants.fontSizeSmall,
                            color: AppColors.statusDraft,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Container blanc en bas du header
                  Positioned(
                    top: 150,
                    left: AppConstants.paddingLarge + 8,
                    right: AppConstants.paddingLarge + 8,
                    child: Container(
                      padding: EdgeInsets.all(AppConstants.paddingLarge),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REQ-2024-004',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilyInter,
                              fontWeight: FontWeight.w600,
                              fontSize: AppConstants.fontSizeMedium,
                              height: 1.0,
                              letterSpacing: 0.03,
                              color: AppColors.textDarkGray,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Soumis le 15/12, 10h00',
                                style: TextStyle(
                                  fontFamily: AppConstants.fontFamilyInter,
                                  fontWeight: FontWeight.w500,
                                  fontSize: AppConstants.fontSizeRegular,
                                  height: 1.0,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                'Estimé : 17/12',
                                style: TextStyle(
                                  fontFamily: AppConstants.fontFamilyInter,
                                  fontWeight: FontWeight.w500,
                                  fontSize: AppConstants.fontSizeRegular,
                                  height: 1.0,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppConstants.paddingXLarge),
                          // Barre de progression
                          Row(
                            children: [
                              // Étape 1: Enregistré
                              Column(
                                children: [
                                  Container(
                                    width: AppConstants.progressStepSize,
                                    height: AppConstants.progressStepSize,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryDark,
                                      borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/bi_pencil (1).svg',
                                        width: AppConstants.iconSizeMedium,
                                        height: AppConstants.iconSizeMedium,
                                        colorFilter: ColorFilter.mode(
                                          AppColors.white,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: AppConstants.paddingSmall),
                                  Text(
                                    'Enregistré',
                                    style: TextStyle(
                                      fontFamily: AppConstants.fontFamilyInter,
                                      fontWeight: FontWeight.w500,
                                      fontSize: AppConstants.fontSizeRegular,
                                      height: 1.0,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              // Ligne de progression 1
                              Expanded(
                                child: Container(
                                  height: AppConstants.progressLineHeight,
                                  margin: EdgeInsets.only(bottom: 32),
                                  decoration: BoxDecoration(
                                    color: AppColors.divider,
                                    borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                                  ),
                                ),
                              ),
                              // Étape 2: En cours
                              Column(
                                children: [
                                  Container(
                                    width: AppConstants.progressStepSize,
                                    height: AppConstants.progressStepSize,
                                    decoration: BoxDecoration(
                                      color: AppColors.borderDivider,
                                      borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/bi_clock-history.svg',
                                        width: AppConstants.iconSizeMedium,
                                        height: AppConstants.iconSizeMedium,
                                        colorFilter: ColorFilter.mode(
                                          AppColors.textLight,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: AppConstants.paddingSmall),
                                  Text(
                                    'En cours',
                                    style: TextStyle(
                                      fontFamily: AppConstants.fontFamilyInter,
                                      fontWeight: FontWeight.w500,
                                      fontSize: AppConstants.fontSizeRegular,
                                      height: 1.0,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              // Ligne de progression 2
                              Expanded(
                                child: Container(
                                  height: AppConstants.progressLineHeight,
                                  margin: EdgeInsets.only(bottom: 32),
                                  decoration: BoxDecoration(
                                    color: AppColors.divider,
                                    borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                                  ),
                                ),
                              ),
                              // Étape 3: Finalisé
                              Column(
                                children: [
                                  Container(
                                    width: AppConstants.progressStepSize,
                                    height: AppConstants.progressStepSize,
                                    decoration: BoxDecoration(
                                      color: AppColors.borderDivider,
                                      borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/ep_check.svg',
                                        width: AppConstants.iconSizeMedium,
                                        height: AppConstants.iconSizeMedium,
                                        colorFilter: ColorFilter.mode(
                                          AppColors.textLight,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: AppConstants.paddingSmall),
                                  Text(
                                    'Finalisé',
                                    style: TextStyle(
                                      fontFamily: AppConstants.fontFamilyInter,
                                      fontWeight: FontWeight.w500,
                                      fontSize: AppConstants.fontSizeRegular,
                                      height: 1.0,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Nouveau container
                  Positioned(
                    top: 320,
                    left: AppConstants.paddingLarge + 8,
                    right: AppConstants.paddingLarge + 8,
                    child: Container(
                      height: AppConstants.documentContainerHeight,
                      padding: EdgeInsets.fromLTRB(
                        AppConstants.paddingLarge,
                        AppConstants.paddingXLarge,
                        AppConstants.paddingLarge,
                        AppConstants.paddingXLarge,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        border: Border.all(
                          color: AppColors.border,
                          width: AppConstants.borderWidthThin,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowDark,
                            offset: Offset(3, 3),
                            blurRadius: 3,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: AppConstants.iconSizeHuge),
                          SvgPicture.asset(
                            'assets/icons/hugeicons_files-02.svg',
                            width: AppConstants.iconSizeLarge,
                            height: AppConstants.iconSizeLarge,
                          ),
                          SizedBox(height: AppConstants.paddingLarge),
                          Text(
                            'Aucun document fourni',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilyInter,
                              fontWeight: FontWeight.w600,
                              fontSize: AppConstants.fontSizeMedium,
                              height: 1.0,
                              color: AppColors.cardSubtext,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppConstants.paddingSmall),
                          Text(
                            'Merci de téléverser le formulaire rempli.',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilyInter,
                              fontWeight: FontWeight.w500,
                              fontSize: AppConstants.fontSizeRegular,
                              height: 1.0,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bouton en bas
                  Positioned(
                    bottom: 80,
                    left: AppConstants.paddingLarge + 8,
                    right: AppConstants.paddingLarge + 8,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/detail-ouverture-compte-brouillon');
                      },
                      child: Container(
                        height: AppConstants.buttonHeightLarge,
                        padding: EdgeInsets.all(AppConstants.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/bi_pencil (1).svg',
                              width: AppConstants.iconSizeSmall,
                              height: AppConstants.iconSizeSmall,
                              colorFilter: ColorFilter.mode(
                                AppColors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: AppConstants.paddingSmall),
                            Text(
                              'Compléter les informations',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: AppConstants.fontSizeLarge,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
