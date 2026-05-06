import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';
import 'package:quick_forms/features/home/domain/bloc/home_bloc.dart';
import 'package:quick_forms/features/home/domain/bloc/home_state.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    context.locale; // force rebuild on locale change
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final stats = state is HomeStatisticsLoaded ? state.statistics : null;
        final total =
            stats != null ? stats.total.toString().padLeft(2, '0') : '--';
        final inProgress =
            stats != null ? stats.inProgress.toString().padLeft(2, '0') : '--';
        final pending =
            stats != null ? stats.pending.toString().padLeft(2, '0') : '--';
        final validated =
            stats != null ? stats.validated.toString().padLeft(2, '0') : '--';
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: StatCard(
                          label: 'home.total_requests'.tr(),
                          value: total,
                          iconPath: 'assets/icons/td.svg',
                          cardBg: AppColors.statTotalBg,
                          borderColor: AppColors.statTotalBorder,
                          iconColor: AppColors.statTotalIconColor,
                          iconBgColor: AppColors.statTotalIconBg,
                          applyColorFilter: false,
                          iconSize: 17)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: StatCard(
                          label: 'home.in_progress'.tr(),
                          value: inProgress,
                          iconPath: 'assets/icons/bi_clock-history.svg',
                          cardBg: AppColors.statInProgressBg,
                          borderColor: AppColors.statInProgressBorder,
                          iconColor: AppColors.statInProgressIconColor,
                          iconBgColor: AppColors.statInProgressIconBg,
                          iconSize: 22)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: StatCard(
                          label: 'home.pending'.tr(),
                          value: pending,
                          iconPath: 'assets/icons/carbon_rule-draft.svg',
                          cardBg: AppColors.statPendingBg,
                          borderColor: AppColors.statPendingBorder,
                          iconColor: AppColors.statPendingIconColor,
                          iconBgColor: AppColors.statPendingIconBg,
                          iconSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: StatCard(
                          label: 'home.validated'.tr(),
                          value: validated,
                          iconPath: 'assets/icons/bi_check2-circle (1).svg',
                          cardBg: AppColors.statValidatedBg,
                          borderColor: AppColors.statValidatedBorder,
                          iconColor: AppColors.statValidatedIconColor,
                          iconBgColor: AppColors.statValidatedIconBg,
                          iconSize: 22)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String iconPath;
  final Color iconColor;
  final Color iconBgColor;
  final Color borderColor;
  final Color cardBg;
  final bool applyColorFilter;
  final double iconSize;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.iconPath,
    required this.iconColor,
    required this.iconBgColor,
    required this.borderColor,
    this.cardBg = AppColors.white,
    this.applyColorFilter = true,
    this.iconSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      fontFamily: AppConstants.fontFamilyInter,
                      fontSize: 11,
                      color: AppColors.textBlack54,
                      fontWeight: FontWeight.w400)),
              Text(value,
                  style: TextStyle(
                      fontFamily: AppConstants.fontFamilySofiaSans,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textBlack87)),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration:
                BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Center(
              child: SvgPicture.asset(iconPath,
                  width: iconSize,
                  height: iconSize,
                  colorFilter: applyColorFilter
                      ? ColorFilter.mode(iconColor, BlendMode.srcIn)
                      : null),
            ),
          ),
        ],
      ),
    );
  }
}
