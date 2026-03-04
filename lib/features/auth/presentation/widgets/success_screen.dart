import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import '../../../../utils/responsive_utils.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.clientHome);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundModal,
      body: Center(
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
                  'success.title'.tr(),
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
                  'success.message'.tr(),
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
    );
  }
}
