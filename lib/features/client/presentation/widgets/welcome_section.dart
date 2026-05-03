import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';

class WelcomeSection extends StatelessWidget {
  final String firstName;
  const WelcomeSection({super.key, required this.firstName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${'home.hello'.tr()} ${firstName.isNotEmpty ? firstName : ''},',
            style: TextStyle(
              fontFamily: AppConstants.fontFamilySofiaSans,
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: AppColors.textBlack87,
            ),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontSize: 13,
                  fontWeight: FontWeight.w400),
              children: [
                TextSpan(
                    text: 'home.welcome_on'.tr(),
                    style: TextStyle(color: AppColors.textBlack54)),
                TextSpan(
                    text: 'home.quick'.tr(),
                    style: const TextStyle(
                        color: AppColors.backArrowColor,
                        fontWeight: FontWeight.w600)),
                TextSpan(
                    text: 'home.forms'.tr(),
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
