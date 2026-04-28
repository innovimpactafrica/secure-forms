import 'package:flutter/material.dart';
import 'package:secure_link/utils/responsive_utils.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';

class ResponsiveModal extends StatelessWidget {
  final Widget child;
  final double height;
  final bool hasHandle;
  final EdgeInsets? margin;

  const ResponsiveModal({
    super.key,
    required this.child,
    required this.height,
    this.hasHandle = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ResponsiveUtils.getResponsiveHeight(context, height),
      margin: margin ?? EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveWidth(context, 8),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveValue(context, AppConstants.fontSizeTitle),
        ),
      ),
      child: Stack(
        children: [
          if (hasHandle)
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 12),
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: ResponsiveUtils.getResponsiveWidth(context, AppConstants.modalHandleWidth),
                  height: ResponsiveUtils.getResponsiveHeight(context, AppConstants.modalHandleHeight),
                  decoration: BoxDecoration(
                    color: AppColors.modalHandle,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveValue(context, 999),
                    ),
                  ),
                ),
              ),
            ),
          Positioned.fill(
            top: hasHandle ? ResponsiveUtils.getResponsiveHeight(context, 24) : 0,
            child: child,
          ),
        ],
      ),
    );
  }
}

class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;

  const ResponsiveButton({
    super.key,
    required this.text,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 44,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width != null ? ResponsiveUtils.getResponsiveWidth(context, width!) : null,
        height: ResponsiveUtils.getResponsiveHeight(context, height),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveValue(context, borderRadius),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: AppConstants.fontFamilyInter,
              fontWeight: FontWeight.w500,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, AppConstants.fontSizeLarge),
              color: textColor ?? AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
