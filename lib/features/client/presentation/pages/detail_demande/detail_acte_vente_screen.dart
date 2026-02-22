import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';

class DetailActeVenteScreen extends StatelessWidget {
  const DetailActeVenteScreen({super.key});

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
                  Positioned(
                    top: 70,
                    left: AppConstants.paddingXLarge,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
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
                  Positioned(
                    top: 78,
                    left: 90,
                    child: Text(
                      'Acte de vente',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: AppConstants.fontSizeXXLarge,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 102,
                    left: 90,
                    child: Text(
                      'Notaire X • 05/12/2025',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: AppConstants.fontSizeRegular,
                        color: AppColors.whiteOpacity(0.6),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 78,
                    right: AppConstants.paddingXLarge,
                    child: Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.statusInProgress,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Center(
                        child: Text(
                          'En cours',
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
                          Row(
                            children: [
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
                              Expanded(
                                child: Container(
                                  height: AppConstants.progressLineHeight,
                                  margin: EdgeInsets.only(bottom: 32),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                                  ),
                                ),
                              ),
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
                                        'assets/icons/bi_clock-history.svg',
                                        width: AppConstants.iconSizeMedium,
                                        height: AppConstants.iconSizeMedium,
                                        colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
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
                            offset: Offset(3, 3),
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
                                    width: AppConstants.cardIconSize,
                                    height: AppConstants.cardIconSize,
                                    decoration: BoxDecoration(
                                      color: AppColors.grayLight,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/earmark-text.svg',
                                        width: AppConstants.iconSizeLarge,
                                        height: AppConstants.iconSizeLarge,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: AppConstants.paddingMedium),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(bottom: AppConstants.paddingSmall),
                                        child: Text(
                                          'Acte de vente',
                                          style: TextStyle(
                                            fontFamily: AppConstants.fontFamilyInter,
                                            fontWeight: FontWeight.w600,
                                            fontSize: AppConstants.fontSizeMedium,
                                            height: 1.0,
                                            letterSpacing: 0.03,
                                            color: AppColors.textDarkGray,
                                          ),
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: Offset(0, -2),
                                        child: Text(
                                          'Version 1.1',
                                          style: TextStyle(
                                            fontFamily: AppConstants.fontFamilyInter,
                                            fontWeight: FontWeight.w400,
                                            fontSize: AppConstants.fontSizeRegular,
                                            height: 1.0,
                                            letterSpacing: 0.03,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SvgPicture.asset(
                                'assets/icons/Group (2).svg',
                                width: AppConstants.iconSizeLarge,
                                height: AppConstants.iconSizeLarge,
                              ),
                            ],
                          ),
                          SizedBox(height: AppConstants.paddingXLarge),
                          Container(
                            width: 350,
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              border: Border.all(color: AppColors.borderLight, width: AppConstants.borderWidthThin),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
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
                  Positioned(
                    top: 620,
                    left: AppConstants.paddingXLarge,
                    child: Text(
                      'Documents justificatifs',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontWeight: FontWeight.w600,
                        fontSize: AppConstants.fontSizeXXLarge,
                        height: 24 / 20,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 660,
                    left: AppConstants.paddingXLarge,
                    right: AppConstants.paddingXLarge,
                    child: Container(
                      width: 382,
                      height: 172,
                      padding: EdgeInsets.all(AppConstants.paddingLarge),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: AppConstants.cardIconSize,
                                  height: AppConstants.cardIconSize,
                                  decoration: BoxDecoration(
                                    color: AppColors.grayLight,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/icons/earmark-text.svg',
                                      width: AppConstants.iconSizeLarge,
                                      height: AppConstants.iconSizeLarge,
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppConstants.paddingMedium),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Carte d\'identité',
                                      style: TextStyle(
                                        fontFamily: AppConstants.fontFamilyInter,
                                        fontWeight: FontWeight.w600,
                                        fontSize: AppConstants.fontSizeMedium,
                                        height: 1.0,
                                        letterSpacing: 0.03,
                                        color: AppColors.textDarkGray,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '210 ko',
                                      style: TextStyle(
                                        fontFamily: AppConstants.fontFamilyInter,
                                        fontWeight: FontWeight.w400,
                                        fontSize: AppConstants.fontSizeRegular,
                                        height: 1.0,
                                        letterSpacing: 0.03,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Container(
                                  width: 53,
                                  height: 23,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryOverlay,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Vérifié',
                                      style: TextStyle(
                                        fontFamily: AppConstants.fontFamilyInter,
                                        fontWeight: FontWeight.w500,
                                        fontSize: AppConstants.fontSizeRegular,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: AppColors.borderDivider,
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: AppConstants.cardIconSize,
                                  height: AppConstants.cardIconSize,
                                  decoration: BoxDecoration(
                                    color: AppColors.grayLight,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/icons/earmark-text.svg',
                                      width: AppConstants.iconSizeLarge,
                                      height: AppConstants.iconSizeLarge,
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppConstants.paddingMedium),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Preuve de résidence',
                                      style: TextStyle(
                                        fontFamily: AppConstants.fontFamilyInter,
                                        fontWeight: FontWeight.w600,
                                        fontSize: AppConstants.fontSizeMedium,
                                        height: 1.0,
                                        letterSpacing: 0.03,
                                        color: AppColors.textDarkGray,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '404 ko',
                                      style: TextStyle(
                                        fontFamily: AppConstants.fontFamilyInter,
                                        fontWeight: FontWeight.w400,
                                        fontSize: AppConstants.fontSizeRegular,
                                        height: 1.0,
                                        letterSpacing: 0.03,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Container(
                                  width: 53,
                                  height: 23,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryOverlay,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Vérifié',
                                      style: TextStyle(
                                        fontFamily: AppConstants.fontFamilyInter,
                                        fontWeight: FontWeight.w500,
                                        fontSize: AppConstants.fontSizeRegular,
                                        color: AppColors.primary,
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
                  Positioned(
                    top: 860,
                    left: AppConstants.paddingXLarge,
                    right: AppConstants.paddingXLarge,
                    child: Container(
                      width: 382,
                      height: AppConstants.buttonHeightLarge,
                      padding: EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDarker,
                        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/Group (1).svg',
                            width: AppConstants.iconSizeLarge,
                            height: AppConstants.iconSizeLarge,
                            colorFilter: ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
                          ),
                          SizedBox(width: AppConstants.paddingSmall),
                          Text(
                            'Télécharger le PDF',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilySofiaSans,
                              fontWeight: FontWeight.w500,
                              fontSize: AppConstants.fontSizeXLarge,
                              height: 1.5,
                              color: AppColors.textSecondary,
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
