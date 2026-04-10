import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/utils/responsive_utils.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';

class ResponsiveMenuItem extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;
  final String? trailingText;
  final bool showChevron;

  const ResponsiveMenuItem({
    super.key,
    required this.title,
    required this.iconPath,
    required this.onTap,
    this.trailingText,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveUtils.getResponsiveHeight(context, AppConstants.paddingLarge),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: ResponsiveUtils.getResponsiveWidth(context, AppConstants.iconSizeLarge),
              height: ResponsiveUtils.getResponsiveHeight(context, AppConstants.iconSizeLarge),
              colorFilter: ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, AppConstants.paddingLarge)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontWeight: FontWeight.w500,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, AppConstants.fontSizeLarge),
                  color: AppColors.profileText,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontWeight: FontWeight.w400,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, AppConstants.fontSizeMedium),
                  color: AppColors.iconGray,
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, AppConstants.paddingSmall)),
            ],
            if (showChevron)
              Icon(
                Icons.chevron_right,
                color: AppColors.iconGray,
                size: ResponsiveUtils.getResponsiveValue(context, AppConstants.iconSizeMedium),
              ),
          ],
        ),
      ),
    );
  }
}