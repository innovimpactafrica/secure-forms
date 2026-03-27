import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/client/data/models/archive_model.dart';
import 'package:secure_link/features/client/data/repositories/demandes_repository.dart';
import 'package:secure_link/features/client/domain/bloc/archives_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/archives_event.dart';
import 'package:secure_link/features/client/domain/bloc/archives_state.dart';

class MesArchivesScreen extends StatefulWidget {
  const MesArchivesScreen({super.key});

  @override
  State<MesArchivesScreen> createState() => _MesArchivesScreenState();
}

class _MesArchivesScreenState extends State<MesArchivesScreen> {
  late final ArchivesBloc _bloc;
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();

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
  }

  @override
  void dispose() {
    _bloc.close();
    _searchController.dispose();
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('archives.retry'.tr(),
                        style: const TextStyle(
                            color: AppColors.white, fontSize: 14)),
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
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primaryDark,
            onRefresh: () async {
              _bloc.add(LoadArchivesEvent(status: _filterStatuses[_selectedFilter]));
              await Future.delayed(const Duration(milliseconds: 800));
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: items.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ArchiveCard(item: items[index]),
              ),
            ),
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
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back,
                  color: AppColors.white, size: 20),
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
                style:
                    const TextStyle(fontSize: 14, color: AppColors.textDark),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryDark
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _filterLabels[index].tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color:
                        isSelected ? AppColors.white : AppColors.textSecondary,
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
  bool _isDownloading = false;

  // Télécharge le fichier et retourne le chemin local
  Future<String?> _fetchFile(BuildContext context) async {
    setState(() => _isDownloading = true);
    try {
      String? url = widget.item.isRequest
          ? widget.item.pdfUrl
          : widget.item.filePath;

      final token = UserSession.instance.accessToken;

      if (widget.item.isRequest && (url == null || url.isEmpty)) {
        final demande = await DemandesRepository()
            .getRequestById(accessToken: token, id: widget.item.id);
        url = demande.pdfUrl;
      }

      if (url == null || url.isEmpty) {
        throw Exception('Aucun PDF disponible');
      }

      // Fichier temporaire pour le viewer
      final tmp = await getTemporaryDirectory();
      final tmpPath = '${tmp.path}/view_${widget.item.id}.pdf';

      final options = widget.item.isRequest
          ? Options(responseType: ResponseType.bytes)
          : Options(
              responseType: ResponseType.bytes,
              headers: {'Authorization': 'Bearer $token'},
            );

      await Dio().download(url, tmpPath, options: options);
      return tmpPath;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('archives.download_error'.tr()),
          backgroundColor: AppColors.statusRejected,
        ));
      }
      return null;
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  // Ouvre le viewer PDF intégré
  void _onView(BuildContext context) {
    if (widget.item.isRequest) {
      // Pour les demandes : ouvrir le viewer PDF directement
      _fetchFile(context).then((path) {
        if (path != null && context.mounted) {
          _openPdfViewer(context, path);
        }
      });
    } else {
      _fetchFile(context).then((path) {
        if (path != null && context.mounted) {
          _openPdfViewer(context, path);
        }
      });
    }
  }

  void _openPdfViewer(BuildContext context, String path) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PdfViewerSheet(
        label: widget.item.title,
        filePath: path,
      ),
    );
  }

  // Télécharge dans le dossier Téléchargements public Android
  Future<void> _onDownload(BuildContext context) async {
    final tmpPath = await _fetchFile(context);
    if (tmpPath == null || !context.mounted) return;

    try {
      // Dossier public Downloads visible dans le gestionnaire de fichiers
      final fileName = '${widget.item.title.replaceAll(RegExp(r'[^\w\s]'), '_')}_${widget.item.id}.pdf';
      final savePath = '/storage/emulated/0/Download/$fileName';
      await File(tmpPath).copy(savePath);

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
    } catch (_) {
      // Fallback : ouvrir depuis le fichier temporaire
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('archives.download_success'.tr()),
          backgroundColor: AppColors.statusValideGreen,
          action: SnackBarAction(
            label: 'archives.open'.tr(),
            textColor: AppColors.white,
            onPressed: () => OpenFilex.open(tmpPath),
          ),
        ));
      }
    }
  }

  Future<void> _onShare(BuildContext context) async {
    final path = await _fetchFile(context);
    if (path != null && context.mounted) {
      await Share.shareXFiles(
        [XFile(path)],
        text: '${widget.item.title} — ${widget.item.institution}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      widget.item.isRequest
                          ? 'assets/icons/logo.svg'
                          : 'assets/icons/earmark-text.svg',
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
                        widget.item.title.isNotEmpty
                            ? widget.item.title
                            : '—',
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
          SizedBox(
            height: 44,
            child: _isDownloading
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onView(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.remove_red_eye_outlined,
                                  size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 5),
                              Text('archives.view'.tr(),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 20,
                          color: const Color(0xFFEEEEEE)),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onDownload(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/download.png',
                                  width: 16, height: 16),
                              const SizedBox(width: 5),
                              Text('archives.download'.tr(),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 20,
                          color: const Color(0xFFEEEEEE)),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onShare(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/share.png',
                                  width: 16, height: 16),
                              const SizedBox(width: 5),
                              Text('archives.share'.tr(),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
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

// ---------------------------------------------------------------------------
// PDF Viewer Sheet
// ---------------------------------------------------------------------------

class _PdfViewerSheet extends StatelessWidget {
  final String label;
  final String filePath;
  const _PdfViewerSheet({required this.label, required this.filePath});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Container(
      height: screenH * 0.92,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderGray,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close,
                    color: AppColors.textSecondary, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: PDFView(
              filePath: filePath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: false,
              pageSnap: false,
              fitPolicy: FitPolicy.WIDTH,
              enableRenderDuringScale: true,
              useBestQuality: true,
            ),
          ),
        ],
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
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cfg.text)),
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
