import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/core/services/demande_zip_service.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/client/data/models/archive_model.dart';
import 'package:secure_link/features/client/data/repositories/demandes_repository.dart';
import 'package:secure_link/features/client/domain/bloc/archives_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/archives_event.dart';
import 'package:secure_link/features/client/domain/bloc/archives_state.dart';

class MesArchivesScreen extends StatefulWidget {
  final bool fromHome;
  final VoidCallback? onGoHome;
  const MesArchivesScreen({super.key, this.fromHome = false, this.onGoHome});

  @override
  State<MesArchivesScreen> createState() => _MesArchivesScreenState();
}

class _MesArchivesScreenState extends State<MesArchivesScreen> {
  late final ArchivesBloc _bloc;
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const List<String> _filterLabels = [
    'archives.all',
    'archives.draft',
    'archives.in_progress',
    'archives.validated',
    'archives.rejected',
  ];

  static const List<String?> _filterStatuses = [
    null,
    'BROUILLON',
    'EN_COURS',
    'VALIDE',
    'REJETE',
  ];

  @override
  void initState() {
    super.initState();
    _bloc = ArchivesBloc()..add(const LoadArchivesEvent());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _bloc.add(const LoadMoreArchivesEvent());
    }
  }

  @override
  void dispose() {
    _bloc.close();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<ArchiveModel> _applySearch(List<ArchiveModel> list) {
    if (_selectedFilter != 0) {
      final status = _filterStatuses[_selectedFilter];
      list = list.where((a) => a.status.toUpperCase() == status).toList();
    }
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return list;
    return list
        .where((a) =>
            a.title.toLowerCase().contains(query) ||
            a.institution.toLowerCase().contains(query))
        .toList();
  }

  void _goToPage(int page) {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    _bloc.add(GoToArchivesPageEvent(page));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildSearchBar(),
              _buildFilterBar(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ArchivesBloc, ArchivesState>(
      builder: (context, state) {
        if (state is ArchivesLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is ArchivesError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.statusRejected, size: 40),
                const SizedBox(height: 12),
                Text(state.message,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _bloc.add(
                      LoadArchivesEvent(status: _filterStatuses[_selectedFilter])),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('archives.retry'.tr(),
                        style: const TextStyle(color: AppColors.white, fontSize: 14)),
                  ),
                ),
              ],
            ),
          );
        }
        if (state is ArchivesLoaded) {
          final items = _applySearch(state.archives);

          if (items.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primaryDark,
              onRefresh: () async {
                _bloc.add(LoadArchivesEvent(status: _filterStatuses[_selectedFilter]));
                await Future.delayed(const Duration(milliseconds: 800));
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text('archives.no_archives'.tr(),
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.textSecondary)),
                    ),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              // Compteur
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    Text(
                      '${state.total} ',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      'archives.title'.tr().toLowerCase(),
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Liste
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primaryDark,
                  onRefresh: () async {
                    _bloc.add(LoadArchivesEvent(status: _filterStatuses[_selectedFilter]));
                    await Future.delayed(const Duration(milliseconds: 800));
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: items.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ArchiveCard(item: items[index]),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (widget.fromHome && widget.onGoHome != null) {
                widget.onGoHome!();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back, color: AppColors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('archives.title'.tr(),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              const SizedBox(height: 2),
              Text('archives.subtitle'.tr(),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderDivider)),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'archives.search_placeholder'.tr(),
                  hintStyle: const TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _filterLabels.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final isSelected = _selectedFilter == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _filterLabels[index].tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Archive Card
// ---------------------------------------------------------------------------

class _ArchiveCard extends StatefulWidget {
  final ArchiveModel item;
  const _ArchiveCard({required this.item});

  @override
  State<_ArchiveCard> createState() => _ArchiveCardState();
}

class _ArchiveCardState extends State<_ArchiveCard> {
  bool _isBusy = false;
  double _progress = 0;
  String _progressLabel = '';

  // ── Ouvre le détail de la demande ──
  void _onView(BuildContext context) {
    Navigator.of(context).pushNamed(
      AppRoutes.clientDemandeDetail,
      arguments: {'id': widget.item.id},
    );
  }

  // ── Génère le ZIP et le sauvegarde dans Téléchargements ──
  Future<void> _onDownload(BuildContext context) async {
    if (_isBusy) return;
    setState(() { _isBusy = true; _progress = 0; _progressLabel = 'Préparation...'; });
    try {
      final demande = await DemandesRepository().getRequestById(
        accessToken: _token(),
        id: widget.item.id,
      );

      final zip = await DemandeZipService.genererEtZipper(
        demande: demande,
        onProgress: (p, label) {
          if (mounted) setState(() { _progress = p; _progressLabel = label; });
        },
      );

      final shortId = widget.item.id.length >= 8
          ? widget.item.id.substring(0, 8)
          : widget.item.id;
      final fileName = 'demande_$shortId.zip';

      // Android 10+ : pas besoin de permission, on copie dans Downloads
      String savePath;
      try {
        savePath = '/storage/emulated/0/Download/$fileName';
        await zip.copy(savePath);
      } catch (_) {
        // Fallback : dossier temporaire accessible
        savePath = zip.path;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('archives.download_success'.tr()),
          backgroundColor: AppColors.statusValideGreen,
          action: SnackBarAction(
            label: 'archives.open'.tr(),
            textColor: AppColors.white,
            onPressed: () => OpenFilex.open(savePath),
          ),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('archives.download_error'.tr()),
          backgroundColor: AppColors.statusRejected,
        ));
      }
    } finally {
      if (mounted) setState(() { _isBusy = false; _progress = 0; });
    }
  }

  // ── Génère le ZIP et partage ──
  Future<void> _onShare(BuildContext context) async {
    if (_isBusy) return;
    setState(() { _isBusy = true; _progress = 0; _progressLabel = 'Préparation...'; });
    try {
      final demande = await DemandesRepository().getRequestById(
        accessToken: _token(),
        id: widget.item.id,
      );

      final zip = await DemandeZipService.genererEtZipper(
        demande: demande,
        onProgress: (p, label) {
          if (mounted) setState(() { _progress = p; _progressLabel = label; });
        },
      );

      if (context.mounted) {
        await Share.shareXFiles(
          [XFile(zip.path)],
          subject: widget.item.title,
          text: '${widget.item.title} — ${widget.item.institution}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('archives.download_error'.tr()),
          backgroundColor: AppColors.statusRejected,
        ));
      }
    } finally {
      if (mounted) setState(() { _isBusy = false; _progress = 0; });
    }
  }

  String _token() => UserSession.instance.accessToken;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onView(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDivider),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadowDark,
                blurRadius: 6,
                offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            // ── Infos ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: AppColors.gray,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/logo.svg',
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title.isNotEmpty ? widget.item.title : '—',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.item.institution.isNotEmpty
                              ? '${widget.item.institution} • ${widget.item.date}'
                              : widget.item.date,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: widget.item.status),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // ── Barre de progression ou boutons ──
            if (_isBusy)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _progressLabel,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                        Text(
                          '${(_progress * 100).toInt()}%',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 4,
                        backgroundColor: AppColors.borderDivider,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    // Voir
                    Expanded(
                      child: InkWell(
                        onTap: () => _onView(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.remove_red_eye_outlined,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text('archives.view'.tr(),
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 1, height: 24, color: const Color(0xFFEEEEEE)),
                    // Télécharger
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _onDownload(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.download_outlined,
                                size: 18, color: AppColors.primaryDark),
                            const SizedBox(width: 6),
                            Text('archives.download'.tr(),
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 1, height: 24, color: const Color(0xFFEEEEEE)),
                    // Partager
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _onShare(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.share_outlined,
                                size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text('archives.share'.tr(),
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Badge statut
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final cfg = _cfg();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: cfg.bg, borderRadius: BorderRadius.circular(999)),
      child: Text(cfg.label,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: cfg.text)),
    );
  }

  _Cfg _cfg() {
    switch (status.toUpperCase()) {
      case 'VALIDEE':
      case 'VALIDE':
        return _Cfg('profile.validated'.tr(), AppColors.statusValidated,
            AppColors.statusValidatedLight);
      case 'REJETEE':
      case 'REJETE':
        return _Cfg('profile.rejected'.tr(), AppColors.statusRejected,
            AppColors.statusRejectedLight);
      case 'EN_COURS':
      case 'EN_VERIFICATION':
        return _Cfg('profile.in_progress'.tr(), AppColors.statusInProgress,
            AppColors.statusInProgressLight);
      case 'BROUILLON':
        return _Cfg('demandes.draft'.tr(), AppColors.statusDraft,
            AppColors.statusDraftLight);
      default:
        return _Cfg(status, AppColors.textSecondary, AppColors.borderDivider);
    }
  }
}

class _Cfg {
  final String label;
  final Color text;
  final Color bg;
  const _Cfg(this.label, this.text, this.bg);
}
