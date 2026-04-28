import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';

class DetailVirementScreen extends StatelessWidget {
  const DetailVirementScreen({super.key});

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
                  // Titre "Demande de virement"
                  Positioned(
                    top: 78,
                    left: 90,
                    child: Text(
                      'Demande de virement',
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
                      'Banque Nationale • 04/11/2025',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: AppConstants.fontSizeRegular,
                        color: AppColors.whiteOpacity(0.6),
                      ),
                    ),
                  ),
                  // Badge "En attente"
                  Positioned(
                    top: 78,
                    right: AppConstants.paddingXLarge,
                    child: Container(
                      width: 65,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.statusPending,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Center(
                        child: Text(
                          'En attente',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontWeight: FontWeight.w500,
                            fontSize: AppConstants.fontSizeSmall,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Container blanc en bas du header
                  Positioned(
                    top: 150,
                    left: AppConstants.paddingXLarge,
                    right: AppConstants.paddingXLarge,
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
                            'REQ-2024-001',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilyInter,
                              fontWeight: FontWeight.w600,
                              fontSize: AppConstants.fontSizeMedium,
                              height: 1.0,
                              letterSpacing: 0.03,
                              color: AppColors.textDarkGray,
                            ),
                          ),
                          const SizedBox(height: 4),
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
                              // Étape 1: Soumis
                              Column(
                                children: [
                                  Container(
                                    width: AppConstants.progressStepSize,
                                    height: AppConstants.progressStepSize,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/bi_pencil (1).svg',
                                        width: AppConstants.iconSizeMedium,
                                        height: AppConstants.iconSizeMedium,
                                        colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: AppConstants.paddingSmall),
                                  Text(
                                    'Soumis',
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
                                  margin: const EdgeInsets.only(bottom: 32),
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
                                        colorFilter: ColorFilter.mode(AppColors.textLight, BlendMode.srcIn),
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
                                  margin: const EdgeInsets.only(bottom: 32),
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
                                        colorFilter: ColorFilter.mode(AppColors.textLight, BlendMode.srcIn),
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
                  // Deuxième container
                  Positioned(
                    top: 320,
                    left: AppConstants.paddingXLarge,
                    right: AppConstants.paddingXLarge,
                    child: Container(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F0F0),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/earmark-text.svg',
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          'Acte de vente',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            height: 1.0,
                                            letterSpacing: 0.03,
                                            color: const Color(0xFF1F2937),
                                          ),
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: const Offset(0, -2),
                                        child: Text(
                                          'Version 1.1',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            height: 1.0,
                                            letterSpacing: 0.03,
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SvgPicture.asset(
                                'assets/icons/Group (2).svg',
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: 350,
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFDEE8EE), width: 1),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/field.png',
                                width: 350,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Texte "Documents justificatifs"
                  Positioned(
                    top: 620,
                    left: 24,
                    child: Text(
                      'Documents justificatifs',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        height: 24 / 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Container documents
                  Positioned(
                    top: 660,
                    left: 24,
                    right: 24,
                    child: Container(
                      width: 382,
                      height: 172,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Partie haute du container
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F0F0),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/icons/earmark-text.svg',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Carte d\'identité',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        height: 1.0,
                                        letterSpacing: 0.03,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '210 ko',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        height: 1.0,
                                        letterSpacing: 0.03,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  width: 53,
                                  height: 23,
                                  decoration: BoxDecoration(
                                    color: const Color(0x0F23A3A6),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Vérifié',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: const Color(0xFF23A3A6),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Ligne de séparation
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: const Color(0xFFE5E7EB),
                          ),
                          // Partie basse du container
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F0F0),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/icons/earmark-text.svg',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Preuve de résidence',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        height: 1.0,
                                        letterSpacing: 0.03,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '404 ko',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        height: 1.0,
                                        letterSpacing: 0.03,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  width: 53,
                                  height: 23,
                                  decoration: BoxDecoration(
                                    color: const Color(0x0F23A3A6),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Vérifié',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: const Color(0xFF23A3A6),
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
                  ),
                  // Bouton
                  Positioned(
                    top: 860,
                    left: 24,
                    right: 24,
                    child: Container(
                      width: 382,
                      height: 64,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A324A),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/Group (1).svg',
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(Color(0xFF6B7280), BlendMode.srcIn),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Télécharger le PDF',
                            style: TextStyle(
                              fontFamily: 'Sofia Sans',
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              height: 1.5,
                              color: const Color(0xFF6B7280),
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
