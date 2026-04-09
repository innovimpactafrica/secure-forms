import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/features/auth/domain/bloc/user_bloc.dart';
import 'package:secure_link/features/auth/domain/bloc/user_state.dart';
import 'package:secure_link/features/client/domain/bloc/demandes_bloc/demandes_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/demandes_bloc/demandes_event.dart';
import 'package:secure_link/features/client/domain/bloc/notifications_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/notifications_event.dart';
import 'package:secure_link/features/client/domain/bloc/profile_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/profile_event.dart';
import 'package:secure_link/features/client/presentation/widgets/home_header.dart';
import 'package:secure_link/features/client/presentation/widgets/profile_progress_section.dart';
import 'package:secure_link/features/client/presentation/widgets/recent_demandes_section.dart';
import 'package:secure_link/features/client/presentation/widgets/stats_grid.dart';
import 'package:secure_link/features/client/presentation/widgets/welcome_section.dart';
import 'package:secure_link/features/home/domain/bloc/home_bloc.dart';
import 'package:secure_link/features/home/domain/bloc/home_event.dart';
import 'package:secure_link/features/kyc/domain/bloc/kyc_bloc.dart';
import 'package:secure_link/features/kyc/domain/bloc/kyc_event.dart';
import 'package:secure_link/features/kyc/domain/bloc/kyc_state.dart';
import 'package:secure_link/features/kyc/presentation/pages/kyc_intro_page.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  late KycBloc _kycBloc;
  String _lastUserId = '';
  bool _kycGateOpen = false;
  bool _lastPushWasFirst = true;

  @override
  void initState() {
    super.initState();
    _kycBloc = KycBloc(userId: '');
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
    if (userId == _lastUserId) {
      print('[KYC][initKycBloc] userId inchangé ("$userId") → skip');
      return;
    }
    print('[KYC][initKycBloc] "$_lastUserId" → "$userId"');
    final old = _kycBloc;
    _lastUserId = userId;
    _kycGateOpen = false;
    _lastPushWasFirst = true;
    _kycBloc = KycBloc(userId: userId);
    old.close();
    print('[KYC][initKycBloc] nouveau KycBloc créé, dispatch KycCheckStatus');
    _kycBloc.add(const KycCheckStatus());
    if (mounted) setState(() {});
  }

  void _pushKycIntro({int delaySeconds = 3}) {
    print('[KYC][pushKycIntro] appelé | _kycGateOpen=$_kycGateOpen mounted=$mounted delay=${delaySeconds}s');
    if (_kycGateOpen) {
      print('[KYC][pushKycIntro] BLOQUÉ — _kycGateOpen=true, page déjà en cours d\'ouverture');
      return;
    }
    if (!mounted) {
      print('[KYC][pushKycIntro] BLOQUÉ — widget non monté');
      return;
    }
    _kycGateOpen = true;
    print('[KYC][pushKycIntro] gate ouverte, attente ${delaySeconds}s...');
    Future.delayed(Duration(seconds: delaySeconds), () {
      if (!mounted) {
        print('[KYC][pushKycIntro] délai écoulé mais widget non monté → annulé');
        _kycGateOpen = false;
        return;
      }
      print('[KYC][pushKycIntro] délai écoulé → push KycIntroPage');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(value: _kycBloc, child: const KycIntroPage()),
        ),
      ).then((_) {
        print('[KYC][pushKycIntro] KycIntroPage fermée (pop) | mounted=$mounted');
        _kycGateOpen = false;
        if (mounted) {
          print('[KYC][pushKycIntro] re-dispatch KycCheckStatus après retour');
          _kycBloc.add(const KycCheckStatus());
        } else {
          print('[KYC][pushKycIntro] widget non monté après retour → pas de re-check');
        }
      });
    });
  }

  @override
  void dispose() {
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
            print('[ClientHome] UserBloc -> nouvel userId: "$_lastUserId" -> "$userId"');
            _initKycBloc(userId);
          }
        }
      },
      child: BlocProvider.value(
        value: _kycBloc,
        child: BlocListener<KycBloc, KycState>(
          bloc: _kycBloc,
          listener: (context, state) {
            print('[KYC][BlocListener] state reçu: ${state.runtimeType} | _kycGateOpen=$_kycGateOpen | _lastPushWasFirst=$_lastPushWasFirst');
            if (state is KycChecking) {
              print('[KYC][BlocListener] KycChecking → vérification en cours, attente...');
            } else if (state is KycRequired) {
              final delay = _lastPushWasFirst ? 1 : 2;
              print('[KYC][BlocListener] KycRequired → délai=$delay s | premier=${_lastPushWasFirst}');
              _lastPushWasFirst = false;
              _pushKycIntro(delaySeconds: delay);
            } else if (state is KycCompleted) {
              print('[KYC][BlocListener] KycCompleted → accès autorisé, aucune action');
            }
          },
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) {
                _kycGateOpen = false;
                _kycBloc.add(const KycCheckStatus());
              }
            },
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                final bloc = context.read<UserBloc>();
                final user = userState is UserLoaded ? userState.user : bloc.cachedUser;
                return Scaffold(
                  backgroundColor: AppColors.white,
                  body: SafeArea(
                    child: RefreshIndicator(
                      color: AppColors.primaryDark,
                      onRefresh: () async {
                        context.read<ProfileBloc>().add(const LoadDocumentTypesEvent(forceRefresh: true));
                        context.read<DemandesBloc>().add(const LoadRecentDemandesEvent(limit: 5, forceRefresh: true));
                        context.read<HomeBloc>().add(const LoadClientStatisticsEvent(forceRefresh: true));
                        context.read<NotificationsBloc>().add(const LoadNotificationsEvent(forceRefresh: true));
                        await Future.delayed(const Duration(milliseconds: 800));
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HomeHeader(initials: user?.initials ?? ''),
                            WelcomeSection(firstName: user?.firstName ?? ''),
                            const ProfileProgressSection(),
                            const StatsGrid(),
                            const SearchBarSection(),
                            const RecentDemandesSection(),
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
      ),
    );
  }
}
