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

class SearchBarSection extends StatefulWidget {
  const SearchBarSection({super.key});

  @override
  State<SearchBarSection> createState() => _SearchBarSectionState();
}

class _SearchBarSectionState extends State<SearchBarSection> {
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
          color: AppColors.white,
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
                    color: AppColors.textBlack87),
                decoration: InputDecoration(
                  hintText: 'home.search_placeholder'.tr(),
                  hintStyle: TextStyle(
                      fontFamily: AppConstants.fontFamilyInter,
                      fontSize: AppConstants.fontSizeMedium,
                      color: AppColors.greyShade500,
                      fontWeight: FontWeight.w400),
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
                      color: AppColors.primaryDark, shape: BoxShape.circle),
                  child: Icon(Icons.arrow_forward,
                      color: AppColors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentDemandesSection extends StatelessWidget {
  const RecentDemandesSection({super.key});

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
              Text('home.recent_requests'.tr(),
                  style: TextStyle(
                      fontFamily: AppConstants.fontFamilySofiaSans,
                      fontWeight: FontWeight.w500,
                      fontSize: AppConstants.fontSizeTitle,
                      color: AppColors.textBlack87)),
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.clientDemandes),
                child: Row(
                  children: [
                    Text('home.see_all'.tr(),
                        style: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontWeight: FontWeight.bold,
                            fontSize: AppConstants.fontSizeMedium,
                            color: AppColors.primary)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios,
                        size: AppConstants.fontSizeSmall,
                        color: AppColors.primary),
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
                        child: CircularProgressIndicator(strokeWidth: 2)));
              }
              if (state is DemandesError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(state.message,
                      style: TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontSize: AppConstants.fontSizeRegular,
                          color: AppColors.statusRejected)),
                );
              }
              if (state is RecentDemandesLoaded) {
                if (state.demandes.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('demandes.no_demandes'.tr(),
                        style: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontSize: AppConstants.fontSizeRegular,
                            color: AppColors.textSecondary)),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.demandes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      RecentDemandeCard(demande: state.demandes[index]),
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

class RecentDemandeCard extends StatelessWidget {
  final DemandeModel demande;
  const RecentDemandeCard({super.key, required this.demande});

  @override
  Widget build(BuildContext context) {
    final statusCfg = _statusConfig(demande.status);
    final title =
        demande.formType.isNotEmpty ? demande.formType : demande.requestNumber;
    final org = demande.organisationName;
    final date = demande.createdAt;
    final subtitle =
        [if (org.isNotEmpty) org, if (date.isNotEmpty) date].join(' • ');

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.clientDemandeDetail,
          arguments: {'id': demande.id}),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDivider),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadowDark,
                blurRadius: 6,
                offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: AppColors.grayLight, shape: BoxShape.circle),
              child: Center(
                  child: SvgPicture.asset('assets/icons/icone.svg',
                      width: 16, height: 16)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark),
                      overflow: TextOverflow.ellipsis),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: statusCfg.bgColor,
                  borderRadius: BorderRadius.circular(20)),
              child: Text(statusCfg.label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusCfg.textColor)),
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
        return _StatusCfg('demandes.pending'.tr(), AppColors.statusPending,
            AppColors.statusPendingLight);
      case 'EN_COURS':
        return _StatusCfg('demandes.in_progress'.tr(),
            AppColors.statusInProgress, AppColors.statusInProgressLight);
      case 'VALIDEE':
      case 'VALIDATION_FINALE':
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
