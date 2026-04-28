import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';

class ClientBanquesScreen extends StatefulWidget {
  const ClientBanquesScreen({super.key});

  @override
  State<ClientBanquesScreen> createState() => _ClientBanquesScreenState();
}

class _ClientBanquesScreenState extends State<ClientBanquesScreen> {
  int selectedFilter = 0; // 0: Notaire, 1: Banque

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
              top: 102,
              left: 90,
              child: Text(
                'Choisissez une banque ou un notaire',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: AppConstants.fontSizeRegular,
                  color: AppColors.whiteOpacity(0.6),
                ),
              ),
            ),
            // Barre de progression
            Positioned(
              top: 140,
              left: AppConstants.paddingXLarge,
              child: Container(
                width: AppConstants.progressBarWidth,
                height: AppConstants.progressBarHeight,
                decoration: BoxDecoration(
                  color: AppColors.progressBar,
                  borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                ),
              ),
            ),
            // Indicateur 0/5
            Positioned(
              top: 135.6,
              left: 354,
              child: Text(
                '0/5',
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
            // Titre descriptif principal
            Positioned(
              top: 153,
              left: AppConstants.paddingXLarge,
              child: SizedBox(
                width: 382,
                height: 48,
                child: Text(
                  'Choisissez une banque ou un notaire pour entamer une demande.',
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
            ),
            // Section barre de recherche
            Positioned(
              top: 220,
              left: AppConstants.paddingXLarge,
              right: AppConstants.paddingXLarge,
              child: Container(
                height: AppConstants.searchBarHeight,
                padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.searchBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                  border: Border.all(color: AppColors.borderOverlay, width: AppConstants.borderWidthThin),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 28,
                      color: AppColors.whiteOpacity(0.6),
                    ),
                    SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: Text(
                        'Rechercher une banque, notaire....',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: AppConstants.fontSizeMedium,
                          height: 20 / 14,
                          color: AppColors.iconGray,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Filtres Notaire et Banque
            Positioned(
              top: 290,
              left: AppConstants.paddingXLarge,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.whiteOverlayLight,
                      borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                    ),
                    child: Text(
                      'Notaire',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: AppConstants.fontSizeMedium,
                        color: AppColors.whiteOpacity(0.7),
                      ),
                    ),
                  ),
                  SizedBox(width: AppConstants.paddingMedium),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.whiteOverlayLight,
                      borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                    ),
                    child: Text(
                      'Banque',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: AppConstants.fontSizeMedium,
                        color: AppColors.whiteOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Cartes d'organisations
            Positioned(
              top: 340,
              left: AppConstants.paddingXLarge,
              right: AppConstants.paddingXLarge,
              child: Column(
                children: [
                  // Première ligne - 2 cartes
                  Row(
                    children: [
                      // Card 1
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.clientFormulaires);
                          },
                          child: Container(
                            width: 183,
                            height: 162,
                            padding: EdgeInsets.fromLTRB(AppConstants.paddingMedium, AppConstants.paddingLarge, AppConstants.paddingMedium, AppConstants.paddingLarge),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              border: Border.all(color: AppColors.whiteOverlay),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadowLight,
                                  blurRadius: 48,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      'assets/images/banque nationale.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                    SvgPicture.asset(
                                      'assets/icons/Vector (17).svg',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Banque Nationale',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    height: 24 / 16,
                                    letterSpacing: 0,
                                    color: const Color(0xFF212121),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Principal partenaire bancaire pour les comptes personnel...',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Card 2
                      Expanded(
                        child: Container(
                          width: 183,
                          height: 162,
                          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x14FFFFFF)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x0F000000),
                                blurRadius: 48,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/images/notaire.png',
                                    width: 40,
                                    height: 40,
                                  ),
                                  SvgPicture.asset(
                                    'assets/icons/Vector (17).svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Étude notariale',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Sofia Sans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  height: 24 / 16,
                                  letterSpacing: 0,
                                  color: const Color(0xFF212121),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Services notariés certifiés en droit immobilier et en droit...',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Sofia Sans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  height: 1.0,
                                  letterSpacing: 0,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Deuxième ligne - 1 carte
                  Row(
                    children: [
                      // Card 3
                      Expanded(
                        child: Container(
                          width: 183,
                          height: 162,
                          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x14FFFFFF)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x0F000000),
                                blurRadius: 48,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/images/credit.png',
                                    width: 40,
                                    height: 40,
                                  ),
                                  SvgPicture.asset(
                                    'assets/icons/Vector (17).svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Crédit Moderne',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Sofia Sans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  height: 24 / 16,
                                  letterSpacing: 0,
                                  color: const Color(0xFF212121),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Spécialisé dans le crédit à la consommation et les prêts.',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Sofia Sans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  height: 1.0,
                                  letterSpacing: 0,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
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
