import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/features/auth/domain/bloc/user_bloc.dart';
import 'package:secure_link/features/auth/domain/bloc/user_state.dart';
import 'package:secure_link/features/client/data/models/demande_model.dart';
import 'package:secure_link/features/client/domain/bloc/demandes_bloc/demandes_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/demandes_bloc/demandes_event.dart';
import 'package:secure_link/features/client/domain/bloc/demandes_bloc/demandes_state.dart';
import 'package:secure_link/features/client/domain/bloc/notifications_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/notifications_event.dart';
import 'package:secure_link/features/client/domain/bloc/notifications_state.dart';
import 'package:secure_link/features/client/domain/bloc/profile_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/profile_event.dart';
import 'package:secure_link/features/client/domain/bloc/profile_state.dart';
import 'package:secure_link/features/client/presentation/pages/notifications_screen.dart';
import 'package:secure_link/features/client/presentation/pages/step2_documents_screen.dart';
import 'package:secure_link/features/home/domain/bloc/home_bloc.dart';
import 'package:secure_link/features/home/domain/bloc/home_event.dart';
import 'package:secure_link/features/home/domain/bloc/home_state.dart';
import 'package:secure_link/features/kyc/domain/bloc/kyc_bloc.dart';
import 'package:secure_link/features/kyc/domain/bloc/kyc_event.dart';
import 'package:secure_link/features/kyc/domain/bloc/kyc_state.dart';
import 'package:secure_link/features/kyc/presentation/pages/kyc_gate_page.dart';
import 'package:secure_link/features/kyc/presentation/pages/kyc_intro_page.dart';
import 'package:secure_link/widgets/user_avatar.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  late KycBloc _kycBloc;
  StreamSubscription<KycState>? _kycSub;
  String _lastUserId = '';
  bool _kycTriggered = false;
  bool _kycGateOpen = false;

  @override
  void initState() {
    super.initState();
    _kycBloc = KycBloc(userId: '');
    _kycSub = _kycBloc.stream.listen(_onKycState);
    // Charger la complétion réelle depuis l'API au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = context.read<UserBloc>().state;
      if (userState is UserLoaded && userState.user.id != _lastUserId) {
        _initKycBloc(userState.user.id);
      }
      context.read<ProfileBloc>().add(const LoadDocumentTypesEvent());
      context.read<DemandesBloc>().add(const LoadRecentDemandesEvent(limit: 5));
      context.read<HomeBloc>().add(const LoadClientStatisticsEvent());
    });
  }

  void _initKycBloc(String userId) {
    // ignore: avoid_print
    print('[ClientHome] _initKycBloc userId="$_lastUserId" -> "$userId"');
    _kycSub?.cancel();
    _kycBloc.close();
    _lastUserId = userId;
    _kycTriggered = false;
    _kycBloc = KycBloc(userId: userId);
    _kycSub = _kycBloc.stream.listen(_onKycState);
    _kycBloc.add(const KycCheckStatus());
    // ignore: avoid_print
    print('[ClientHome] KycBloc initialise pour userId="$userId"');
  }

  void _pushKycIntro({bool withDelay = true}) {
    if (_kycGateOpen || !mounted) return;
    _kycGateOpen = true;
    _kycTriggered = true;
    Future.delayed(withDelay ? const Duration(seconds: 3) : Duration.zero, () {
      if (!mounted) { _kycGateOpen = false; return; }
      // ignore: avoid_print
      print('[ClientHome] ${withDelay ? "3s ecoulees" : "retour"} -> push KycGatePage');
      // Etape 1 : afficher KycGatePage (ecran d'attente 3s)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: _kycBloc,
            child: const KycGatePage(),
          ),
        ),
      ).then((_) {
        // KycGatePage s'est fermee automatiquement -> push KycIntroPage
        if (!mounted) { _kycGateOpen = false; return; }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: _kycBloc,
              child: const KycIntroPage(),
            ),
          ),
        ).then((result) {
          // ignore: avoid_print
          print('[ClientHome] Retour depuis KycIntroPage result=$result -> re-check KYC');
          _kycGateOpen = false;
          // Re-déclencher que l'utilisateur ait cliqué la flèche (true)
          // ou utilisé le geste/bouton retour Android (null)
          if (mounted && _kycBloc.state is KycRequired) {
            _kycTriggered = false;
            _pushKycIntro(withDelay: true);
          }
        });
      });
    });
  }

  void _triggerKycCheck() {
    // ignore: avoid_print
    print('[ClientHome] triggerKycCheck -> _kycTriggered=$_kycTriggered');
    if (_kycGateOpen) return;
    if (_kycBloc.state is KycRequired) {
      _pushKycIntro(withDelay: true);
    }
  }

  void _onKycState(KycState state) {
    // ignore: avoid_print
    print('[ClientHome] KycState: ${state.runtimeType} | userId=$_lastUserId | triggered=$_kycTriggered');
    if (state is KycCompleted) {
      // ignore: avoid_print
      print('[ClientHome] KYC deja complete -> acces libre');
      _kycTriggered = true;
      return;
    }
    if (state is KycRequired && !_kycTriggered) {
      // ignore: avoid_print
      print('[ClientHome] KYC requis -> home 3s puis KycGatePage');
      _pushKycIntro(withDelay: true);
    }
  }

  @override
  void dispose() {
    _kycSub?.cancel();
    _kycBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    return BlocListener<UserBloc, UserState>(
      listener: (context, userState) {
        if (userState is UserLoaded) {
          final userId = userState.user.id;
          if (userId != _lastUserId) {
            // ignore: avoid_print
            print('[ClientHome] UserBloc -> nouvel userId: "$_lastUserId" -> "$userId"');
            _initKycBloc(userId);
          }
        }
      },
      child: BlocProvider.value(
        value: _kycBloc,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              // ignore: avoid_print
              print('[ClientHome] Retour arriere intercepte -> re-check KYC');
              _kycTriggered = false;
              _triggerKycCheck();
            }
          },
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              final bloc = context.read<UserBloc>();
              final user = userState is UserLoaded
                  ? userState.user
                  : bloc.cachedUser;
              return Scaffold(
                backgroundColor: AppColors.white,
                body: SafeArea(
                  child: RefreshIndicator(
                    color: AppColors.primaryDark,
                    onRefresh: () async {
                      context.read<ProfileBloc>().add(const LoadDocumentTypesEvent(forceRefresh: true));
                      context.read<DemandesBloc>().add(const LoadRecentDemandesEvent(limit: 5));
                      context.read<HomeBloc>().add(const LoadClientStatisticsEvent());
                      context.read<NotificationsBloc>().add(const LoadNotificationsEvent());
                      await Future.delayed(const Duration(milliseconds: 800));
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HomeHeader(initials: user?.initials ?? ''),
                          _WelcomeSection(firstName: user?.firstName ?? ''),
                          _ProfileProgressSection(),
                          _StatsGrid(),
                          _SearchBarSection(),
                          _RecentDemandesSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String initials;
  const _HomeHeader({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ).then((_) {
                  if (context.mounted) {
                    context.read<NotificationsBloc>().add(const LoadNotificationsEvent());
                  }
                }),
                child: const _NotifBadge(),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.clientProfil),
                child: const UserAvatar(size: 42, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Badge notifications — widget séparé pour écouter le bloc indépendamment
class _NotifBadge extends StatelessWidget {
  const _NotifBadge();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        final unread = state is NotificationsLoaded
            ? state.notifications.where((n) => !n.isRead).length
            : 0;
        // ignore: avoid_print
        print('[NotifBadge] unread=$unread state=${state.runtimeType}');
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_outlined,
              size: 26,
              color: AppColors.textBlack87,
            ),
            if (unread > 0)
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
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}


class _WelcomeSection extends StatelessWidget {
  final String firstName;
  const _WelcomeSection({required this.firstName});

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
  bool _showCompletedBanner = false;
  int _lastCompletion = -1;

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, userState) {
        if (userState is UserLoaded) {
          final completion = userState.user.profileCompletion;
          if (completion >= 100 && _lastCompletion >= 0 && _lastCompletion < 100) {
            setState(() => _showCompletedBanner = true);
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) setState(() => _showCompletedBanner = false);
            });
          }
          _lastCompletion = completion;
        }
      },
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, profileState) {
          int? newCompletion;
          if (profileState is ProfileDocumentsLoaded) newCompletion = profileState.completion.completion;
          if (profileState is ProfileDocumentUploadedSuccess) newCompletion = profileState.completion.completion;
          if (profileState is ProfileDocumentUploadedNeedsVerification) newCompletion = profileState.completion.completion;
          if (profileState is ProfileDocumentPatched) newCompletion = profileState.completion.completion;
          if (profileState is ProfileDocumentDeleted) newCompletion = profileState.completion.completion;
          if (newCompletion != null) {
            if (newCompletion >= 100 && _lastCompletion >= 0 && _lastCompletion < 100) {
              setState(() => _showCompletedBanner = true);
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) setState(() => _showCompletedBanner = false);
              });
            }
            _lastCompletion = newCompletion;
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          // Lire la complétion depuis le ProfileBloc (GET /api/users/profile/completion)
          int completion = 50;
          if (profileState is ProfileDocumentsLoaded) {
            completion = profileState.completion.completion;
          } else if (profileState is ProfileDocumentUploadedSuccess) {
            completion = profileState.completion.completion;
          } else if (profileState is ProfileDocumentUploadedNeedsVerification) {
            completion = profileState.completion.completion;
          } else if (profileState is ProfileDocumentPatched) {
            completion = profileState.completion.completion;
          } else if (profileState is ProfileDocumentDeleted) {
            completion = profileState.completion.completion;
          } else if (profileState is ProfileDocumentUploading) {
            completion = profileState.completion.completion;
          } else {
            // Fallback sur UserBloc si ProfileBloc pas encore chargé
            final userState = context.read<UserBloc>().state;
            if (userState is UserLoaded) {
              completion = userState.user.profileCompletion;
            }
            // Déclencher le chargement de la complétion réelle si pas encore fait
            if (profileState is ProfileInProgress || profileState is ProfileLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.read<ProfileBloc>().add(const LoadDocumentTypesEvent());
                }
              });
            }
          }

          final isCompleted = completion >= 100;

          if (isCompleted && !_showCompletedBanner) {
            return const SizedBox.shrink();
          }

          if (_showCompletedBanner) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.statusValideGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.statusValideGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppColors.statusValideGreen,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'home.profile_completed'.tr(),
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.statusValideGreen,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final progress = (completion / 100).clamp(0.0, 1.0);
          final percent = '$completion%';

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'home.complete_profile'.tr(),
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilySofiaSans,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.primaryDark,
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
                          color: AppColors.progressFill,
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
                      color: AppColors.progressFill,
                    ),
                  ),
                ),
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
            ),
          );
        },
      ),
    ),
  );
  }
}


class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

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
                  Expanded(
                    child: _StatCard(
                      label: 'home.total_requests'.tr(),
                      value: total,
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
                      value: inProgress,
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
                      value: pending,
                      iconPath: 'assets/icons/carbon_rule-draft.svg',
                      iconColor: AppColors.statusEnAttente,
                      borderColor: AppColors.statusEnAttente,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'home.validated'.tr(),
                      value: validated,
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
      },
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
class _SearchBarSection extends StatefulWidget {
  const _SearchBarSection();

  @override
  State<_SearchBarSection> createState() => _SearchBarSectionState();
}

class _SearchBarSectionState extends State<_SearchBarSection> {
  final _controller = TextEditingController();

  void _search(String value) {
    FocusScope.of(context).unfocus();
    context.read<DemandesBloc>().add(LoadRecentDemandesEvent(
          limit: 5,
          search: value.trim().isEmpty ? null : value.trim(),
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              child: TextField(
                controller: _controller,
                onSubmitted: _search,
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppColors.textBlack87,
                ),
                decoration: InputDecoration(
                  hintText: 'home.search_placeholder'.tr(),
                  hintStyle: TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppColors.greyShade500,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _search(_controller.text),
              child: Padding(
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
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// RECENT DEMANDES — branchée sur DemandesBloc (API réelle)
// ─────────────────────────────────────────────────────────────────
class _RecentDemandesSection extends StatelessWidget {
  const _RecentDemandesSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.clientDemandes),
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
          BlocBuilder<DemandesBloc, DemandesState>(
            builder: (context, state) {
              if (state is DemandesLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              if (state is DemandesError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    state.message,
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamilyInter,
                      fontSize: AppConstants.fontSizeRegular,
                      color: AppColors.statusRejected,
                    ),
                  ),
                );
              }
              if (state is RecentDemandesLoaded) {
                if (state.demandes.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'demandes.no_demandes'.tr(),
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontSize: AppConstants.fontSizeRegular,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.demandes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _RecentDemandeCard(demande: state.demandes[index]),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _RecentDemandeCard extends StatelessWidget {
  final DemandeModel demande;
  const _RecentDemandeCard({required this.demande});

  @override
  Widget build(BuildContext context) {
    final statusCfg = _statusConfig(demande.status);
    // Nom affiché : formType > formName > requestNumber
    final title = demande.formType.isNotEmpty
        ? demande.formType
        : demande.requestNumber;
    // Sous-titre : organisation + date, on masque si vide
    final org = demande.organisationName;
    final date = demande.createdAt;
    final subtitle = [if (org.isNotEmpty) org, if (date.isNotEmpty) date].join(' • ');

    // ignore: avoid_print
    print('[RecentDemandeCard] id=${demande.id} | title="$title" | subtitle="$subtitle" | formType="${demande.formType}" | requestNumber="${demande.requestNumber}" | org="$org" | date="$date"');

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.clientDemandeDetail,
        arguments: {'id': demande.id},
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDivider),
          boxShadow: const [
            BoxShadow(color: AppColors.shadowDark, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.gray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/logo.svg',
                  width: 22,
                  height: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusCfg.bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusCfg.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusCfg.textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _StatusCfg _statusConfig(String status) {
    switch (status.toUpperCase()) {
      case 'EN_ATTENTE':
      case 'SOUMISE':
        return _StatusCfg('demandes.pending'.tr(), AppColors.statusPending, AppColors.statusPendingLight);
      case 'EN_COURS':
        return _StatusCfg('demandes.in_progress'.tr(), AppColors.statusInProgress, AppColors.statusInProgressLight);
      case 'VALIDEE':
      case 'VALIDATION_FINALE':
        return _StatusCfg('demandes.validated'.tr(), AppColors.statusValidated, AppColors.statusValidatedLight);
      case 'REJETEE':
        return _StatusCfg('demandes.rejected'.tr(), AppColors.statusRejected, AppColors.statusRejectedLight);
      case 'BROUILLON':
        return _StatusCfg('demandes.draft'.tr(), AppColors.statusDraft, AppColors.statusDraftLight);
      default:
        return _StatusCfg(status, AppColors.statusDraft, AppColors.statusDraftLight);
    }
  }
}

class _StatusCfg {
  final String label;
  final Color textColor;
  final Color bgColor;
  const _StatusCfg(this.label, this.textColor, this.bgColor);
}