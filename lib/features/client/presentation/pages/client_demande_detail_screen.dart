import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/utils/base_url.dart';
import 'package:secure_link/core/utils/authenticated_http_client.dart';
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
    final d = _demande!;
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
            // Soumise
            SizedBox(
              width: 60,
              child: Text('demande_detail.submitted'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ),
            // En cours
            SizedBox(
              width: 60,
              child: Column(
                children: [
                  if (status == _DemandeStatus.enAttente)
                    Image.asset('assets/images/sablier.png', width: 24, height: 24),
                  Text('demandes.in_progress'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  if (d.inProgressAt != null)
                    Text(d.inProgressAt!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            // Finalisé
            SizedBox(
              width: 60,
              child: Column(
                children: [
                  if (status == _DemandeStatus.enAttente || status == _DemandeStatus.enCours)
                    Image.asset('assets/images/sablier.png', width: 24, height: 24),
                  Text('demande_detail.finalized'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  if (d.finalizedAt != null)
                    Text(d.finalizedAt!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ],
              ),
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
              InkWell(
                onTap: f.pdfUrl.isNotEmpty
                    ? () => _openViewer(
                          context,
                          label: f.label.isNotEmpty ? f.label : f.fileName,
                          url: f.pdfUrl,
                          useToken: true,
                          requestId: d.id,
                          formIndex: i,
                        )
                    : null,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
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
                      if (f.pdfUrl.isNotEmpty)
                        const Icon(Icons.visibility_outlined,
                            size: 18, color: AppColors.primary)
                      else
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
              InkWell(
                onTap: doc.id.isNotEmpty
                    ? () {
                        final url = (doc.fileUrl != null && doc.fileUrl!.isNotEmpty)
                            ? doc.fileUrl!
                            : BaseUrl.profileDocumentFile(doc.id);
                        // Tous les endpoints /api/... nécessitent un token
                        // Seules les URLs MinIO (X-Amz-) n'en ont pas besoin
                        final useToken = !url.contains('X-Amz-');
                        _openViewer(context, label: doc.label, url: url, useToken: useToken);
                      }
                    : null,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
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
                      const Icon(Icons.visibility_outlined,
                          size: 18, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Ouvrir le viewer ──────────────────────────────────────────────────────

  void _openViewer(BuildContext context, {required String label, required String url, required bool useToken, String? requestId, int formIndex = 0}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _DocumentViewerPage(label: label, url: url, useToken: useToken, requestId: requestId, formIndex: formIndex),
    ));
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

// ---------------------------------------------------------------------------
// Page plein écran — viewer document (image ou PDF)
// ---------------------------------------------------------------------------

class _DocumentViewerPage extends StatefulWidget {
  final String label;
  final String url;
  final bool useToken;
  final String? requestId;
  final int formIndex; // index dans submittedForms pour le fallback

  const _DocumentViewerPage({
    required this.label,
    required this.url,
    required this.useToken,
    this.requestId,
    this.formIndex = 0,
  });

  @override
  State<_DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<_DocumentViewerPage> {
  // Cache statique partagé entre toutes les instances
  static final Map<String, Uint8List> _cache = {};

  Uint8List? _imageBytes;
  Uint8List? _pdfBytes;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Vérifier le cache d'abord
    final cached = _cache[widget.url];
    if (cached != null) {
      final isPdf = cached.length >= 4 &&
          cached[0] == 0x25 && cached[1] == 0x50 &&
          cached[2] == 0x44 && cached[3] == 0x46;
      if (isPdf) _pdfBytes = cached;
      else _imageBytes = cached;
      _loading = false;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    // Refresh proactif du token avant tout téléchargement
    final token = await AuthenticatedHttpClient.instance.ensureFreshToken();
    try {
      Uint8List bytes;
      final isMinIO = widget.url.contains('X-Amz-');

      if (isMinIO) {
        bytes = await compute(_fetchDirect, widget.url);
      } else {
        bytes = await compute(_fetchWithToken, {
          'url': widget.url,
          'token': token,
        });
      }

      final isPdf = bytes.length >= 4 &&
          bytes[0] == 0x25 && bytes[1] == 0x50 &&
          bytes[2] == 0x44 && bytes[3] == 0x46;

      if (mounted) setState(() {
        if (isPdf) _pdfBytes = bytes;
        else _imageBytes = bytes;
        _cache[widget.url] = bytes;
        _loading = false;
      });
    } catch (e) {
      if (widget.url.contains('X-Amz-') && widget.requestId != null) {
        await _fallbackViaApi(token);
      } else {
        if (mounted) setState(() { _loading = false; _error = e.toString(); });
      }
    }
  }

  Future<void> _fallbackViaApi(String token) async {
    try {
      // Re-refresh au cas où le token aurait expiré entre temps
      final freshToken = await AuthenticatedHttpClient.instance.ensureFreshToken();
      final repo = DemandesRepository();
      final demande = await repo.getRequestById(accessToken: freshToken, id: widget.requestId!);

      // Chercher par index exact d'abord, puis par label, puis premier disponible
      SubmittedFormItem? form;
      if (widget.formIndex < demande.submittedForms.length) {
        final candidate = demande.submittedForms[widget.formIndex];
        if (candidate.pdfUrl.isNotEmpty) form = candidate;
      }
      form ??= demande.submittedForms
          .where((f) => f.label == widget.label && f.pdfUrl.isNotEmpty)
          .firstOrNull;
      form ??= demande.submittedForms
          .where((f) => f.pdfUrl.isNotEmpty)
          .firstOrNull;

      if (form == null || form.pdfUrl.isEmpty) throw Exception('PDF introuvable');

      final freshUrl = form.pdfUrl;
      final isMinIO = freshUrl.contains('X-Amz-');
      Uint8List bytes;
      if (isMinIO) {
        bytes = await compute(_fetchDirect, freshUrl);
      } else {
        bytes = await compute(_fetchWithToken, {'url': freshUrl, 'token': freshToken});
      }

      final isPdf = bytes.length >= 4 &&
          bytes[0] == 0x25 && bytes[1] == 0x50 &&
          bytes[2] == 0x44 && bytes[3] == 0x46;

      if (mounted) setState(() {
        if (isPdf) _pdfBytes = bytes;
        else _imageBytes = bytes;
        _cache[freshUrl] = bytes;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  // Fonctions top-level pour compute (isolate)
  static Future<Uint8List> _fetchWithToken(Map<String, String> args) async {
    final rawUrl = args['url']!;
    final token = args['token']!;
    debugPrint('[Viewer] GET $rawUrl');
    final res = await http.get(
      Uri.parse(rawUrl),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 30));
    debugPrint('[Viewer] status=${res.statusCode} bytes=${res.bodyBytes.length}');
    if (res.statusCode != 200) {
      debugPrint('[Viewer] error body=${res.body}');
      throw Exception('Erreur ${res.statusCode}');
    }
    return res.bodyBytes;
  }

  static Future<Uint8List> _fetchDirect(String url) async {
    final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20));
    if (res.statusCode == 403 || res.statusCode == 404) {
      throw Exception('EXPIRED_${res.statusCode}');
    }
    if (res.statusCode != 200) throw Exception('Erreur ${res.statusCode}');
    return res.bodyBytes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          widget.label,
          style: const TextStyle(
            fontFamily: AppConstants.fontFamilySofiaSans,
            fontWeight: FontWeight.w600,
            fontSize: AppConstants.fontSizeLarge,
            color: AppColors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.statusRejected, size: 48),
                        const SizedBox(height: 12),
                        Text(_error!,
                            style: const TextStyle(
                                color: AppColors.white, fontSize: 14),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : _pdfBytes != null
                  ? SfPdfViewer.memory(_pdfBytes!)
                  : _imageBytes != null
                      ? InteractiveViewer(
                          minScale: 0.8,
                          maxScale: 4.0,
                          child: Center(
                            child: Image.memory(
                              _imageBytes!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.insert_drive_file_outlined,
                                  size: 80, color: AppColors.primary),
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.insert_drive_file_outlined,
                              size: 80, color: AppColors.primary),
                        ),
    );
  }
}
