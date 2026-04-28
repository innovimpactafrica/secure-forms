import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getResponsiveWidth(BuildContext context, double designWidth) {
    final screenWidth = getScreenWidth(context);
    return (designWidth / 430) * screenWidth;
  }

  static double getResponsiveHeight(BuildContext context, double designHeight) {
    final screenHeight = getScreenHeight(context);
    return (designHeight / 932) * screenHeight;
  }

  static double getResponsiveFontSize(BuildContext context, double fontSize) {
    final screenWidth = getScreenWidth(context);
    return fontSize * (screenWidth / 430);
  }

  static EdgeInsets getResponsivePadding(BuildContext context, EdgeInsets padding) {
    final screenWidth = getScreenWidth(context);
    final scale = screenWidth / 430;
    return EdgeInsets.only(
      left: padding.left * scale,
      top: padding.top * scale,
      right: padding.right * scale,
      bottom: padding.bottom * scale,
    );
  }

  static double getResponsiveValue(BuildContext context, double value) {
    final screenWidth = getScreenWidth(context);
    return value * (screenWidth / 430);
  }
}
