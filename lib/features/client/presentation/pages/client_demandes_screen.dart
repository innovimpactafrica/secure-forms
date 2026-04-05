import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/features/client/data/models/demande_model.dart';
import 'package:secure_link/features/client/domain/bloc/demandes_bloc/demandes_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/demandes_bloc/demandes_event.dart';
import 'package:secure_link/features/client/domain/bloc/demandes_bloc/demandes_state.dart';

class ClientDemandesScreen extends StatefulWidget {
  const ClientDemandesScreen({super.key});

  @override
  State<ClientDemandesScreen> createState() => _ClientDemandesScreenState();
}

class _ClientDemandesScreenState extends State<ClientDemandesScreen> {
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const List<String> _filterLabels = [
    'demandes.all',
    'demandes.draft',
    'demandes.in_progress',
    'demandes.validated',
    'demandes.rejected',
  ];

  static const List<String?> _filterStatuses = [
    null,
    'BROUILLON',
    'EN_COURS',
    'VALIDEE',
    'REJETEE',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<DemandesBloc>().add(LoadDemandesEvent(
          status: _filterStatuses[_selectedFilter],
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
        ));
  }

  void _goToPage(int page) {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    context.read<DemandesBloc>().add(GoToDemandesPageEvent(page));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            _buildFilterBar(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'demandes.title'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'demandes.subtitle'.tr(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
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
          border: Border.all(color: AppColors.borderDivider),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _load(),
                onChanged: (v) {
                  if (v.isEmpty) _load();
                },
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'demandes.search_placeholder'.tr(),
                  hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
      padding: const EdgeInsets.only(top: 16, bottom: 8),
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
              onTap: () {
                setState(() => _selectedFilter = index);
                _load();
              },
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

  Widget _buildList() {
    return BlocBuilder<DemandesBloc, DemandesState>(
      builder: (context, state) {
        if (state is DemandesLoading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark));
        }
        if (state is DemandesError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.statusRejected, size: 40),
                  const SizedBox(height: 12),
                  Text(state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.statusRejected, fontSize: 14)),
                  const SizedBox(height: 16),
                  TextButton(onPressed: _load, child: Text('archives.retry'.tr())),
                ],
              ),
            ),
          );
        }
        if (state is DemandesLoaded) {
          if (state.demandes.isEmpty) {
            return Center(
              child: Text(
                'demandes.no_demandes'.tr(),
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            );
          }

          final totalPages = (state.total / 10).ceil().clamp(1, 999);

          return Column(
            children: [
              // ── Compteur résultats ──
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
                      state.total > 1 ? 'demandes.title'.tr().toLowerCase() : 'demandes.title'.tr().toLowerCase(),
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    Text(
                      'Page ${state.currentPage}/$totalPages',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Liste ──
              Expanded(
                child: state.isLoadingMore
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: state.demandes.length,
                        itemBuilder: (context, index) {
                          final item = state.demandes[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _DemandeCard(
                              item: item,
                              onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.clientDemandeDetail,
                                arguments: {'id': item.id},
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // ── Barre de pagination ──
              if (totalPages > 1)
                _PaginationBar(
                  currentPage: state.currentPage,
                  totalPages: totalPages,
                  onPageTap: _goToPage,
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BARRE DE PAGINATION
// ─────────────────────────────────────────────────────────────────
class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final void Function(int page) onPageTap;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageTap,
  });

  List<int?> _buildPageNumbers() {
    // Affiche max 5 numéros avec ellipses (null = ...)
    if (totalPages <= 7) {
      return List.generate(totalPages, (i) => i + 1);
    }
    final pages = <int?>[];
    pages.add(1);
    if (currentPage > 3) pages.add(null); // ellipse gauche
    for (int i = (currentPage - 1).clamp(2, totalPages - 1);
        i <= (currentPage + 1).clamp(2, totalPages - 1);
        i++) {
      pages.add(i);
    }
    if (currentPage < totalPages - 2) pages.add(null); // ellipse droite
    pages.add(totalPages);
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPageNumbers();
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.borderDivider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bouton précédent
          _NavButton(
            icon: Icons.chevron_left,
            enabled: currentPage > 1,
            onTap: () => onPageTap(currentPage - 1),
          ),
          const SizedBox(width: 8),

          // Numéros de pages
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: pages.map((p) {
                  if (p == null) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text('...', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    );
                  }
                  final isActive = p == currentPage;
                  return GestureDetector(
                    onTap: isActive ? null : () => onPageTap(p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primaryDark : AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive ? AppColors.primaryDark : AppColors.borderDivider,
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$p',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                            color: isActive ? AppColors.white : AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(width: 4),
          // Bouton suivant
          _NavButton(
            icon: Icons.chevron_right,
            enabled: currentPage < totalPages,
            onTap: () => onPageTap(currentPage + 1),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryDark : AppColors.greyShade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Demande Card
// ---------------------------------------------------------------------------

class _DemandeCard extends StatelessWidget {
  final DemandeModel item;
  final VoidCallback onTap;

  const _DemandeCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusCfg = _statusConfig(item.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDivider),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowDark,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.gray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/logo.svg',
                  width: 32,
                  height: 32,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.formType.isNotEmpty ? item.formType : item.requestNumber,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.organisationName} • ${item.createdAt}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusCfg.bgColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusCfg.label,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeRegular,
                    fontWeight: FontWeight.w500,
                    color: statusCfg.textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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
        return _StatusCfg('demandes.pending'.tr(), AppColors.statusPending, AppColors.statusPendingLight);
      case 'EN_COURS':
        return _StatusCfg('demandes.in_progress'.tr(), AppColors.statusInProgress, AppColors.statusInProgressLight);
      case 'VALIDEE':
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
