import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';
import 'package:quick_forms/core/utils/app_routes.dart';
import 'package:quick_forms/features/client/data/models/demande_model.dart';
import 'package:quick_forms/features/client/domain/bloc/demandes_bloc/demandes_bloc.dart';
import 'package:quick_forms/features/client/domain/bloc/demandes_bloc/demandes_event.dart';
import 'package:quick_forms/features/client/domain/bloc/demandes_bloc/demandes_state.dart';

class ClientDemandesScreen extends StatefulWidget {
  final bool fromHome;
  final VoidCallback? onGoHome;
  const ClientDemandesScreen({super.key, this.fromHome = false, this.onGoHome});

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
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<DemandesBloc>().add(const LoadMoreDemandesEvent());
    }
  }

  void _load() {
    context.read<DemandesBloc>().add(LoadDemandesEvent(
          status: _filterStatuses[_selectedFilter],
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
        ));
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
          if (!widget.fromHome) ...[
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back,
                    color: AppColors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
          ],
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
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.borderDivider),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search, size: 22, color: AppColors.textSecondary),
            const SizedBox(width: 10),
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
                  hintStyle: const TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                _load();
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward,
                      color: AppColors.white, size: 18),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.primaryDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _filterLabels[index].tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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

  Widget _buildList() {
    return BlocBuilder<DemandesBloc, DemandesState>(
      builder: (context, state) {
        if (state is DemandesLoading) {
          return const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primaryDark));
        }
        if (state is DemandesError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.statusRejected, size: 40),
                  const SizedBox(height: 12),
                  Text(state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.statusRejected, fontSize: 14)),
                  const SizedBox(height: 16),
                  TextButton(
                      onPressed: _load, child: Text('archives.retry'.tr())),
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
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
            );
          }

          return Column(
            children: [
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
                      'demandes.title'.tr().toLowerCase(),
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount:
                      state.demandes.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.demandes.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primaryDark),
                        ),
                      );
                    }
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
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

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
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.grayLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/icone.svg',
                  width: 16,
                  height: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.formType.isNotEmpty
                        ? item.formType
                        : item.requestNumber,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
        return _StatusCfg('demandes.pending'.tr(), AppColors.statusPending,
            AppColors.statusPendingLight);
      case 'EN_COURS':
        return _StatusCfg('demandes.in_progress'.tr(),
            AppColors.statusInProgress, AppColors.statusInProgressLight);
      case 'VALIDEE':
        return _StatusCfg('demandes.validated'.tr(), AppColors.statusValidated,
            AppColors.statusValidatedLight);
      case 'REJETEE':
        return _StatusCfg('demandes.rejected'.tr(), AppColors.statusRejected,
            AppColors.statusRejectedLight);
      case 'BROUILLON':
        return _StatusCfg('demandes.draft'.tr(), AppColors.statusDraft,
            AppColors.statusDraftLight);
      default:
        return _StatusCfg(
            status, AppColors.statusDraft, AppColors.statusDraftLight);
    }
  }
}

class _StatusCfg {
  final String label;
  final Color textColor;
  final Color bgColor;
  const _StatusCfg(this.label, this.textColor, this.bgColor);
}
