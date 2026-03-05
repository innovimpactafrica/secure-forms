import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/features/client/domain/bloc/profile_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/profile_state.dart';
import 'package:secure_link/features/client/presentation/pages/notifications_screen.dart';
import 'package:secure_link/features/client/presentation/pages/step2_documents_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  @override
  Widget build(BuildContext context) {
    context.locale; // Force rebuild on locale change
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeHeader(),
              _WelcomeSection(),
              _ProfileProgressSection(),
              _StatsGrid(),
              _SearchBarSection(),
              _RecentDemandesSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // SecureLink logo
          SizedBox(
            width: 54,
            height: 54,
            child: Image.asset(
              'assets/images/SLLOGO.png',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
            ),
          ),
          // Right side: notification bell + avatar
          Row(
            children: [
              // Bell with notification badge
              GestureDetector(
  onTap: () => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const NotificationsScreen(),
    ),
  ),
  child: Stack(
    clipBehavior: Clip.none,
    children: [
      Icon(
        Icons.notifications_outlined,
        size: 26,
        color: AppColors.textBlack87,
      ),
      Positioned(
        top: -3,
        right: -3,
        child: Container(
          width: 15,
          height: 15,
          decoration: const BoxDecoration(
            color: AppColors.statusRejected,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '2',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),
              const SizedBox(width: 14),
              // Avatar circle
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.clientProfil),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'LD',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: AppConstants.fontFamilySofiaSans,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${'home.hello'.tr()} Lamine,',
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
                fontWeight: FontWeight.w400,
              ),
              children: [
                TextSpan(
                  text: 'home.welcome_on'.tr(),
                  style: TextStyle(color: AppColors.textBlack54),
                ),
                TextSpan(
                  text: 'home.secure'.tr(),
                  style: TextStyle(
                    color: AppColors.textBlack87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: 'home.forms'.tr(),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _ProfileProgressSection extends StatefulWidget {
  const _ProfileProgressSection();

  @override
  State<_ProfileProgressSection> createState() =>
      _ProfileProgressSectionState();
}

class _ProfileProgressSectionState extends State<_ProfileProgressSection> {
  bool _showCompleted = false;
  bool _hideSection = false;

  @override
  void initState() {
    super.initState();
    // Vérifier si le profil est déjà complété au démarrage
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileCompleted) {
      _showCompleted = true;
      // Masquer après 3 secondes
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _hideSection = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileCompleted && !_showCompleted) {
          setState(() => _showCompleted = true);
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) setState(() => _hideSection = true);
          });
        }
      },
      builder: (context, state) {
        if (_hideSection) return const SizedBox.shrink();

        final isCompleted = _showCompleted || state is ProfileCompleted;
        final progress = isCompleted
            ? 1.0
            : state is ProfileInProgress
                ? state.profile.progressPercent
                : 0.50;
        final percent = '${(progress * 100).toInt()}%';

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCompleted
                    ? 'home.profile_completed'.tr()
                    : 'home.complete_profile'.tr(),
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isCompleted
                      ? AppColors.statusValideGreen
                      : AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.progressTrack,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 7,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.statusValideGreen
                            : AppColors.progressFill,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  percent,
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? AppColors.statusValideGreen
                        : AppColors.progressFill,
                  ),
                ),
              ),
              if (!isCompleted) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ProfileBloc>(),
                        child: const Step2DocumentsScreen(),
                      ),
                    ),
                  ),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 20),
                        Text(
                          'home.start_now'.tr(),
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            color: AppColors.primaryDarker,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}


class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'home.total_requests'.tr(),
                  value: '12',
                  iconPath: 'assets/icons/logo.svg',
                  iconColor: AppColors.textBlack45,
                  borderColor: AppColors.progressTrack,
                  applyColorFilter: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'home.in_progress'.tr(),
                  value: '10',
                  iconPath: 'assets/icons/bi_clock-history.svg',
                  iconColor: AppColors.primary,
                  borderColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'home.pending'.tr(),
                  value: '01',
                  iconPath: 'assets/icons/carbon_rule-draft.svg',
                  iconColor: AppColors.statusEnAttente,
                  borderColor: AppColors.statusEnAttente,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'home.validated'.tr(),
                  value: '10',
                  iconPath: 'assets/icons/bi_check2-circle (1).svg',
                  iconColor: AppColors.statusValideGreen,
                  borderColor: AppColors.statusValideGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String iconPath;
  final Color iconColor;
  final Color borderColor;
  final bool applyColorFilter;

  const _StatCard({
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
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontSize: 11,
                  color: AppColors.textBlack54,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlack87,
                ),
              ),
            ],
          ),
          Container(
  width: 44,
  height: 44,
  decoration: BoxDecoration(
    color: iconColor.withValues(alpha: 0.12),
    shape: BoxShape.circle,
  ),
  child: Center(
    child: SvgPicture.asset(
      iconPath,
      width: 22,
      height: 22,
      colorFilter: applyColorFilter
          ? ColorFilter.mode(iconColor, BlendMode.srcIn)
          : null,
    ),
  ),
),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SEARCH BAR
// ─────────────────────────────────────────────────────────────────
class _SearchBarSection extends StatelessWidget {
  const _SearchBarSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.greyShade100,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.greyShade200),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search, color: AppColors.greyShade500, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'home.search_placeholder'.tr(),
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppColors.greyShade500,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.primaryDark,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// RECENT DEMANDES — cards conservées identiques à l'original
// ─────────────────────────────────────────────────────────────────
class _RecentDemandesSection extends StatelessWidget {
  const _RecentDemandesSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'home.recent_requests'.tr(),
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontWeight: FontWeight.w500,
                  fontSize: AppConstants.fontSizeTitle,
                  color: AppColors.textBlack87,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.clientDemandes),
                child: Row(
                  children: [
                    Text(
                      'home.see_all'.tr(),
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.fontSizeMedium,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: AppConstants.fontSizeSmall,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Card 1: Ouverture de compte ──
          GestureDetector(
            onTap: () => Navigator.of(context)
                .pushNamed(AppRoutes.clientDemandeDetail),
            child: Container(
              height: AppConstants.cardDemandeHeight,
              padding: EdgeInsets.fromLTRB(
                  AppConstants.paddingLarge, 10, AppConstants.paddingSmall, 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(color: AppColors.whiteOverlay),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 48,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/logo.svg',
                    width: AppConstants.cardIconSize,
                    height: AppConstants.cardIconSize,
                  ),
                  SizedBox(width: AppConstants.paddingLarge),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'home.account_opening'.tr(),
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontWeight: FontWeight.w600,
                            fontSize: AppConstants.fontSizeLarge,
                            color: AppColors.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${'home.national_bank'.tr()} • 18/12/2025',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontWeight: FontWeight.w400,
                            fontSize: AppConstants.fontSizeRegular,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingSmall, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.statusPendingLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'home.pending'.tr(),
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontWeight: FontWeight.w500,
                        fontSize: AppConstants.fontSizeRegular,
                        height: 1.0,
                        color: AppColors.statusPending,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: AppConstants.paddingLarge),

          // ── Card 2: Demande de virement ──
          GestureDetector(
            onTap: () => Navigator.of(context)
                .pushNamed(AppRoutes.clientDemandeDetail),
            child: Container(
              height: AppConstants.cardDemandeHeight,
              padding: EdgeInsets.fromLTRB(
                  AppConstants.paddingLarge, 10, AppConstants.paddingSmall, 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(color: AppColors.whiteOverlay),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 48,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/logo (1).svg',
                    width: AppConstants.cardIconSize,
                    height: AppConstants.cardIconSize,
                  ),
                  SizedBox(width: AppConstants.paddingLarge),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'home.transfer_request'.tr(),
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontWeight: FontWeight.w600,
                            fontSize: AppConstants.fontSizeLarge,
                            color: AppColors.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${'home.national_bank'.tr()} • 12/12/2025',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontWeight: FontWeight.w400,
                            fontSize: AppConstants.fontSizeRegular,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingSmall, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.statusValidatedLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'home.validated'.tr(),
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontWeight: FontWeight.w500,
                        fontSize: AppConstants.fontSizeRegular,
                        height: 1.0,
                        color: AppColors.statusValidated,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}