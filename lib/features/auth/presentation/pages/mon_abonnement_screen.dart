import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';
import 'package:quick_forms/core/utils/user_session.dart';
import 'package:quick_forms/features/client/data/models/plan_model.dart';
import 'package:quick_forms/features/client/data/services/subscription_service.dart';
import 'package:quick_forms/features/client/domain/bloc/plans_bloc/plans_bloc.dart';
import 'package:quick_forms/features/client/domain/bloc/plans_bloc/plans_event.dart';
import 'package:quick_forms/features/client/domain/bloc/plans_bloc/plans_state.dart';

class MonAbonnementScreen extends StatefulWidget {
  const MonAbonnementScreen({super.key});

  @override
  State<MonAbonnementScreen> createState() => _MonAbonnementScreenState();
}

class _MonAbonnementScreenState extends State<MonAbonnementScreen> {
  late final PlansBloc _bloc;
  String? _activePlanId;

  @override
  void initState() {
    super.initState();
    _bloc = PlansBloc()..add(const LoadPlansEvent());
    _loadActivePlan();
  }

  Future<void> _loadActivePlan() async {
    final sub = await SubscriptionService().getEffectiveSubscription(
      accessToken: UserSession.instance.accessToken,
    );
    if (mounted && sub != null && sub.isActive) {
      setState(() => _activePlanId = sub.planId);
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
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
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppConstants.paddingXLarge, AppConstants.paddingMedium,
                    AppConstants.paddingXLarge, AppConstants.paddingSmall),
                child: Text(
                  'plans.available'.tr(),
                  style: const TextStyle(
                    fontFamily: AppConstants.fontFamilySofiaSans,
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.w600,
                    color: AppColors.planTitleColor,
                  ),
                ),
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingXLarge,
        AppConstants.paddingLarge,
        AppConstants.paddingXLarge,
        AppConstants.paddingSmall,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: AppConstants.avatarSizeSmall,
              height: AppConstants.avatarSizeSmall,
              decoration: BoxDecoration(
                color: AppColors.backArrowColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: const Icon(Icons.arrow_back,
                  color: AppColors.white, size: AppConstants.iconSizeMedium),
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'plans.my_subscription_title'.tr(),
                style: const TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPureBlack,
                ),
              ),
              Text(
                'plans.my_subscription_subtitle'.tr(),
                style: const TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontSize: AppConstants.fontSizeRegular,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<PlansBloc, PlansState>(
      builder: (context, state) {
        if (state is PlansLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.backArrowColor));
        }
        if (state is PlansError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.message,
                    style: const TextStyle(color: AppColors.statusRejected)),
                const SizedBox(height: AppConstants.paddingLarge),
                GestureDetector(
                  onTap: () => _bloc.add(const LoadPlansEvent()),
                  child: Text('plans.retry'.tr(),
                      style: const TextStyle(
                          color: AppColors.backArrowColor,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        }
        if (state is PlansLoaded) {
          if (state.plans.isEmpty) {
            return Center(
              child: Text('plans.no_plans'.tr(),
                  style: const TextStyle(color: AppColors.textSecondary)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingXLarge, AppConstants.paddingMedium,
                AppConstants.paddingXLarge, AppConstants.paddingXLarge),
            itemCount: state.plans.length,
            itemBuilder: (context, index) {
              final plan = state.plans[index];
              final isActive = plan.id == _activePlanId;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: AppConstants.paddingLarge,
                  top: isActive ? 22 : 0, // ✅ espace pour le badge
                ),
                child: _AbonnementCard(
                  plan: plan,
                  isActive: isActive,
                  onSuspend: () => _showSuspendModal(context),
                  onSwitch: () {
                    _showPaiementModal(context, plan);
                  },
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showSuspendModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXLarge)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewPadding.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppConstants.paddingXLarge,
            AppConstants.paddingXLarge,
            AppConstants.paddingXLarge,
            bottom + AppConstants.paddingXLarge,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'plans.suspend_title'.tr(),
                style: const TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontWeight: FontWeight.w700,
                  fontSize: AppConstants.fontSizeXXLarge,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                'plans.suspend_message'.tr(),
                style: const TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontWeight: FontWeight.w400,
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppConstants.paddingXLarge),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        child: Text(
                          'plans.cancel'.tr(),
                          style: const TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontWeight: FontWeight.w600,
                            fontSize: AppConstants.fontSizeLarge,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: AppConstants.borderWidthThin,
                    height: AppConstants.paddingXLarge,
                    color: AppColors.divider,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        // TODO: connecter à l'API pour suspendre
                      },
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        child: Text(
                          'plans.confirm'.tr(),
                          style: const TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontWeight: FontWeight.w600,
                            fontSize: AppConstants.fontSizeLarge,
                            color: AppColors.backArrowColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPaiementModal(BuildContext context, PlanModel plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXLarge)),
      ),
      builder: (_) => _PaiementModal(plan: plan),
    );
  }
}

// ---------------------------------------------------------------------------
// Card Abonnement
// ---------------------------------------------------------------------------

class _AbonnementCard extends StatelessWidget {
  final PlanModel plan;
  final bool isActive;
  final VoidCallback onSuspend;
  final VoidCallback onSwitch;

  const _AbonnementCard({
    required this.plan,
    required this.isActive,
    required this.onSuspend,
    required this.onSwitch,
  });

  String _subtitle() {
    switch (plan.clientTypes) {
      case 'LOCAL':
        return 'plans.local'.tr();
      case 'ORGANISATION':
        return 'plans.organisation'.tr();
      case 'INTERNATIONAL':
        return 'plans.international'.tr();
      default:
        return plan.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ✅ margin top pour laisser de la place au badge
        Container(
          margin: EdgeInsets.only(top: isActive ? 18 : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(
                color: isActive
                    ? AppColors.backArrowColor
                    : AppColors.statTotalBorder,
                width: isActive
                    ? AppConstants.borderWidthThick
                    : AppConstants.borderWidthThin,
              ),
              boxShadow: isActive
                  ? const [
                      BoxShadow(
                        color: AppColors.planCardSelectedShadow,
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            // ✅ padding top plus grand quand actif pour ne pas masquer contenu sous le badge
            padding: EdgeInsets.fromLTRB(
              AppConstants.paddingLarge,
              isActive ? 32 : AppConstants.paddingLarge,
              AppConstants.paddingLarge,
              AppConstants.paddingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        plan.name,
                        style: const TextStyle(
                          fontFamily: AppConstants.fontFamilySofiaSans,
                          fontSize: AppConstants.fontSizeXLarge,
                          fontWeight: FontWeight.w700,
                          color: AppColors.planTitleColor,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          plan.formattedPrice,
                          style: const TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontSize: AppConstants.fontSizeLarge,
                            fontWeight: FontWeight.w700,
                            color: AppColors.backArrowColor,
                          ),
                        ),
                        Text(
                          'plans.per_month'.tr(),
                          style: const TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontSize: AppConstants.fontSizeRegular,
                            color: AppColors.textMediumGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _subtitle(),
                  style: const TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    fontSize: AppConstants.fontSizeRegular,
                    color: AppColors.textMediumGray,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                if (plan.services.isNotEmpty)
                  ...plan.services.map((s) => _FeatureItem(
                        text: s.maxRequests > 0
                            ? '${s.serviceName} (max ${s.maxRequests})'
                            : s.serviceName,
                        available: s.isActive,
                      )),
                const SizedBox(height: AppConstants.paddingLarge),
                if (isActive)
                  SizedBox(
                    width: double.infinity,
                    height: AppConstants.buttonHeight,
                    child: OutlinedButton(
                      onPressed: onSuspend,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.backArrowColor,
                            width: AppConstants.borderWidthThin),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusMedium),
                        ),
                      ),
                      child: Text(
                        'plans.suspend'.tr(),
                        style: const TextStyle(
                          fontFamily: AppConstants.fontFamilySofiaSans,
                          color: AppColors.backArrowColor,
                          fontWeight: FontWeight.w600,
                          fontSize: AppConstants.fontSizeLarge,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: AppConstants.buttonHeight,
                    child: ElevatedButton(
                      onPressed: onSwitch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.backArrowColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusMedium),
                        ),
                      ),
                      child: Text(
                        '${'plans.switch_to'.tr()} ${plan.name}',
                        style: const TextStyle(
                          fontFamily: AppConstants.fontFamilySofiaSans,
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: AppConstants.fontSizeLarge,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Badge ACTIF centré sur le bord supérieur
        if (isActive)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: FractionalTranslation(
                translation: const Offset(0, -0.5),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.planCheckGreen,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusRound),
                  ),
                  child: Text(
                    'plans.active_badge'.tr(),
                    style: const TextStyle(
                      fontFamily: AppConstants.fontFamilyInter,
                      fontSize: AppConstants.fontSizeSmall,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;
  final bool available;
  const _FeatureItem({required this.text, this.available = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            available ? Icons.check_circle : Icons.cancel_outlined,
            size: AppConstants.iconSizeSmall,
            color:
                available ? AppColors.planCheckGreen : AppColors.textSecondary,
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontSize: AppConstants.fontSizeMedium,
                color: available ? AppColors.textDark : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Modal Paiement
// ---------------------------------------------------------------------------

class _PaiementModal extends StatefulWidget {
  final PlanModel plan;
  const _PaiementModal({required this.plan});

  @override
  State<_PaiementModal> createState() => _PaiementModalState();
}

class _PaiementModalState extends State<_PaiementModal> {
  _PaymentMethod _selected = _PaymentMethod.wave;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppConstants.paddingMedium),
            Center(
              child: Container(
                width: AppConstants.modalHandleWidth,
                height: AppConstants.modalHandleHeight,
                decoration: BoxDecoration(
                  color: AppColors.paymentModalHandle,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusRound),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            Text(
              'plans.payment_title'.tr(),
              style: const TextStyle(
                fontFamily: AppConstants.fontFamilySofiaSans,
                fontSize: AppConstants.fontSizeXLarge,
                fontWeight: FontWeight.w700,
                color: AppColors.planTitleColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingXLarge),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.paymentCardBg,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMedium),
                      border: Border.all(
                          color: AppColors.paymentCardBorder,
                          width: AppConstants.borderWidthThin),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.paymentIconBg,
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusSmall),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/badge.svg',
                              width: AppConstants.iconSizeMedium,
                              height: AppConstants.iconSizeMedium,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.plan.name,
                                  style: const TextStyle(
                                    fontFamily: AppConstants.fontFamilySofiaSans,
                                    fontSize: AppConstants.fontSizeMedium,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.paymentCardBorder,
                                  )),
                              Text(
                                widget.plan.billingPeriod == 'YEARLY'
                                    ? 'plans.billing_yearly'.tr()
                                    : 'plans.billing_monthly'.tr(),
                                style: const TextStyle(
                                  fontFamily: AppConstants.fontFamilyInter,
                                  fontSize: AppConstants.fontSizeRegular,
                                  color: AppColors.paymentBillingText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(widget.plan.formattedPrice,
                            style: const TextStyle(
                              fontFamily: AppConstants.fontFamilySofiaSans,
                              fontSize: AppConstants.fontSizeLarge,
                              fontWeight: FontWeight.w700,
                              color: AppColors.paymentCardBorder,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.paymentInfoBg,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                    child: Text(
                      'plans.payment_info'.tr(),
                      style: const TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontSize: AppConstants.fontSizeMedium,
                        color: AppColors.paymentInfoText,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  _PaymentMethodTile(
                    label: 'plans.wave'.tr(),
                    imagePath: 'assets/images/wave.png',
                    isSelected: _selected == _PaymentMethod.wave,
                    onTap: () =>
                        setState(() => _selected = _PaymentMethod.wave),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  _PaymentMethodTile(
                    label: 'plans.orange_money'.tr(),
                    imagePath: 'assets/images/om.png',
                    isSelected: _selected == _PaymentMethod.orangeMoney,
                    onTap: () => setState(
                        () => _selected = _PaymentMethod.orangeMoney),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  _PaymentMethodTile(
                    label: 'plans.card'.tr(),
                    imagePath: 'assets/images/cb.png',
                    isSelected: _selected == _PaymentMethod.card,
                    onTap: () =>
                        setState(() => _selected = _PaymentMethod.card),
                  ),
                  const SizedBox(height: AppConstants.paddingXLarge),
                  SizedBox(
                    width: double.infinity,
                    height: AppConstants.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: connecter au paiement
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.backArrowColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusRound),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('plans.confirm_pay'.tr(),
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilySofiaSans,
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: AppConstants.fontSizeLarge,
                              )),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward,
                              color: AppColors.white,
                              size: AppConstants.iconSizeMedium),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline,
                          size: AppConstants.iconSizeSmall,
                          color: AppColors.paymentSecureText),
                      const SizedBox(width: 4),
                      Text('plans.secure'.tr(),
                          style: const TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontSize: AppConstants.fontSizeRegular,
                            color: AppColors.paymentSecureText,
                          )),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingXLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PaymentMethod { wave, orangeMoney, card }

class _PaymentMethodTile extends StatelessWidget {
  final String label;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.paymentMethodSelectedBg
              : AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: isSelected
                ? AppColors.paymentCardBorder
                : AppColors.paymentMethodUnselectedBorder,
            width: AppConstants.borderWidthThin,
          ),
        ),
        child: Row(
          children: [
            Image.asset(imagePath,
                width: AppConstants.iconSizeXLarge,
                height: AppConstants.iconSizeXLarge,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.payment,
                    size: AppConstants.iconSizeXLarge,
                    color: AppColors.textSecondary)),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                    fontFamily: AppConstants.fontFamilySofiaSans,
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.w500,
                    color: AppColors.planTitleColor,
                  )),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.paymentCardBorder
                    : AppColors.white,
                border: Border.all(
                  color: isSelected
                      ? AppColors.paymentCardBorder
                      : AppColors.paymentMethodUnselectedCircle,
                  width: isSelected
                      ? AppConstants.borderWidthThin
                      : AppConstants.borderWidthThick,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.circle, size: 10, color: AppColors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}