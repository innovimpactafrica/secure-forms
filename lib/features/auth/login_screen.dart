import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import '../../utils/responsive_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SizedBox(
        width: ResponsiveUtils.getScreenWidth(context),
        height: ResponsiveUtils.getScreenHeight(context),
        child: Stack(
          children: [
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 50),
              left: ResponsiveUtils.getResponsiveWidth(context, 24),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: ResponsiveUtils.getResponsiveWidth(context, 44),
                  height: ResponsiveUtils.getResponsiveHeight(context, 44),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, 22)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowDark,
                        blurRadius: ResponsiveUtils.getResponsiveValue(context, 32),
                        offset: Offset(ResponsiveUtils.getResponsiveValue(context, -3), ResponsiveUtils.getResponsiveValue(context, -3)),
                      ),
                      BoxShadow(
                        color: AppColors.shadowDark,
                        blurRadius: ResponsiveUtils.getResponsiveValue(context, 32),
                        offset: Offset(ResponsiveUtils.getResponsiveValue(context, 3), ResponsiveUtils.getResponsiveValue(context, 3)),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveUtils.getResponsiveValue(context, 7.54)),
                    child: SvgPicture.asset(
                      'assets/icons/arrow-left.svg',
                      width: ResponsiveUtils.getResponsiveWidth(context, 30.17),
                      height: ResponsiveUtils.getResponsiveHeight(context, 30.17),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 56),
              right: ResponsiveUtils.getResponsiveWidth(context, 24),
              child: Image.asset(
                'assets/images/securelink.png',
                width: ResponsiveUtils.getResponsiveWidth(context, 131),
                height: ResponsiveUtils.getResponsiveHeight(context, 32),
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 150),
              left: ResponsiveUtils.getResponsiveWidth(context, 24),
              right: ResponsiveUtils.getResponsiveWidth(context, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Numéro de téléphone',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamilySofiaSans,
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
                      height: 32 / 24,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 16)),
                  Text(
                    'Veuillez saisir votre numéro de téléphone.\nNous vous enverrons un code pour nous assurer que c\'est bien vous.',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamilySofiaSans,
                      fontWeight: FontWeight.w400,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                      height: 24 / 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 24)),
                  Container(
                    width: double.infinity,
                    height: ResponsiveUtils.getResponsiveHeight(context, 54),
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getResponsiveWidth(context, 20),
                      vertical: ResponsiveUtils.getResponsiveHeight(context, 15),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, 100)),
                      border: Border.all(color: AppColors.borderGray),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: ResponsiveUtils.getResponsiveWidth(context, 24),
                          height: ResponsiveUtils.getResponsiveHeight(context, 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, 12)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, 12)),
                            child: Image.asset(
                              'assets/images/flag_sn-1x1.png',
                              width: ResponsiveUtils.getResponsiveWidth(context, 24),
                              height: ResponsiveUtils.getResponsiveHeight(context, 24),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 8)),
                        SvgPicture.asset(
                          'assets/icons/mdi-light_chevron-down.svg',
                          width: ResponsiveUtils.getResponsiveWidth(context, 20),
                          height: ResponsiveUtils.getResponsiveHeight(context, 20),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 8)),
                        Container(
                          width: ResponsiveUtils.getResponsiveWidth(context, 1),
                          height: ResponsiveUtils.getResponsiveHeight(context, 16),
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, 100)),
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 8)),
                        Text(
                          '+221',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontWeight: FontWeight.w400,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                            color: AppColors.textMediumGray,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 12)),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: '77 123 45 67',
                              hintStyle: TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontWeight: FontWeight.w400,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                                color: AppColors.hintText,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilyInter,
                              fontWeight: FontWeight.w400,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                              color: AppColors.textMediumGray,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: ResponsiveUtils.getResponsiveHeight(context, 170),
              left: ResponsiveUtils.getResponsiveWidth(context, 24),
              right: ResponsiveUtils.getResponsiveWidth(context, 24),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilySofiaSans,
                    fontWeight: FontWeight.w400,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'En continuant, vous confirmez avoir lu et accepté les '),
                    TextSpan(
                      text: 'conditions générales',
                      style: TextStyle(
                        color: AppColors.textBlack,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' et la '),
                    TextSpan(
                      text: 'politique de confidentialité.',
                      style: TextStyle(
                        color: AppColors.textBlack,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: ResponsiveUtils.getResponsiveHeight(context, 80),
              left: ResponsiveUtils.getResponsiveWidth(context, 24),
              right: ResponsiveUtils.getResponsiveWidth(context, 24),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.otpVerification);
                },
                child: Container(
                  height: ResponsiveUtils.getResponsiveHeight(context, 64),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                  ),
                  child: Center(
                    child: Text(
                      'Suivant',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        fontWeight: FontWeight.w500,
                        fontSize: AppConstants.fontSizeXLarge,
                        color: AppColors.white,
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

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
