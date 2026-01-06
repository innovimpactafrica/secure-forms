import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/responsive_utils.dart';

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
          vertical: ResponsiveUtils.getResponsiveHeight(context, 16),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: ResponsiveUtils.getResponsiveWidth(context, 24),
              height: ResponsiveUtils.getResponsiveHeight(context, 24),
              colorFilter: const ColorFilter.mode(
                Color(0xFF23A3A6),
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 16)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Sofia Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  color: const Color(0xFF374151),
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: TextStyle(
                  fontFamily: 'Sofia Sans',
                  fontWeight: FontWeight.w400,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 8)),
            ],
            if (showChevron)
              Icon(
                Icons.chevron_right,
                color: const Color(0xFF9CA3AF),
                size: ResponsiveUtils.getResponsiveValue(context, 20),
              ),
          ],
        ),
      ),
    );
  }
}