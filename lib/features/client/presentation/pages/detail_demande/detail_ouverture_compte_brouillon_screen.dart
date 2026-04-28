import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';

class DetailOuvertureCompteBrouillonScreen extends StatelessWidget {
  const DetailOuvertureCompteBrouillonScreen({super.key});

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
                    left: AppConstants.paddingXLarge,
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
                    right: AppConstants.paddingXLarge,
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
                  // Barre de progression 3/5
                  Positioned(
                    top: 140,
                    left: AppConstants.paddingXLarge,
                    child: Stack(
                      children: [
                        Container(
                          width: AppConstants.progressBarWidth,
                          height: AppConstants.progressBarHeight,
                          decoration: BoxDecoration(
                            color: AppColors.progressBar,
                            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                          ),
                        ),
                        Container(
                          width: 192,
                          height: AppConstants.progressBarHeight,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Indicateur 3/5
                  Positioned(
                    top: 135.6,
                    left: 354,
                    child: Text(
                      '3/5',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontWeight: FontWeight.w500,
                        fontSize: AppConstants.fontSizeMedium,
                        height: 1.0,
                        letterSpacing: 0,
                        color: AppColors.textLightGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Titre "Téléverser le formulaire rempli"
                  Positioned(
                    top: 185,
                    left: AppConstants.paddingXLarge,
                    child: Text(
                      'Téléverser le formulaire rempli',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontWeight: FontWeight.w600,
                        fontSize: AppConstants.fontSizeLarge,
                        height: 24 / 16,
                        letterSpacing: 0,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  // Sous-titre "Sélectionnez le fichier PDF rempli"
                  Positioned(
                    top: 210,
                    left: AppConstants.paddingXLarge,
                    child: Text(
                      'Sélectionnez le fichier PDF rempli',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontWeight: FontWeight.w400,
                        fontSize: AppConstants.fontSizeMedium,
                        height: 24 / 14,
                        letterSpacing: 0,
                        color: AppColors.whiteOpacity(0.7),
                      ),
                    ),
                  ),
                  // Nouveau container
                  Positioned(
                    top: 260,
                    left: AppConstants.paddingXLarge,
                    right: AppConstants.paddingXLarge,
                    child: Container(
                      height: AppConstants.documentContainerHeight,
                      padding: EdgeInsets.fromLTRB(AppConstants.paddingLarge, AppConstants.paddingXLarge, AppConstants.paddingLarge, AppConstants.paddingXLarge),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        border: Border.all(color: AppColors.border, width: AppConstants.borderWidthThin),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowDark,
                            offset: const Offset(3, 3),
                            blurRadius: 3,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 150,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: EdgeInsets.fromLTRB(AppConstants.paddingLarge, AppConstants.radiusXLarge, AppConstants.paddingLarge, AppConstants.radiusXLarge),
                            decoration: BoxDecoration(
                              color: AppColors.statusValidatedLight,
                              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              border: Border.all(
                                color: AppColors.primary,
                                width: AppConstants.borderWidthThin,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: AppConstants.cardIconSize,
                                  height: AppConstants.cardIconSize,
                                  padding: EdgeInsets.fromLTRB(AppConstants.paddingMedium, AppConstants.paddingSmall + 2, AppConstants.paddingMedium, AppConstants.paddingSmall + 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icons/bi_cloud-upload.svg',
                                    width: 12,
                                    height: 16,
                                    colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Cliquez pour télécharger',
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamilyInter,
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppConstants.fontSizeMedium,
                                    height: 1.0,
                                    color: AppColors.cardSubtext,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'PDF, JPG, PNG jusqu\'à 10 Mo',
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
                        ],
                      ),
                    ),
                  ),
                  // Nouveau container en bas
                  Positioned(
                    top: 480,
                    left: AppConstants.paddingXLarge,
                    right: AppConstants.paddingXLarge,
                    child: GestureDetector(
                      onTap: () {
                        // Navigation vers Client - Detail demande - Brouillon
                      },
                      child: Container(
                        height: 88,
                        padding: EdgeInsets.fromLTRB(AppConstants.paddingLarge, AppConstants.radiusXLarge, AppConstants.paddingLarge, AppConstants.radiusXLarge),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          border: Border.all(color: AppColors.whiteOverlay, width: AppConstants.borderWidthThin),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              offset: const Offset(0, 2),
                              blurRadius: 48,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      'Formulaire_ouverture_compte.pdf',
                                      style: TextStyle(
                                        fontFamily: AppConstants.fontFamilySofiaSans,
                                        fontWeight: FontWeight.w600,
                                        fontSize: AppConstants.fontSizeLarge,
                                        height: 24 / 16,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Document officiel • 1,2 Mo',
                                    style: TextStyle(
                                      fontFamily: AppConstants.fontFamilySofiaSans,
                                      fontWeight: FontWeight.w400,
                                      fontSize: AppConstants.fontSizeRegular,
                                      height: 1.0,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 1.5, top: 12),
                              child: SvgPicture.asset(
                                'assets/icons/iconamoon_trash.svg',
                                width: 21,
                                height: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bouton en bas
                  Positioned(
                    bottom: 80,
                    left: AppConstants.paddingXLarge,
                    right: AppConstants.paddingXLarge,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/detail-ouverture-compte-continuer');
                      },
                      child: Container(
                        height: AppConstants.buttonHeightLarge,
                        padding: EdgeInsets.all(AppConstants.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                        ),
                        child: Center(
                          child: Text(
                            'Continuer',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: AppConstants.fontSizeLarge,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
