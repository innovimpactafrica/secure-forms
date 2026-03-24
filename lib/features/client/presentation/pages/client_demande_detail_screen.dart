import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/base_url.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/client/data/models/demande_model.dart';
import 'package:secure_link/features/client/data/repositories/demandes_repository.dart';

class ClientDemandeDetailScreen extends StatefulWidget {
  const ClientDemandeDetailScreen({super.key});

  @override
  State<ClientDemandeDetailScreen> createState() =>
      _ClientDemandeDetailScreenState();
}

class _ClientDemandeDetailScreenState
    extends State<ClientDemandeDetailScreen> {
  final _repo = DemandesRepository();
  DemandeModel? _demande;
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) _load();
  }

  Future<void> _load() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? id;
    if (args is Map) id = args['id']?.toString();

    if (id == null || id.isEmpty) {
      setState(() { _loading = false; _error = 'ID manquant'; });
      return;
    }

    try {
      final token = UserSession.instance.accessToken;
      debugPrint('[DemandeDetail] loading id=$id');
      final demande = await _repo.getRequestById(accessToken: token, id: id);
      debugPrint('[DemandeDetail] submittedForms=${demande.submittedForms.length}');
      debugPrint('[DemandeDetail] requiredDocuments=${demande.requiredDocuments.length}');
      for (final f in demande.submittedForms) {
        debugPrint('[DemandeDetail] pdf label=${f.label} fileName=${f.fileName}');
      }
      for (final d in demande.requiredDocuments) {
        debugPrint('[DemandeDetail] doc id=${d.id} label=${d.label}');
      }
      if (mounted) setState(() { _demande = demande; _loading = false; });
    } catch (e) {
      debugPrint('[DemandeDetail] ERROR: $e');
      if (mounted) setState(() { _loading = false; _error = e.toString().replaceAll('Exception: ', ''); });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              _BackButton(),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.statusRejected, size: 40),
                      const SizedBox(height: 12),
                      Text(_error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                      const SizedBox(height: 16),
                      TextButton(
                          onPressed: () {
                            setState(() { _loading = true; _error = null; });
                            _load();
                          },
                          child: Text('archives.retry'.tr())),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final d = _demande!;
    final status = _parseStatus(d.status);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Zone header blanche ──────────────────────────────
                    Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context, d.formType.isNotEmpty ? d.formType : d.requestNumber, d.organisationName, status),
                          const SizedBox(height: 16),
                          _buildRefRow(d.requestNumber, d.createdAt),
                          const SizedBox(height: 20),
                          _buildStepper(status),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ── PDFs soumis ──────────────────────────────────────
                    if (d.submittedForms.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildDocCard(d),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // ── Documents requis ─────────────────────────────────
                    if (d.requiredDocuments.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: Text(
                          'demande_detail.required_documents'.tr(),
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildRequiredDocsCard(d),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          if (status == _DemandeStatus.valide) _buildDownloadButton(context, d.id),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, String title, String institution, _DemandeStatus status) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 3),
              Text(institution,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _HeaderBadge(status: status),
      ],
    );
  }

  // ── Référence + date ──────────────────────────────────────────────────────

  Widget _buildRefRow(String reference, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(reference,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 3),
        Text('${'demande_detail.submitted_on'.tr()} $date',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  // ── Stepper ───────────────────────────────────────────────────────────────

  Widget _buildStepper(_DemandeStatus status) {
    final steps = _getStepStates(status);
    return Column(
      children: [
        Row(
          children: [
            _StepCircle(state: steps[0].circleState, icon: steps[0].icon),
            Expanded(child: _StepLine(active: steps[0].lineActive)),
            _StepCircle(state: steps[1].circleState, icon: steps[1].icon),
            Expanded(child: _StepLine(active: steps[1].lineActive)),
            _StepCircle(state: steps[2].circleState, icon: steps[2].icon),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 60,
              child: Text('demande_detail.submitted'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ),
            SizedBox(
              width: 60,
              child: Text('demandes.in_progress'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ),
            SizedBox(
              width: 60,
              child: Text('demande_detail.finalized'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ),
          ],
        ),
      ],
    );
  }

  List<_StepData> _getStepStates(_DemandeStatus status) {
    switch (status) {
      case _DemandeStatus.enAttente:
      case _DemandeStatus.rejete:
      case _DemandeStatus.brouillon:
        return [
          _StepData(circleState: _CircleState.active, icon: Icons.edit_outlined, lineActive: false),
          _StepData(circleState: _CircleState.inactive, icon: Icons.access_time, lineActive: false),
          _StepData(circleState: _CircleState.inactive, icon: Icons.check, lineActive: false),
        ];
      case _DemandeStatus.enCours:
        return [
          _StepData(circleState: _CircleState.done, icon: Icons.check, lineActive: true),
          _StepData(circleState: _CircleState.active, icon: Icons.access_time, lineActive: false),
          _StepData(circleState: _CircleState.inactive, icon: Icons.check, lineActive: false),
        ];
      case _DemandeStatus.valide:
        return [
          _StepData(circleState: _CircleState.done, icon: Icons.check, lineActive: true),
          _StepData(circleState: _CircleState.done, icon: Icons.check, lineActive: true),
          _StepData(circleState: _CircleState.done, icon: Icons.check, lineActive: false),
        ];
    }
  }

  // ── Card PDFs soumis ──────────────────────────────────────────────────────

  Widget _buildDocCard(DemandeModel d) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDivider),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowDark, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: d.submittedForms.asMap().entries.map((entry) {
          final i = entry.key;
          final f = entry.value;
          final sub = f.fileName;
          final isGeneric = sub.isEmpty || sub == 'document.pdf.pdf' || sub == f.label;
          return Column(
            children: [
              if (i > 0) const Divider(height: 1, color: AppColors.borderDivider),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.gray,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/earmark-text.svg',
                          width: 22,
                          height: 22,
                          colorFilter: const ColorFilter.mode(
                              AppColors.textSecondary, BlendMode.srcIn),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.label.isNotEmpty ? f.label : f.fileName,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark),
                          ),
                          if (!isGeneric) ...[
                            const SizedBox(height: 2),
                            Text(sub,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.statusValidated.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '● ${'demande_detail.complete'.tr()}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.statusValidated),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Card documents requis ─────────────────────────────────────────────────

  Widget _buildRequiredDocsCard(DemandeModel d) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDivider),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowDark, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: d.requiredDocuments.asMap().entries.map((entry) {
          final i = entry.key;
          final doc = entry.value;
          return Column(
            children: [
              if (i > 0) const Divider(height: 1, color: AppColors.borderDivider),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.gray,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/earmark-text.svg',
                          width: 22,
                          height: 22,
                          colorFilter: const ColorFilter.mode(
                              AppColors.textSecondary, BlendMode.srcIn),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        doc.label,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.statusValidated.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'demande_detail.verified'.tr(),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.statusValidated),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Bouton télécharger PDF ────────────────────────────────────────────────

  Widget _buildDownloadButton(BuildContext context, String id) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: GestureDetector(
          onTap: () {
            debugPrint('[DemandeDetail] PDF URL: ${BaseUrl.requestPdf(id)}');
          },
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.download_outlined,
                    color: AppColors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'demande_detail.download_pdf'.tr(),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _DemandeStatus _parseStatus(String raw) {
    switch (raw.toUpperCase()) {
      case 'EN_COURS':        return _DemandeStatus.enCours;
      case 'VALIDEE':         return _DemandeStatus.valide;
      case 'REJETEE':         return _DemandeStatus.rejete;
      case 'BROUILLON':       return _DemandeStatus.brouillon;
      case 'VALIDATION_FINALE': return _DemandeStatus.valide;
      default:                return _DemandeStatus.enAttente;
    }
  }
}

// ---------------------------------------------------------------------------
// Bouton retour simple
// ---------------------------------------------------------------------------

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
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
    );
  }
}

// ---------------------------------------------------------------------------
// Stepper
// ---------------------------------------------------------------------------

enum _DemandeStatus { enAttente, enCours, valide, rejete, brouillon }
enum _CircleState { active, done, inactive }

class _StepData {
  final _CircleState circleState;
  final IconData icon;
  final bool lineActive;
  const _StepData({required this.circleState, required this.icon, required this.lineActive});
}

class _StepCircle extends StatelessWidget {
  final _CircleState state;
  final IconData icon;
  const _StepCircle({required this.state, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isActive = state != _CircleState.inactive;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryDark : AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppColors.primaryDark : AppColors.borderGray,
          width: 2,
        ),
      ),
      child: Icon(icon,
          size: 16,
          color: isActive ? AppColors.white : AppColors.borderGray),
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool active;
  const _StepLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      color: active ? AppColors.primaryDark : AppColors.borderGray,
    );
  }
}

// ---------------------------------------------------------------------------
// Badge header
// ---------------------------------------------------------------------------

class _HeaderBadge extends StatelessWidget {
  final _DemandeStatus status;
  const _HeaderBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case _DemandeStatus.enAttente:
        return _badge('demandes.pending'.tr(), AppColors.statusPending, AppColors.statusPending.withValues(alpha: 0.15));
      case _DemandeStatus.enCours:
        return _badge('demandes.in_progress'.tr(), AppColors.statusInProgress, AppColors.statusInProgress.withValues(alpha: 0.15));
      case _DemandeStatus.valide:
        return _badge('profile.validated'.tr(), AppColors.statusValidated, AppColors.statusValidated.withValues(alpha: 0.15));
      case _DemandeStatus.rejete:
        return _badge('profile.rejected'.tr(), AppColors.statusRejected, AppColors.statusRejected.withValues(alpha: 0.15));
      case _DemandeStatus.brouillon:
        return _badge('demandes.draft'.tr(), AppColors.statusDraft, AppColors.statusDraft.withValues(alpha: 0.15));
    }
  }

  Widget _badge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}
