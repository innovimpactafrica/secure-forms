import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';
import 'package:quick_forms/features/client/data/models/notification_model.dart';
import 'package:quick_forms/features/client/domain/bloc/notifications_bloc.dart';
import 'package:quick_forms/features/client/domain/bloc/notifications_event.dart';
import 'package:quick_forms/features/client/domain/bloc/notifications_state.dart';

// ─────────────────────────────────────────────────────────────────
// ÉCRAN NOTIFICATIONS
// ─────────────────────────────────────────────────────────────────
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _NotificationsView();
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Charger si pas encore fait
    final bloc = context.read<NotificationsBloc>();
    if (bloc.state is! NotificationsLoaded) {
      bloc.add(const LoadNotificationsEvent());
    }
    // Marquer toutes comme lues dès l'ouverture → badge à 0
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<NotificationsBloc>()
          .add(const MarkAllNotificationsReadEvent());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NotificationModel> _filter(List<NotificationModel> items) {
    if (_searchQuery.isEmpty) return items;
    return items
        .where((n) =>
            n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            n.message.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _NotifHeader(),
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
                    Icon(Icons.search, color: AppColors.greyShade500, size: 20),
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
                          hintText: 'notifications.search_placeholder'.tr(),
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
              child: BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (context, state) {
                  if (state is NotificationsLoading) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    );
                  }
                  if (state is NotificationsError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              color: AppColors.statusRejected, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => context
                                .read<NotificationsBloc>()
                                .add(const LoadNotificationsEvent()),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'archives.retry'.tr(),
                                style: const TextStyle(
                                    color: AppColors.white, fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is NotificationsLoaded) {
                    return RefreshIndicator(
                      color: AppColors.primaryDark,
                      onRefresh: () async {
                        context
                            .read<NotificationsBloc>()
                            .add(const LoadNotificationsEvent());
                        await Future.delayed(const Duration(milliseconds: 800));
                      },
                      child: _buildList(context, state.notifications),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<NotificationModel> all) {
    final filtered = _filter(all);

    // Grouper par date (aujourd'hui / hier / autres)
    final Map<String, List<NotificationModel>> grouped = {};
    for (final n in filtered) {
      final key = n.formattedDate;
      grouped.putIfAbsent(key, () => []).add(n);
    }

    if (grouped.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Text(
            'notifications.no_notifications'.tr(),
            style: TextStyle(
              fontFamily: AppConstants.fontFamilyInter,
              fontSize: AppConstants.fontSizeMedium,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    // Ordre d'affichage : today → yesterday → autres
    final orderedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 'today') return -1;
        if (b == 'today') return 1;
        if (a == 'yesterday') return -1;
        if (b == 'yesterday') return 1;
        return b.compareTo(a);
      });

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        for (final key in orderedKeys) ...[
          _SectionLabel(label: _sectionTitle(key)),
          const SizedBox(height: 12),
          ...grouped[key]!.map((n) => _NotifCard(item: n)),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  String _sectionTitle(String key) {
    if (key == 'today') return 'notifications.today'.tr();
    if (key == 'yesterday') return 'notifications.yesterday'.tr();
    return key;
  }
}

// ─────────────────────────────────────────────────────────────────
// HEADER — identique à l'original
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
              child: const Icon(Icons.arrow_back,
                  color: AppColors.white, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'notifications.title'.tr(),
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
// LABEL DE SECTION — identique à l'original
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
// CARD DE NOTIFICATION — design identique à l'original
// ─────────────────────────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final NotificationModel item;
  const _NotifCard({required this.item});

  Color _borderColor() {
    switch (item.type.toUpperCase()) {
      case 'DOCUMENT_EXPIRING':
      case 'REQUEST_REJECTED':
        return AppColors.statusRejected;
      case 'REQUEST_VALIDATED':
      case 'DOCUMENT_VALIDATED':
        return AppColors.statusValideGreen;
      case 'VERIFICATION_PENDING':
      case 'DOCUMENT_PENDING':
        return AppColors.statusEnAttente;
      default:
        return AppColors.primary;
    }
  }

  Widget _icon() {
    switch (item.type.toUpperCase()) {
      case 'DOCUMENT_EXPIRING':
      case 'REQUEST_REJECTED':
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
      case 'REQUEST_VALIDATED':
      case 'DOCUMENT_VALIDATED':
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.statusValideGreen.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle_outline,
              color: AppColors.statusValideGreen, size: 22),
        );
      case 'VERIFICATION_PENDING':
      case 'DOCUMENT_PENDING':
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.statusEnAttente.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.warning_amber_rounded,
              color: AppColors.statusEnAttente, size: 22),
        );
      default:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.info_outline, color: AppColors.primary, size: 22),
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
            _icon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontWeight:
                                item.isRead ? FontWeight.w500 : FontWeight.w700,
                            fontSize: AppConstants.fontSizeMedium,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.statusRejected,
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(width: 4),
                      Text(
                        item.timeFormatted,
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
                  Text(
                    item.message,
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
