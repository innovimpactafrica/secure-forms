import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/features/home/domain/bloc/home_bloc.dart';
import 'package:secure_link/features/home/domain/bloc/home_state.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final stats = state is HomeStatisticsLoaded ? state.statistics : null;
        final total      = stats != null ? stats.total.toString().padLeft(2, '0')      : '--';
        final inProgress = stats != null ? stats.inProgress.toString().padLeft(2, '0') : '--';
        final pending    = stats != null ? stats.pending.toString().padLeft(2, '0')    : '--';
        final validated  = stats != null ? stats.validated.toString().padLeft(2, '0')  : '--';
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: StatCard(label: 'home.total_requests'.tr(), value: total, iconPath: 'assets/icons/logo.svg', iconColor: AppColors.textBlack45, borderColor: AppColors.progressTrack, applyColorFilter: false)),
                  const SizedBox(width: 12),
                  Expanded(child: StatCard(label: 'home.in_progress'.tr(), value: inProgress, iconPath: 'assets/icons/bi_clock-history.svg', iconColor: AppColors.primary, borderColor: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: StatCard(label: 'home.pending'.tr(), value: pending, iconPath: 'assets/icons/carbon_rule-draft.svg', iconColor: AppColors.statusEnAttente, borderColor: AppColors.statusEnAttente)),
                  const SizedBox(width: 12),
                  Expanded(child: StatCard(label: 'home.validated'.tr(), value: validated, iconPath: 'assets/icons/bi_check2-circle (1).svg', iconColor: AppColors.statusValideGreen, borderColor: AppColors.statusValideGreen)),
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
  final Color borderColor;
  final bool applyColorFilter;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.iconPath,
    required this.iconColor,
    required this.borderColor,
    this.applyColorFilter = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontFamily: AppConstants.fontFamilyInter, fontSize: 11, color: AppColors.textBlack54, fontWeight: FontWeight.w400)),
              Text(value, style: TextStyle(fontFamily: AppConstants.fontFamilySofiaSans, fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textBlack87)),
            ],
          ),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Center(
              child: SvgPicture.asset(iconPath, width: 22, height: 22,
                  colorFilter: applyColorFilter ? ColorFilter.mode(iconColor, BlendMode.srcIn) : null),
            ),
          ),
        ],
      ),
    );
  }
}
