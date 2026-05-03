import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quick_forms/core/utils/app_routes.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';

class NouvelleDemandeStep9Screen extends StatefulWidget {
  const NouvelleDemandeStep9Screen({super.key});

  @override
  State<NouvelleDemandeStep9Screen> createState() =>
      _NouvelleDemandeStep9ScreenState();
}

class _NouvelleDemandeStep9ScreenState
    extends State<NouvelleDemandeStep9Screen> {
  void _showSuccessModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => Container(
        width: 342,
        margin: EdgeInsets.all(AppConstants.paddingXLarge),
        padding: EdgeInsets.all(AppConstants.paddingXLarge),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône de validation
            SvgPicture.asset(
              'assets/icons/Vector (19).svg',
              width: 70,
              height: 70,
            ),
            SizedBox(height: AppConstants.paddingLarge),
            // Titre
            Text(
              'Demande envoyé',
              style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontWeight: FontWeight.w600,
                fontSize: AppConstants.fontSizeXLarge,
                color: AppColors.textBlack,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppConstants.paddingSmall),
            // Message de confirmation
            Text(
              'Votre demande a été envoyé avec succès',
              style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontWeight: FontWeight.w400,
                fontSize: AppConstants.fontSizeLarge,
                height: 32 / 16,
                letterSpacing: 0,
                color: AppColors.textGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Redirection après 1.5 secondes
    final navigator = Navigator.of(context);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      navigator.pop(); // Fermer la modal
      navigator.pushReplacementNamed(AppRoutes.clientDemandes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.white,
                      size: 21.4,
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
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusRound),
                    ),
                  ),
                  Container(
                    width: AppConstants.progressBarWidth,
                    height: AppConstants.progressBarHeight,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusRound),
                    ),
                  ),
                ],
              ),
            ),
            // Indicateur 5/5
            Positioned(
              top: 135.6,
              left: 354,
              child: Text(
                '5/5',
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
            // Icône de validation
            Positioned(
              top: 200,
              left: 180,
              child: SvgPicture.asset(
                'assets/icons/Vector (19).svg',
                width: 70,
                height: 70,
              ),
            ),
            // Titre "Prêt à soumettre ?"
            Positioned(
              top: 290,
              left: (430 - 177) / 2,
              child: Text(
                'Prêt à soumettre ?',
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontWeight: FontWeight.w600,
                  fontSize: AppConstants.fontSizeXXLarge,
                  height: 1.3,
                  letterSpacing: 0,
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Description
            Positioned(
              top: 330,
              left: AppConstants.paddingXLarge,
              right: AppConstants.paddingXLarge,
              child: Text(
                'Veuillez vérifier votre demande. Une fois soumise, vous recevrez un courriel de confirmation.',
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontWeight: FontWeight.w400,
                  fontSize: AppConstants.fontSizeMedium,
                  height: 24 / 14,
                  letterSpacing: 0,
                  color: AppColors.borderLight,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Container de récapitulatif
            Positioned(
              top: 413,
              left: AppConstants.paddingXLarge,
              right: AppConstants.paddingXLarge,
              child: Container(
                height: 142.404052734375,
                padding: EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  color: AppColors.cardBackground,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Ligne Formulaire
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Formulaire',
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            height: 1.0,
                            letterSpacing: 0,
                            color: const Color(0x80030319),
                          ),
                        ),
                        Text(
                          'Ouverture de compte',
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            height: 1.0,
                            letterSpacing: 0,
                            color: const Color(0xFF333333),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                    // Ligne Montant
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Montant',
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            height: 1.0,
                            letterSpacing: 0,
                            color: const Color(0x80030319),
                          ),
                        ),
                        Text(
                          '150 000 F CFA',
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            height: 1.0,
                            letterSpacing: 0,
                            color: const Color(0xFF333333),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                    // Ligne Documents
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Documents',
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            height: 1.0,
                            letterSpacing: 0,
                            color: const Color(0x80030319),
                          ),
                        ),
                        Text(
                          '2 fichiers joints',
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            height: 1.0,
                            letterSpacing: 0,
                            color: const Color(0xFF333333),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Bouton Soumettre
            Positioned(
              top: 780,
              left: AppConstants.paddingXLarge,
              right: AppConstants.paddingXLarge,
              child: GestureDetector(
                onTap: () {
                  _showSuccessModal(context);
                },
                child: Container(
                  width: 382,
                  height: AppConstants.buttonHeight,
                  padding: EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusRound),
                  ),
                  child: Center(
                    child: Text(
                      'Soumettre',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        fontWeight: FontWeight.w500,
                        fontSize: AppConstants.fontSizeLarge,
                        height: 1.5,
                        letterSpacing: 0,
                        color: AppColors.white,
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
    );
  }
}
