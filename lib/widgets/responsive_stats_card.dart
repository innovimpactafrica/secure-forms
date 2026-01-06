import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/responsive_utils.dart';

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
      height: ResponsiveUtils.getResponsiveHeight(context, 82),
      padding: EdgeInsets.fromLTRB(
        ResponsiveUtils.getResponsiveWidth(context, 12),
        ResponsiveUtils.getResponsiveHeight(context, 16),
        ResponsiveUtils.getResponsiveWidth(context, 12),
        ResponsiveUtils.getResponsiveHeight(context, 16),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveValue(context, 8),
        ),
        border: Border.all(
          color: const Color(0xFFE8EEE7),
          width: ResponsiveUtils.getResponsiveValue(context, 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
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
                    fontFamily: 'Sofia Sans',
                    fontWeight: FontWeight.w500,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                    height: 1.0,
                    letterSpacing: 0,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 4)),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Sofia Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                    height: 1.2,
                    letterSpacing: 0,
                    color: const Color(0xFF212121),
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