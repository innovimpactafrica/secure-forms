import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';

class NouvelleDemandeStep8Screen extends StatelessWidget {
  const NouvelleDemandeStep8Screen({super.key});

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
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
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
                      borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                    ),
                  ),
                  Container(
                    width: 256,
                    height: AppConstants.progressBarHeight,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                    ),
                  ),
                ],
              ),
            ),
            // Indicateur 4/5
            Positioned(
              top: 135.6,
              left: 354,
              child: Text(
                '4/5',
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
            // Container d'information
            Positioned(
              top: 175,
              left: AppConstants.paddingXLarge,
              right: AppConstants.paddingXLarge,
              child: Container(
                height: 64,
                padding: EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFD17C00),
                    width: AppConstants.borderWidthThin,
                  ),
                  color: const Color(0x14FFFAF1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Formats acceptés : PDF, JPG, PNG — Taille max : 5 Mo par document',
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          height: 20 / 13,
                          letterSpacing: 0,
                          color: const Color(0xFFF29900),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Titre "Téléverser des documents"
            Positioned(
              top: 265,
              left: AppConstants.paddingXLarge,
              child: Text(
                'Téléverser des documents',
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
            // Container principal des documents
            Positioned(
              top: 310,
              left: AppConstants.paddingXLarge,
              right: AppConstants.paddingXLarge,
              child: Container(
                height: 271.33331298828125,
                padding: EdgeInsets.fromLTRB(AppConstants.paddingLarge, AppConstants.paddingXLarge, AppConstants.paddingLarge, AppConstants.paddingXLarge),
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
                      blurRadius: 3,
                      offset: const Offset(3, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                    // Container avec bordure en pointillés
                    Container(
                      width: 350,
                      height: 131.3333282470703,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF23A3A6),
                          width: 1,
                        ),
                        color: const Color(0x0A23A3A6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ligne avec icône et texte
                          Row(
                            children: [
                              // Icône id-card-alt
                              SvgPicture.asset(
                                'assets/icons/id-card-alt.svg',
                                width: 24,
                                height: 21.33333396911621,
                              ),
                              const SizedBox(width: 12),
                              // Texte
                              Text(
                                'Pièce d\'identité (obligatoire)',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  height: 1.0,
                                  letterSpacing: 0,
                                  color: const Color(0xFF343A40),
                                ),
                              ),
                              const Spacer(),
                              // Icône Vector
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF23A3A6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Container blanc
                          Container(
                            width: 318,
                            height: 50,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      // Image img (4).png
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(3.56),
                                          border: Border.all(
                                            color: const Color(0x0D000000),
                                            width: 0.17,
                                          ),
                                          color: const Color(0x33000000),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(3.56),
                                          child: Image.asset(
                                            'assets/images/img (4).png',
                                            width: 32,
                                            height: 32,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Texte cni.png
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'cni.png',
                                              style: TextStyle(
                                                fontFamily: 'Work Sans',
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                height: 1.0,
                                                letterSpacing: 0,
                                                color: const Color(0xFF343A40),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '20KO',
                                              style: TextStyle(
                                                fontFamily: 'Work Sans',
                                                fontWeight: FontWeight.w300,
                                                fontSize: 12,
                                                height: 1.0,
                                                letterSpacing: 0,
                                                color: const Color(0xFF95A5A6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Icône poubelle
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/icons/iconamoon_trash.svg',
                                      width: 16,
                                      height: 16,
                                      colorFilter: ColorFilter.mode(
                                        const Color(0xFFF44336),
                                        BlendMode.srcIn,
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
                    const SizedBox(height: 16),
                    // Nouveau container avec bordure en pointillés
                    Container(
                      width: 350,
                      height: 68,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFCBD5E1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                // Icône list-solid
                                SvgPicture.asset(
                                  'assets/icons/list-solid.svg',
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 8),
                                // Texte
                                Expanded(
                                  child: Text(
                                    'Preuve de transaction (facultatif)',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      height: 1.0,
                                      letterSpacing: 0,
                                      color: const Color(0xFF343A40),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Icône btn-primary à droite
                          SvgPicture.asset(
                            'assets/icons/btn-primary.svg',
                            width: 24,
                            height: 24,
                          ),
                        ],
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            ),
            // Bouton Continuer
            Positioned(
              top: 780,
              left: AppConstants.paddingXLarge,
              right: AppConstants.paddingXLarge,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/nouvelle-demande-step-9');
                },
                child: Container(
                  width: 382,
                  height: AppConstants.buttonHeight,
                  padding: EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                  ),
                  child: Center(
                    child: Text(
                      'Continuer',
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