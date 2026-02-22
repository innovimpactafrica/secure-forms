import 'package:flutter/material.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import '../../../../utils/responsive_utils.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: ResponsiveUtils.getScreenWidth(context),
        height: ResponsiveUtils.getScreenHeight(context),
        child: Stack(
          children: [
            Container(
              width: ResponsiveUtils.getScreenWidth(context),
              height: ResponsiveUtils.getScreenHeight(context),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/f681350a809b550bf671bd4da879c2555620dd3b.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width: ResponsiveUtils.getScreenWidth(context),
              height: ResponsiveUtils.getScreenHeight(context),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: ResponsiveUtils.getResponsiveHeight(context, 80),
              left: ResponsiveUtils.getResponsiveWidth(context, 12),
              right: ResponsiveUtils.getResponsiveWidth(context, 12),
              child: Column(
                children: [
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveWidth(context, 406),
                    height: ResponsiveUtils.getResponsiveHeight(context, 38),
                    child: Text(
                      'SECURELINK',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        fontWeight: FontWeight.w700,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 32),
                        height: 1.0,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 16)),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveWidth(context, 406),
                    height: ResponsiveUtils.getResponsiveHeight(context, 56),
                    child: Text(
                      'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        fontWeight: FontWeight.w400,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                        height: 28 / 18,
                        color: AppColors.whiteOpacity(0.7),
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 32)),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                    },
                    child: Container(
                      width: ResponsiveUtils.getResponsiveWidth(context, 382),
                      height: ResponsiveUtils.getResponsiveHeight(context, 64),
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getResponsiveWidth(context, 24),
                        vertical: ResponsiveUtils.getResponsiveHeight(context, 16),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                      ),
                      child: Center(
                        child: Text(
                          'Commencer',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontWeight: FontWeight.w500,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                            height: 1.0,
                            color: AppColors.white,
                          ),
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
    );
  }
}
