import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import '../../../../utils/responsive_utils.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  bool _showSuccessModal = false;

  void _showSuccess() {
    setState(() {
      _showSuccessModal = true;
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.clientHome);
      }
    });
  }

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
              bottom: ResponsiveUtils.getResponsiveHeight(context, 250),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    'otp.title'.tr(),
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
                    'otp.description'.tr() + ' 77... .. 67',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamilySofiaSans,
                      fontWeight: FontWeight.w400,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                      height: 24 / 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 40)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) {
                      bool isActive = _otpControllers[index].text.isEmpty && 
                          (index == 0 || _otpControllers[index - 1].text.isNotEmpty);
                      
                      return Container(
                        width: ResponsiveUtils.getResponsiveWidth(context, 60),
                        height: ResponsiveUtils.getResponsiveHeight(context, 60),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primaryLight : AppColors.statusDraftLight,
                          borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, 12)),
                          border: isActive ? Border.all(color: AppColors.primary, width: AppConstants.borderWidthThin) : null,
                        ),
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              if (value.isNotEmpty && index < 3) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            });
                          },
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 40)),
                  Center(
                    child: Text(
                      'otp.didnt_receive'.tr(),
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        fontWeight: FontWeight.w400,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 8)),
                  Center(
                    child: Opacity(
                      opacity: 0.3,
                      child: Text(
                        'otp.resend'.tr() + ' 00:29',
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontWeight: FontWeight.w500,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                          height: 1.0,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  ],
                ),
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
                    TextSpan(text: 'login.legal_text'.tr()),
                    TextSpan(
                      text: 'login.terms'.tr(),
                      style: TextStyle(
                        color: AppColors.textBlack,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(text: 'login.and'.tr()),
                    TextSpan(
                      text: 'login.privacy'.tr(),
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
                onTap: _showSuccess,
                child: Container(
                  height: ResponsiveUtils.getResponsiveHeight(context, 64),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                  ),
                  child: Center(
                    child: Text(
                      'otp.verify_button'.tr(),
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        fontWeight: FontWeight.w500,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_showSuccessModal)
              Positioned(
                bottom: ResponsiveUtils.getResponsiveHeight(context, 50),
                left: ResponsiveUtils.getResponsiveWidth(context, 20),
                right: ResponsiveUtils.getResponsiveWidth(context, 20),
                child: Container(
                  width: ResponsiveUtils.getResponsiveWidth(context, 390),
                  height: ResponsiveUtils.getResponsiveHeight(context, 264),
                  padding: EdgeInsets.fromLTRB(
                    ResponsiveUtils.getResponsiveWidth(context, 24),
                    ResponsiveUtils.getResponsiveHeight(context, 50),
                    ResponsiveUtils.getResponsiveWidth(context, 24),
                    ResponsiveUtils.getResponsiveHeight(context, 50),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.whiteOpacity(0.2),
                        blurRadius: ResponsiveUtils.getResponsiveValue(context, 10),
                        offset: Offset(0, ResponsiveUtils.getResponsiveValue(context, 5)),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/Vector (16).svg',
                        width: ResponsiveUtils.getResponsiveWidth(context, 64),
                        height: ResponsiveUtils.getResponsiveHeight(context, 64),
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 32)),
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveWidth(context, 112),
                        height: ResponsiveUtils.getResponsiveHeight(context, 26),
                        child: Text(
                          'otp.account_created'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                            height: 1.3,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 16)),
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveWidth(context, 342),
                        height: ResponsiveUtils.getResponsiveHeight(context, 24),
                        child: Text(
                          'otp.welcome_space'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontWeight: FontWeight.w400,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                            height: 24 / 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
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
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
