import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/responsive_utils.dart';
import '../core/utils/app_colors.dart';
import '../core/utils/app_constants.dart';

class ResponsiveStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String iconPath;
  final Color? iconColor;

  const ResponsiveStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.iconPath,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = (ResponsiveUtils.getScreenWidth(context) - 
        ResponsiveUtils.getResponsiveWidth(context, 48) - 
        ResponsiveUtils.getResponsiveWidth(context, 16)) / 2;

    return Container(
      width: cardWidth,
      height: ResponsiveUtils.getResponsiveHeight(context, AppConstants.profileCardHeight),
      padding: EdgeInsets.fromLTRB(
        ResponsiveUtils.getResponsiveWidth(context, AppConstants.paddingMedium),
        ResponsiveUtils.getResponsiveHeight(context, AppConstants.paddingLarge),
        ResponsiveUtils.getResponsiveWidth(context, AppConstants.paddingMedium),
        ResponsiveUtils.getResponsiveHeight(context, AppConstants.paddingLarge),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveValue(context, AppConstants.radiusSmall),
        ),
        border: Border.all(
          color: AppColors.border,
          width: ResponsiveUtils.getResponsiveValue(context, AppConstants.borderWidthThin),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            offset: Offset(
              ResponsiveUtils.getResponsiveValue(context, 3),
              ResponsiveUtils.getResponsiveValue(context, 3),
            ),
            blurRadius: ResponsiveUtils.getResponsiveValue(context, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilySofiaSans,
                    fontWeight: FontWeight.w500,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, AppConstants.fontSizeRegular),
                    height: 1.0,
                    letterSpacing: 0,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 4)),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilySofiaSans,
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, AppConstants.fontSizeXXLarge),
                    height: 1.2,
                    letterSpacing: 0,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset(
            iconPath,
            width: ResponsiveUtils.getResponsiveWidth(context, 32),
            height: ResponsiveUtils.getResponsiveHeight(context, 32),
            colorFilter: iconColor != null
                ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                : null,
          ),
        ],
      ),
    );
  }
}