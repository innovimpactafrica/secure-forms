import 'package:flutter/material.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';

// ─────────────────────────────────────────────────────────────────
// MODÈLE DE NOTIFICATION
// ─────────────────────────────────────────────────────────────────
enum NotifType { urgent, success, warning, info }

class NotifItem {
  final String title;
  final String subtitle;
  final String time;
  final NotifType type;

  const NotifItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
  });
}

// ─────────────────────────────────────────────────────────────────
// DONNÉES SIMULÉES — TODO: remplacer par API GET /notifications
// ─────────────────────────────────────────────────────────────────
final _notifsTodayMock = [
  const NotifItem(
    title: 'Carte d\'identité expire bientôt',
    subtitle: 'Votre carte d\'identité expire dans 15 jours renouvelez des maintenant.',
    time: 'Aujourd\'hui, 07:35',
    type: NotifType.urgent,
  ),
  const NotifItem(
    title: 'Permis de conduire validé',
    subtitle: 'Votre permis de conduire a été validé avec succès. score: 98%',
    time: 'Aujourd\'hui, 07:55',
    type: NotifType.success,
  ),
  const NotifItem(
    title: 'Vérification en attente',
    subtitle: 'Validation en cours pour votre ouverture de compte SUNU Banque',
    time: 'Hier, 07:35',
    type: NotifType.warning,
  ),
];

final _notifsYesterdayMock = [
  const NotifItem(
    title: 'Permis de conduire expire bientôt',
    subtitle: 'Votre permis de conduire expire dans 30 jours renouvelez des maintenant.',
    time: 'Hier, 07:35',
    type: NotifType.urgent,
  ),
];

// ─────────────────────────────────────────────────────────────────
// ÉCRAN NOTIFICATIONS
// ─────────────────────────────────────────────────────────────────
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NotifItem> _filter(List<NotifItem> items) {
    if (_searchQuery.isEmpty) return items;
    return items
        .where((n) =>
            n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            n.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final todayFiltered = _filter(_notifsTodayMock);
    final yesterdayFiltered = _filter(_notifsYesterdayMock);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _NotifHeader(),
            // ── Barre de recherche ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.greyShade100,
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(color: AppColors.greyShade200),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search,
                        color: AppColors.greyShade500, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontSize: AppConstants.fontSizeMedium,
                          color: AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Rechercher une demande',
                          hintStyle: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontSize: AppConstants.fontSizeMedium,
                            color: AppColors.greyShade500,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── Liste ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  if (todayFiltered.isNotEmpty) ...[
                    _SectionLabel(label: 'Aujourd\'hui'),
                    const SizedBox(height: 12),
                    ...todayFiltered.map((n) => _NotifCard(item: n)),
                  ],
                  if (yesterdayFiltered.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionLabel(label: 'Hier'),
                    const SizedBox(height: 12),
                    ...yesterdayFiltered.map((n) => _NotifCard(item: n)),
                  ],
                  if (todayFiltered.isEmpty && yesterdayFiltered.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Text(
                          'Aucune notification trouvée',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontSize: AppConstants.fontSizeMedium,
                            color: AppColors.textSecondary,
                          ),
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

// ─────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────
class _NotifHeader extends StatelessWidget {
  const _NotifHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Mes notifications',
            style: TextStyle(
              fontFamily: AppConstants.fontFamilySofiaSans,
              fontWeight: FontWeight.w700,
              fontSize: AppConstants.fontSizeXXLarge,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// LABEL DE SECTION (Aujourd'hui / Hier)
// ─────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: AppConstants.fontFamilySofiaSans,
        fontWeight: FontWeight.w700,
        fontSize: AppConstants.fontSizeTitle,
        color: AppColors.textDark,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CARD DE NOTIFICATION
// ─────────────────────────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final NotifItem item;
  const _NotifCard({required this.item});

  Color _borderColor() {
    switch (item.type) {
      case NotifType.urgent:
        return AppColors.statusRejected;
      case NotifType.success:
        return AppColors.statusValideGreen;
      case NotifType.warning:
        return AppColors.statusEnAttente;
      case NotifType.info:
        return AppColors.primary;
    }
  }

  Widget _icon() {
    switch (item.type) {
      case NotifType.urgent:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.statusRejected.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '!',
              style: TextStyle(
                fontFamily: AppConstants.fontFamilySofiaSans,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.statusRejected,
              ),
            ),
          ),
        );
      case NotifType.success:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.statusValideGreen.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            color: AppColors.statusValideGreen,
            size: 22,
          ),
        );
      case NotifType.warning:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.statusEnAttente.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            color: AppColors.statusEnAttente,
            size: 22,
          ),
        );
      case NotifType.info:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 22,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border(
          left: BorderSide(color: _borderColor(), width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône
            _icon(),
            const SizedBox(width: 12),
            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre + heure
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontWeight: FontWeight.w600,
                            fontSize: AppConstants.fontSizeMedium,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.time,
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Sous-titre
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamilyInter,
                      fontSize: AppConstants.fontSizeRegular,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
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