import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';

class ClientMethodeScreen extends StatefulWidget {
  const ClientMethodeScreen({super.key});

  @override
  State<ClientMethodeScreen> createState() => _ClientMethodeScreenState();
}

class _ClientMethodeScreenState extends State<ClientMethodeScreen> {
  int selectedOption = 0; // 0: aucune sélection, 1: en ligne, 2: hors ligne

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
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
                      width: 128,
                      height: AppConstants.progressBarHeight,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                      ),
                    ),
                  ],
                ),
              ),
              // Indicateur 2/5
              Positioned(
                top: 135.6,
                left: 354,
                child: Text(
                  '2/5',
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
                top: 180,
                left: AppConstants.paddingXLarge,
                child: Text(
                  'Comment souhaitez-vous remplir le formulaire ?',
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    height: 24 / 15,
                    letterSpacing: 0,
                    color: AppColors.white,
                  ),
                ),
              ),
              // Sous-titre descriptif
              Positioned(
                top: 207,
                left: AppConstants.paddingXLarge,
                child: SizedBox(
                  width: 332,
                  height: 24,
                  child: Text(
                    'Choisissez la méthode qui vous convient le mieux.',
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
              ),
              // Container principal des options
              Positioned(
                top: 255,
                left: AppConstants.paddingXLarge,
                right: AppConstants.paddingXLarge,
                child: Container(
                  height: 568,
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
                        blurRadius: AppConstants.elevationMedium,
                        offset: const Offset(3, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Card 1 - Remplir en ligne
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = 1;
                          });
                        },
                        child: Container(
                          width: 350,
                          height: 244,
                          padding: const EdgeInsets.fromLTRB(17, 20, 17, 20),
                          decoration: BoxDecoration(
                            color: selectedOption == 1 ? AppColors.primaryLight : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                            border: Border.all(
                              color: selectedOption == 1 ? AppColors.primary : AppColors.borderGray,
                              width: selectedOption == 1 ? AppConstants.borderWidthMedium : AppConstants.borderWidthThin,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icône crayon
                              Container(
                                width: AppConstants.iconSizeHuge,
                                height: AppConstants.iconSizeHuge,
                                decoration: BoxDecoration(
                                  color: AppColors.gray,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: SvgPicture.asset(
                                        'assets/icons/bi_pencil (1).svg',
                                        width: AppConstants.iconSizeSmall,
                                        height: AppConstants.iconSizeSmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppConstants.paddingLarge),
                              // Titre
                              Text(
                                'Remplir en ligne',
                                style: TextStyle(
                                  fontFamily: AppConstants.fontFamilyInter,
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppConstants.fontSizeXLarge,
                                  height: 24 / 18,
                                  letterSpacing: 0,
                                  color: AppColors.textBlack,
                                ),
                              ),
                              SizedBox(height: AppConstants.paddingSmall),
                              // Description
                              Text(
                                'Remplissez le formulaire directement dans votre navigateur grâce à notre éditeur sécurisé.',
                                style: TextStyle(
                                  fontFamily: AppConstants.fontFamilyInter,
                                  fontWeight: FontWeight.w400,
                                  fontSize: AppConstants.fontSizeRegular,
                                  height: 16 / 12,
                                  letterSpacing: 0,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: AppConstants.paddingLarge),
                              // Avantages
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/bi_check2-circle (1).svg',
                                    width: AppConstants.iconSizeSmall,
                                    height: AppConstants.iconSizeSmall,
                                  ),
                                  SizedBox(width: AppConstants.paddingSmall),
                                  Expanded(
                                    child: Text(
                                      'Expérience guidée',
                                      style: TextStyle(
                                        fontFamily: AppConstants.fontFamilyInter,
                                        fontWeight: FontWeight.w400,
                                        fontSize: AppConstants.fontSizeRegular,
                                        height: 16 / 12,
                                        letterSpacing: 0,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppConstants.paddingSmall),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/bi_check2-circle (1).svg',
                                    width: AppConstants.iconSizeSmall,
                                    height: AppConstants.iconSizeSmall,
                                  ),
                                  SizedBox(width: AppConstants.paddingSmall),
                                  Expanded(
                                    child: Text(
                                      'Sauvegarde automatique de la progression',
                                      style: TextStyle(
                                        fontFamily: AppConstants.fontFamilyInter,
                                        fontWeight: FontWeight.w400,
                                        fontSize: AppConstants.fontSizeRegular,
                                        height: 16 / 12,
                                        letterSpacing: 0,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppConstants.paddingSmall),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/bi_check2-circle (1).svg',
                                    width: AppConstants.iconSizeSmall,
                                    height: AppConstants.iconSizeSmall,
                                  ),
                                  SizedBox(width: AppConstants.paddingSmall),
                                  Expanded(
                                    child: Text(
                                      'Signature électronique instantanée',
                                      style: TextStyle(
                                        fontFamily: AppConstants.fontFamilyInter,
                                        fontWeight: FontWeight.w400,
                                        fontSize: AppConstants.fontSizeRegular,
                                        height: 16 / 12,
                                        letterSpacing: 0,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppConstants.paddingMedium),
                      // Card 2 - Télécharger hors ligne
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = 2;
                          });
                        },
                        child: Container(
                          width: 350,
                          height: 244,
                          padding: const EdgeInsets.fromLTRB(17, 20, 17, 20),
                          decoration: BoxDecoration(
                            color: selectedOption == 2 ? AppColors.primaryLight : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                            border: Border.all(
                              color: selectedOption == 2 ? AppColors.primary : AppColors.borderGray,
                              width: selectedOption == 2 ? AppConstants.borderWidthMedium : AppConstants.borderWidthThin,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icône téléchargement
                              Container(
                                width: AppConstants.iconSizeHuge,
                                height: AppConstants.iconSizeHuge,
                                decoration: BoxDecoration(
                                  color: AppColors.gray,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: SvgPicture.asset(
                                        'assets/icons/Group (1).svg',
                                        width: AppConstants.iconSizeSmall,
                                        height: AppConstants.iconSizeSmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppConstants.paddingLarge),
                              // Titre
                              Text(
                                'Téléchargez et remplissez hors ligne',
                                style: TextStyle(
                                  fontFamily: AppConstants.fontFamilyInter,
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppConstants.fontSizeMedium,
                                  height: 24 / 14,
                                  letterSpacing: 0,
                                  color: AppColors.textBlack,
                                ),
                              ),
                              SizedBox(height: AppConstants.paddingSmall),
                              // Description
                              Text(
                                'Téléchargez le PDF officiel, remplissez-le à votre rythme et téléchargez-le en toute sécurité.',
                                style: TextStyle(
                                  fontFamily: AppConstants.fontFamilyInter,
                                  fontWeight: FontWeight.w400,
                                  fontSize: AppConstants.fontSizeRegular,
                                  height: 16 / 12,
                                  letterSpacing: 0,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: AppConstants.paddingLarge),
                              // Avantages
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/bi_check2-circle (1).svg',
                                    width: AppConstants.iconSizeSmall,
                                    height: AppConstants.iconSizeSmall,
                                  ),
                                  SizedBox(width: AppConstants.paddingSmall),
                                  Expanded(
                                    child: Text(
                                      'Format PDF officiel',
                                      style: TextStyle(
                                        fontFamily: AppConstants.fontFamilyInter,
                                        fontWeight: FontWeight.w400,
                                        fontSize: AppConstants.fontSizeRegular,
                                        height: 16 / 12,
                                        letterSpacing: 0,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppConstants.paddingSmall),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/bi_check2-circle (1).svg',
                                    width: AppConstants.iconSizeSmall,
                                    height: AppConstants.iconSizeSmall,
                                  ),
                                  SizedBox(width: AppConstants.paddingSmall),
                                  Expanded(
                                    child: Text(
                                      'Remplir sans internet',
                                      style: TextStyle(
                                        fontFamily: AppConstants.fontFamilyInter,
                                        fontWeight: FontWeight.w400,
                                        fontSize: AppConstants.fontSizeRegular,
                                        height: 16 / 12,
                                        letterSpacing: 0,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppConstants.paddingSmall),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/bi_check2-circle (1).svg',
                                    width: AppConstants.iconSizeSmall,
                                    height: AppConstants.iconSizeSmall,
                                  ),
                                  SizedBox(width: AppConstants.paddingSmall),
                                  Expanded(
                                    child: Text(
                                      'Vérification OTP sécurisée',
                                      style: TextStyle(
                                        fontFamily: AppConstants.fontFamilyInter,
                                        fontWeight: FontWeight.w400,
                                        fontSize: AppConstants.fontSizeRegular,
                                        height: 16 / 12,
                                        letterSpacing: 0,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bouton Continuer
              Positioned(
                top: 850,
                left: AppConstants.paddingXLarge,
                right: AppConstants.paddingXLarge,
                child: GestureDetector(
                  onTap: selectedOption > 0 ? () {
                    if (selectedOption == 1) {
                      Navigator.pushNamed(context, AppRoutes.nouvelleDemandeStep7);
                    } else {
                      Navigator.pushNamed(context, AppRoutes.nouvelleDemandeStep8);
                    }
                  } : null,
                  child: Container(
                    height: AppConstants.buttonHeight,
                    padding: EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: selectedOption > 0 ? AppColors.primary : AppColors.primaryDarker,
                      borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                    ),
                    child: Center(
                      child: Text(
                        selectedOption == 1 ? 'Continuer' : 'Télécharger et compléter plus tard',
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilySofiaSans,
                          fontWeight: FontWeight.w500,
                          fontSize: AppConstants.fontSizeLarge,
                          height: 1.5,
                          letterSpacing: 0,
                          color: selectedOption > 0 ? AppColors.white : AppColors.textLightGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
