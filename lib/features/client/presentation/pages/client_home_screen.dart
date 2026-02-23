import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/features/client/domain/bloc/profile_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/profile_state.dart';
import 'package:secure_link/features/client/presentation/pages/step1_informations_screen.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
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
              Stack(
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
            'Bonjour Lamine,',
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
                  text: 'Bienvenue sur ',
                  style: TextStyle(color: AppColors.textBlack54),
                ),
                TextSpan(
                  text: 'secure ',
                  style: TextStyle(
                    color: AppColors.textBlack87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: 'Forms',
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


class _ProfileProgressSection extends StatelessWidget {
  const _ProfileProgressSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final isCompleted = state is ProfileCompleted;
        final progress = state is ProfileInProgress
            ? state.profile.progressPercent
            : state is ProfileCompleted
                ? 1.0
                : 0.30;
        final percent = '${(progress * 100).toInt()}%';

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label dynamique
              Text(
                isCompleted ? 'Profil complété à 100% ✓' : 'Complétez votre profil',
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isCompleted ? AppColors.statusValideGreen : AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              // Barre de progression dynamique
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
              // % dynamique
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
              // Bouton masqué si profil complété
              if (!isCompleted) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ProfileBloc>(),
                        child: const Step1InformationsScreen(),
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
                          'Commencer maintenant',
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
                  label: 'Total demandes',
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
                  label: 'En cours',
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
                  label: 'En attente',
                  value: '01',
                  iconPath: 'assets/icons/carbon_rule-draft.svg',
                  iconColor: AppColors.statusEnAttente,
                  borderColor: AppColors.statusEnAttente,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Validé',
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
                'Rechercher une banque, notaire....',
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
                'Demandes récentes',
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
                      'Tout voir',
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
                          'Ouverture de compte',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontWeight: FontWeight.w600,
                            fontSize: AppConstants.fontSizeLarge,
                            color: AppColors.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Banque Nationale • 18/12/2025',
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
                      'En attente',
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
                          'Demande de virement',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontWeight: FontWeight.w600,
                            fontSize: AppConstants.fontSizeLarge,
                            color: AppColors.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Banque Nationale • 12/12/2025',
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
                      'Validé',
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