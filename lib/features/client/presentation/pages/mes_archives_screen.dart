import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_colors.dart';

// ---------------------------------------------------------------------------
// Model temporaire
// TODO: Remplacer par ArchiveModel depuis data/models/ lors de l'intégration API
// ---------------------------------------------------------------------------

enum ArchiveStatus { tous, brouillon, enCours, valide, rejete }

class ArchiveItem {
  final String id;
  final String titre;
  final String institution;
  final String date;
  final ArchiveStatus status;
  final String iconAsset;

  const ArchiveItem({
    required this.id,
    required this.titre,
    required this.institution,
    required this.date,
    required this.status,
    required this.iconAsset,
  });
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class MesArchivesScreen extends StatefulWidget {
  const MesArchivesScreen({super.key});

  @override
  State<MesArchivesScreen> createState() => _MesArchivesScreenState();
}

class _MesArchivesScreenState extends State<MesArchivesScreen> {
  // TODO: Replace with BLoC state – ArchivesBloc
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();

  // TODO: Replace with data from ArchivesRepository
  final List<ArchiveItem> _allArchives = const [
    ArchiveItem(
      id: '1',
      titre: 'Ouverture de compte',
      institution: 'Banque Nationale',
      date: '18/12/2025',
      status: ArchiveStatus.valide,
      iconAsset: 'assets/icons/logo.svg',
    ),
    ArchiveItem(
      id: '2',
      titre: 'Demande de virement',
      institution: 'Banque Nationale',
      date: '12/12/2025',
      status: ArchiveStatus.rejete,
      iconAsset: 'assets/icons/logo (1).svg',
    ),
    ArchiveItem(
      id: '3',
      titre: 'Acte de vente',
      institution: 'Notaire X',
      date: '05/12/2025',
      status: ArchiveStatus.enCours,
      iconAsset: 'assets/icons/logo.svg',
    ),
    ArchiveItem(
      id: '4',
      titre: 'Demande de prêt',
      institution: 'Crédit Moderne',
      date: '12/11/2025',
      status: ArchiveStatus.valide,
      iconAsset: 'assets/icons/logo.svg',
    ),
  ];

  static const List<String> _filterLabels = [
    'Tous',
    'Brouillon',
    'En cours',
    'Validés',
    'Rejetés',
  ];

  List<ArchiveItem> get _filteredArchives {
    // TODO: Move filtering logic to ArchivesBloc when API connected
    final query = _searchController.text.toLowerCase();
    List<ArchiveItem> list = _allArchives;

    if (_selectedFilter != 0) {
      final statusMap = {
        1: ArchiveStatus.brouillon,
        2: ArchiveStatus.enCours,
        3: ArchiveStatus.valide,
        4: ArchiveStatus.rejete,
      };
      list =
          list.where((a) => a.status == statusMap[_selectedFilter]).toList();
    }

    if (query.isNotEmpty) {
      list = list
          .where((a) =>
              a.titre.toLowerCase().contains(query) ||
              a.institution.toLowerCase().contains(query))
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
            // TODO: Wrap with BlocBuilder<ArchivesBloc, ArchivesState>
            Expanded(child: _buildArchivesList()),
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
              child: const Icon(Icons.arrow_back,
                  color: AppColors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mes archives',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Suivez et gérer mes demandes',
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
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textDark),
                decoration: const InputDecoration(
                  hintText: 'Rechercher une demande',
                  hintStyle: TextStyle(
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

  // -------------------------------------------------------------------------
  // Filter bar
  // -------------------------------------------------------------------------

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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryDark
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _filterLabels[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: isSelected
                        ? AppColors.white
                        : AppColors.textSecondary,
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
  // Archives list
  // -------------------------------------------------------------------------

  Widget _buildArchivesList() {
    final items = _filteredArchives;

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Aucune archive trouvée',
          style: TextStyle(
              fontSize: 14, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ArchiveCard(item: items[index]),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Archive Card Widget
// ---------------------------------------------------------------------------

class _ArchiveCard extends StatelessWidget {
  final ArchiveItem item;

  const _ArchiveCard({required this.item});

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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Ligne 1 : icône + titre + badge statut ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                // Icône SVG dans cercle gris
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.gray,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      item.iconAsset,
                      width: 28,
                      height: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Titre + institution • date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.titre,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.institution} • ${item.date}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Badge statut
                _StatusText(status: item.status),
              ],
            ),
          ),

          // Séparateur
          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // ── Ligne 2 : actions Voir / Télécharger / Partager ──
          SizedBox(
            height: 44,
            child: Row(
              children: [
                // Voir
                Expanded(
                  child: GestureDetector(
                    // TODO: Implémenter l'aperçu du document via le service PDF
                    onTap: () {},
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.remove_red_eye_outlined,
                            size: 16, color: AppColors.textSecondary),
                        SizedBox(width: 5),
                        Text(
                          'Voir',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Séparateur vertical
                Container(
                    width: 1, height: 20, color: const Color(0xFFEEEEEE)),
                // Télécharger
                Expanded(
                  child: GestureDetector(
                    // TODO: Implémenter le téléchargement via le service dédié
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/download.png',
                          width: 16,
                          height: 16,
                         // color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Télécharger',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Séparateur vertical
                Container(
                    width: 1, height: 20, color: const Color(0xFFEEEEEE)),
                // Partager
                Expanded(
                  child: GestureDetector(
                    // TODO: Implémenter le partage via share_plus
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/share.png',
                          width: 16,
                          height: 16,
                         // color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Partager',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
// Status text widget
// ---------------------------------------------------------------------------

class _StatusText extends StatelessWidget {
  final ArchiveStatus status;

  const _StatusText({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: config.textColor,
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig() {
    switch (status) {
      case ArchiveStatus.valide:
        return _StatusConfig(
          label: 'Validé',
          textColor: AppColors.statusValidated,
          bgColor: AppColors.statusValidatedLight,
        );
      case ArchiveStatus.rejete:
        return _StatusConfig(
          label: 'Rejeté',
          textColor: AppColors.statusRejected,
          bgColor: AppColors.statusRejectedLight,
        );
      case ArchiveStatus.enCours:
        return _StatusConfig(
          label: 'En cours',
          textColor: AppColors.statusInProgress,
          bgColor: AppColors.statusInProgressLight,
        );
      case ArchiveStatus.brouillon:
        return _StatusConfig(
          label: 'Brouillon',
          textColor: AppColors.statusDraft,
          bgColor: AppColors.statusDraftLight,
        );
      case ArchiveStatus.tous:
        return _StatusConfig(
          label: '',
          textColor: AppColors.textSecondary,
          bgColor: Colors.transparent,
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
  });}
