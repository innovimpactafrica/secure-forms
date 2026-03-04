import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_routes.dart';

// ---------------------------------------------------------------------------
// Models – will be replaced by real API models once connected
// ---------------------------------------------------------------------------

enum DemandeStatus { brouillon, enAttente, enCours, valide, rejete }

class DemandeItem {
  final String id;
  final String title;
  final String institution;
  final String date;
  final DemandeStatus status;
  final String iconAsset;

  const DemandeItem({
    required this.id,
    required this.title,
    required this.institution,
    required this.date,
    required this.status,
    required this.iconAsset,
  });
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class ClientDemandesScreen extends StatefulWidget {
  const ClientDemandesScreen({super.key});

  @override
  State<ClientDemandesScreen> createState() => _ClientDemandesScreenState();
}

class _ClientDemandesScreenState extends State<ClientDemandesScreen> {
  // TODO: Replace with BLoC state – DemandesBloc
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();

  // TODO: Replace with data coming from DemandesBloc / DemandesRepository
  List<DemandeItem> get _allDemandes => [
    DemandeItem(
      id: '1',
      title: 'demandes.account_opening'.tr(),
      institution: 'demandes.national_bank'.tr(),
      date: '18/12/2025',
      status: DemandeStatus.enAttente,
      iconAsset: 'assets/icons/logo.svg',
    ),
    DemandeItem(
      id: '2',
      title: 'demandes.transfer_request'.tr(),
      institution: 'demandes.national_bank'.tr(),
      date: '12/12/2025',
      status: DemandeStatus.valide,
      iconAsset: 'assets/icons/logo (1).svg',
    ),
    DemandeItem(
      id: '3',
      title: 'demandes.sale_deed'.tr(),
      institution: 'demandes.notary_x'.tr(),
      date: '05/12/2025',
      status: DemandeStatus.enCours,
      iconAsset: 'assets/icons/logo.svg',
    ),
    DemandeItem(
      id: '4',
      title: 'demandes.loan_request'.tr(),
      institution: 'demandes.modern_credit'.tr(),
      date: '12/11/2025',
      status: DemandeStatus.valide,
      iconAsset: 'assets/icons/logo.svg',
    ),
    DemandeItem(
      id: '5',
      title: 'demandes.card_opposition'.tr(),
      institution: 'demandes.national_bank'.tr(),
      date: '04/11/2025',
      status: DemandeStatus.rejete,
      iconAsset: 'assets/icons/logo.svg',
    ),
  ];

  static const List<String> _filterLabels = [
    'demandes.all',
    'demandes.draft',
    'demandes.in_progress',
    'demandes.validated',
    'demandes.rejected',
  ];

  // Convertit le statut en String pour le passer à la page de détail
  // TODO: Supprimer quand l'API sera connectée (on passera un vrai ID)
  String _statusToString(DemandeStatus status) {
    switch (status) {
      case DemandeStatus.enAttente:
        return 'enAttente';
      case DemandeStatus.enCours:
        return 'enCours';
      case DemandeStatus.valide:
        return 'valide';
      case DemandeStatus.rejete:
        return 'rejete';
      case DemandeStatus.brouillon:
        return 'brouillon';
    }
  }

  List<DemandeItem> get _filteredDemandes {
    // TODO: Move filtering logic to BLoC when API connected
    final query = _searchController.text.toLowerCase();
    List<DemandeItem> list = _allDemandes;

    if (_selectedFilter != 0) {
      final statusMap = {
        1: DemandeStatus.brouillon,
        2: DemandeStatus.enCours,
        3: DemandeStatus.valide,
        4: DemandeStatus.rejete,
      };
      list = list.where((d) => d.status == statusMap[_selectedFilter]).toList();
    }

    if (query.isNotEmpty) {
      list = list
          .where((d) =>
              d.title.toLowerCase().contains(query) ||
              d.institution.toLowerCase().contains(query))
          .toList();
    }

    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
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
            // TODO: Wrap with BlocBuilder<DemandesBloc, DemandesState>
            Expanded(child: _buildDemandesList()),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Header
  // -------------------------------------------------------------------------

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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'demandes.subtitle'.tr(),
                style: TextStyle(
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

  // -------------------------------------------------------------------------
  // Search bar
  // -------------------------------------------------------------------------

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
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'demandes.search_placeholder'.tr(),
                  hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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

  // -------------------------------------------------------------------------
  // Filter bar
  // -------------------------------------------------------------------------

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

  // -------------------------------------------------------------------------
  // Demandes list
  // -------------------------------------------------------------------------

  Widget _buildDemandesList() {
    final items = _filteredDemandes;

    if (items.isEmpty) {
      return Center(
        child: Text(
          'demandes.no_demandes'.tr(),
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _DemandeCard(
            item: item,
            onTap: () {
              // TODO: When API connected, pass only item.id and load from DemandesRepository
              // On passe un Map simple pour éviter les imports croisés entre fichiers
              Navigator.of(context).pushNamed(
                AppRoutes.clientDemandeDetail,
                arguments: {
                  'id': item.id,
                  'titre': item.title,
                  'institution': item.institution,
                  'status': _statusToString(item.status),
                  'reference': 'REQ-2024-00${item.id}',
                  'datesoumission': '${'demande_detail.submitted_on'.tr()} 15/12, 10h00',
                  'dateEstimee': '${'demande_detail.estimated'.tr()} : 17/12',
                  'documentVersion': '${'demande_detail.version'.tr()} 1.1',
                },
              );
            },
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Demande Card Widget
// ---------------------------------------------------------------------------

class _DemandeCard extends StatelessWidget {
  final DemandeItem item;
  final VoidCallback onTap;

  const _DemandeCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
                  item.iconAsset,
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
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.institution} • ${item.date}',
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
            _StatusBadge(status: item.status),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status Badge Widget
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final DemandeStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: config.textColor,
        ),
      ),
    );
  }

  _StatusConfig _statusConfig(DemandeStatus status) {
    switch (status) {
      case DemandeStatus.brouillon:
        return _StatusConfig(
          label: 'demandes.draft'.tr(),
          textColor: AppColors.statusDraft,
          bgColor: AppColors.statusDraftLight,
        );
      case DemandeStatus.enAttente:
        return _StatusConfig(
          label: 'demandes.pending'.tr(),
          textColor: AppColors.statusPending,
          bgColor: AppColors.statusPendingLight,
        );
      case DemandeStatus.enCours:
        return _StatusConfig(
          label: 'demandes.in_progress'.tr(),
          textColor: AppColors.statusInProgress,
          bgColor: AppColors.statusInProgressLight,
        );
      case DemandeStatus.valide:
        return _StatusConfig(
          label: 'profile.validated'.tr(),
          textColor: AppColors.statusValidated,
          bgColor: AppColors.statusValidatedLight,
        );
      case DemandeStatus.rejete:
        return _StatusConfig(
          label: 'profile.rejected'.tr(),
          textColor: AppColors.statusRejected,
          bgColor: AppColors.statusRejectedLight,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color textColor;
  final Color bgColor;

  const _StatusConfig({
    required this.label,
    required this.textColor,
    required this.bgColor,
  });
}