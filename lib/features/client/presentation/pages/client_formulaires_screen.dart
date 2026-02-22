import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';

class ClientFormulairesScreen extends StatefulWidget {
  const ClientFormulairesScreen({super.key});

  @override
  State<ClientFormulairesScreen> createState() => _ClientFormulairesScreenState();
}

class _ClientFormulairesScreenState extends State<ClientFormulairesScreen> {
  int? selectedCard; // null = aucune sélection, 0-3 = carte sélectionnée

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: AppConstants.screenWidth,
        height: AppConstants.screenHeight,
        color: AppColors.background,
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
            // Titre "Nouvelle demande"
            Positioned(
              top: 78,
              left: 90,
              child: Text(
                'Nouvelle demande',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: AppConstants.fontSizeXXLarge,
                  color: AppColors.white,
                ),
              ),
            ),
            // Sous-titre
            Positioned(
              top: 105,
              left: 90,
              child: Text(
                'Banque Nationale',
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontWeight: FontWeight.w500,
                  fontSize: AppConstants.fontSizeRegular,
                  height: 1.0,
                  letterSpacing: 0,
                  color: AppColors.whiteOpacity(0.6),
                ),
              ),
            ),
            // Barre de progression
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
                    width: 70,
                    height: AppConstants.progressBarHeight,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                    ),
                  ),
                ],
              ),
            ),
            // Indicateur 1/5
            Positioned(
              top: 135.6,
              left: 354,
              child: Text(
                '1/5',
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
            // Titre principal
            Positioned(
              top: 153,
              left: AppConstants.paddingXLarge,
              child: Text(
                'Sélectionnez un formulaire',
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontWeight: FontWeight.w600,
                  fontSize: AppConstants.fontSizeLarge,
                  height: 24 / 16,
                  letterSpacing: 0,
                  color: AppColors.whiteOpacity(0.7),
                ),
              ),
            ),
            // Cartes de formulaires
            Positioned(
              top: 197,
              left: AppConstants.paddingXLarge,
              right: AppConstants.paddingXLarge,
              child: Column(
                children: [
                  // Card 1
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCard = selectedCard == 0 ? null : 0;
                      });
                    },
                    child: Container(
                      width: 382,
                      height: 78,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      decoration: BoxDecoration(
                        color: selectedCard == 0 ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        border: Border.all(color: AppColors.whiteOverlay),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: AppConstants.elevationHigh,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/logo (1).svg',
                            width: AppConstants.cardIconSize,
                            height: AppConstants.cardIconSize,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Demande de transfert',
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamilySofiaSans,
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppConstants.fontSizeXLarge,
                                    height: 24 / 18,
                                    letterSpacing: 0,
                                    color: selectedCard == 0 ? AppColors.white : AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  'Délai traitement 24h',
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamilySofiaSans,
                                    fontWeight: FontWeight.w400,
                                    fontSize: AppConstants.fontSizeRegular,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: selectedCard == 0 ? AppColors.whiteOpacity(0.8) : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          selectedCard == 0
                              ? Container(
                                  width: AppConstants.iconSizeLarge,
                                  height: AppConstants.iconSizeLarge,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: AppConstants.iconSizeSmall,
                                    color: AppColors.primary,
                                  ),
                                )
                              : SvgPicture.asset(
                                  'assets/icons/Vector (17).svg',
                                  width: AppConstants.iconSizeLarge,
                                  height: AppConstants.iconSizeLarge,
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Card 2
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCard = selectedCard == 1 ? null : 1;
                      });
                    },
                    child: Container(
                      width: 382,
                      height: 78,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      decoration: BoxDecoration(
                        color: selectedCard == 1 ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        border: Border.all(color: AppColors.whiteOverlay),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: AppConstants.elevationHigh,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/logo.svg',
                            width: AppConstants.cardIconSize,
                            height: AppConstants.cardIconSize,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Ouverture de compte',
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamilySofiaSans,
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppConstants.fontSizeXLarge,
                                    height: 24 / 18,
                                    letterSpacing: 0,
                                    color: selectedCard == 1 ? AppColors.white : AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  'Délai traitement 24h',
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamilySofiaSans,
                                    fontWeight: FontWeight.w400,
                                    fontSize: AppConstants.fontSizeRegular,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: selectedCard == 1 ? AppColors.whiteOpacity(0.8) : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          selectedCard == 1
                              ? Container(
                                  width: AppConstants.iconSizeLarge,
                                  height: AppConstants.iconSizeLarge,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: AppConstants.iconSizeSmall,
                                    color: AppColors.primary,
                                  ),
                                )
                              : SvgPicture.asset(
                                  'assets/icons/Vector (17).svg',
                                  width: AppConstants.iconSizeLarge,
                                  height: AppConstants.iconSizeLarge,
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Card 3
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCard = selectedCard == 2 ? null : 2;
                      });
                    },
                    child: Container(
                      width: 382,
                      height: 78,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      decoration: BoxDecoration(
                        color: selectedCard == 2 ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        border: Border.all(color: AppColors.whiteOverlay),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: AppConstants.elevationHigh,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/logo (2).svg',
                            width: AppConstants.cardIconSize,
                            height: AppConstants.cardIconSize,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Demande de prêt',
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamilySofiaSans,
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppConstants.fontSizeXLarge,
                                    height: 24 / 18,
                                    letterSpacing: 0,
                                    color: selectedCard == 2 ? AppColors.white : AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  'Délai traitement 24h',
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamilySofiaSans,
                                    fontWeight: FontWeight.w400,
                                    fontSize: AppConstants.fontSizeRegular,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: selectedCard == 2 ? AppColors.whiteOpacity(0.8) : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          selectedCard == 2
                              ? Container(
                                  width: AppConstants.iconSizeLarge,
                                  height: AppConstants.iconSizeLarge,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: AppConstants.iconSizeSmall,
                                    color: AppColors.primary,
                                  ),
                                )
                              : SvgPicture.asset(
                                  'assets/icons/Vector (17).svg',
                                  width: AppConstants.iconSizeLarge,
                                  height: AppConstants.iconSizeLarge,
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Card 4
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCard = selectedCard == 3 ? null : 3;
                      });
                    },
                    child: Container(
                      width: 382,
                      height: 78,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      decoration: BoxDecoration(
                        color: selectedCard == 3 ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        border: Border.all(color: AppColors.whiteOverlay),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: AppConstants.elevationHigh,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/logo (3).svg',
                            width: AppConstants.cardIconSize,
                            height: AppConstants.cardIconSize,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Opposition de cartes',
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamilySofiaSans,
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppConstants.fontSizeXLarge,
                                    height: 24 / 18,
                                    letterSpacing: 0,
                                    color: selectedCard == 3 ? AppColors.white : AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  'Délai traitement 24h',
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamilySofiaSans,
                                    fontWeight: FontWeight.w400,
                                    fontSize: AppConstants.fontSizeRegular,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: selectedCard == 3 ? AppColors.whiteOpacity(0.8) : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          selectedCard == 3
                              ? Container(
                                  width: AppConstants.iconSizeLarge,
                                  height: AppConstants.iconSizeLarge,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: AppConstants.iconSizeSmall,
                                    color: AppColors.primary,
                                  ),
                                )
                              : SvgPicture.asset(
                                  'assets/icons/Vector (17).svg',
                                  width: AppConstants.iconSizeLarge,
                                  height: AppConstants.iconSizeLarge,
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bouton Continuer
            Positioned(
              bottom: 40,
              left: AppConstants.paddingXLarge,
              right: AppConstants.paddingXLarge,
              child: Container(
                width: 382,
                height: AppConstants.buttonHeight,
                decoration: BoxDecoration(
                  color: selectedCard != null ? AppColors.primary : AppColors.primaryDarker,
                  borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                ),
                child: Center(
                  child: GestureDetector(
                    onTap: selectedCard != null ? () {
                      Navigator.pushNamed(context, AppRoutes.clientMethode);
                    } : null,
                    child: Text(
                      'Continuer',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontWeight: FontWeight.w600,
                        fontSize: AppConstants.fontSizeLarge,
                        color: selectedCard != null ? AppColors.white : AppColors.textLightGray,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
