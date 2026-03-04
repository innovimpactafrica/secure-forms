import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';

// ---------------------------------------------------------------------------
// Enums & Models
// TODO: Déplacer dans data/models/demande_detail_model.dart lors de l'intégration API
// ---------------------------------------------------------------------------

enum DemandeDetailStatus { enAttente, enCours, valide, rejete, brouillon }

class DocumentJustificatif {
  final String nom;
  final String taille;
  final bool verifie;

  const DocumentJustificatif({
    required this.nom,
    required this.taille,
    required this.verifie,
  });
}

// ---------------------------------------------------------------------------
// Page principale
// ---------------------------------------------------------------------------

class ClientDemandeDetailScreen extends StatelessWidget {
  const ClientDemandeDetailScreen({super.key});

  Map<String, dynamic> _getArgs(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    return {
      'id': '1',
      'titre': 'Ouverture de compte',
      'institution': 'Banque Nationale',
      'status': 'enAttente',
      'reference': 'REQ-2024-001',
      'datesoumission': 'Soumis le 15/12, 10h00',
      'dateEstimee': 'Estimé : 17/12',
      'documentVersion': 'Version 1.1',
    };
  }

  DemandeDetailStatus _parseStatus(String raw) {
    switch (raw) {
      case 'enCours':   return DemandeDetailStatus.enCours;
      case 'valide':    return DemandeDetailStatus.valide;
      case 'rejete':    return DemandeDetailStatus.rejete;
      case 'brouillon': return DemandeDetailStatus.brouillon;
      default:          return DemandeDetailStatus.enAttente;
    }
  }

  // TODO: charger depuis l'API
  static const List<DocumentJustificatif> _mockDocuments = [
    DocumentJustificatif(nom: "Carte d'identité",    taille: '210 ko', verifie: true),
    DocumentJustificatif(nom: 'Preuve de résidence', taille: '404 ko', verifie: true),
  ];

  @override
  Widget build(BuildContext context) {
    final args          = _getArgs(context);
    final status        = _parseStatus(args['status'] as String);
    final titre         = args['titre'] as String;
    final institution   = args['institution'] as String;
    final reference     = args['reference'] as String;
    final datesoumission= args['datesoumission'] as String;
    final dateEstimee   = args['dateEstimee'] as String;
    final documentVersion = args['documentVersion'] as String;

    // TODO: Remplacer par BlocBuilder<DemandeDetailBloc, DemandeDetailState>
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, institution, status),
                    _buildRefRow(reference, datesoumission, dateEstimee),
                    _buildStepper(status),
                    _buildDocumentCard(titre, documentVersion),
                    _buildDocumentsSection(_mockDocuments),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          if (status == DemandeDetailStatus.valide)
            _buildDownloadButton(context),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Header
  // -------------------------------------------------------------------------

  Widget _buildHeader(
      BuildContext context, String institution, DemandeDetailStatus status) {
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
              child: const Icon(Icons.arrow_back, color: AppColors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'demande_detail.new_request'.tr(),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(institution,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          // Badge statut avec fond coloré
          _HeaderBadge(status: status),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Référence + dates
  // -------------------------------------------------------------------------

  Widget _buildRefRow(
      String reference, String datesoumission, String dateEstimee) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reference,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(datesoumission,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              Text(dateEstimee,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Stepper
  // -------------------------------------------------------------------------

  Widget _buildStepper(DemandeDetailStatus status) {
    final steps = _getStepStates(status);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
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
                width: 56,
                child: Text('demande_detail.submitted'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ),
              SizedBox(
                width: 56,
                child: Text('demandes.in_progress'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ),
              SizedBox(
                width: 56,
                child: Text('demande_detail.finalized'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<_StepData> _getStepStates(DemandeDetailStatus status) {
    switch (status) {
      case DemandeDetailStatus.enAttente:
      case DemandeDetailStatus.rejete:
      case DemandeDetailStatus.brouillon:
        return [
          _StepData(circleState: _CircleState.active, icon: Icons.edit_outlined, lineActive: false),
          _StepData(circleState: _CircleState.inactive, icon: Icons.access_time, lineActive: false),
          _StepData(circleState: _CircleState.inactive, icon: Icons.check, lineActive: false),
        ];
      case DemandeDetailStatus.enCours:
        return [
          _StepData(circleState: _CircleState.done, icon: Icons.check, lineActive: true),
          _StepData(circleState: _CircleState.active, icon: Icons.access_time, lineActive: false),
          _StepData(circleState: _CircleState.inactive, icon: Icons.check, lineActive: false),
        ];
      case DemandeDetailStatus.valide:
        return [
          _StepData(circleState: _CircleState.done, icon: Icons.check, lineActive: true),
          _StepData(circleState: _CircleState.done, icon: Icons.check, lineActive: true),
          _StepData(circleState: _CircleState.done, icon: Icons.check, lineActive: false),
        ];
    }
  }

  // -------------------------------------------------------------------------
  // Card document principal avec field.png comme aperçu
  // -------------------------------------------------------------------------

  Widget _buildDocumentCard(String titre, String version) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderDivider),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadowDark,
                blurRadius: 8,
                offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de la card
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  // Icône earmark-text.svg
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.gray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/earmark-text.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          AppColors.textSecondary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(titre,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark)),
                        Text(version,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.open_in_new,
                      size: 20, color: AppColors.textSecondary),
                ],
              ),
            ),
            // Aperçu avec field.png
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(14)),
              child: Image.asset(
                'assets/images/field.png',
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Section Documents justificatifs
  // -------------------------------------------------------------------------

  Widget _buildDocumentsSection(List<DocumentJustificatif> documents) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'demande_detail.supporting_documents'.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDivider),
            ),
            child: Column(
              children: documents.asMap().entries.map((entry) {
                final isLast = entry.key == documents.length - 1;
                return Column(
                  children: [
                    _DocumentJustificatifItem(doc: entry.value),
                    if (!isLast)
                      Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: AppColors.borderDivider),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Bouton Télécharger PDF (statut Validé uniquement)
  // -------------------------------------------------------------------------

  Widget _buildDownloadButton(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: GestureDetector(
          // TODO: Implémenter le téléchargement PDF via le service dédié
          onTap: () {},
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.download_outlined, color: AppColors.white, size: 20),
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
}

// ---------------------------------------------------------------------------
// Item document justificatif – icône earmark-text.svg
// ---------------------------------------------------------------------------

class _DocumentJustificatifItem extends StatelessWidget {
  final DocumentJustificatif doc;

  const _DocumentJustificatifItem({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icône earmark-text.svg
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.gray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/earmark-text.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.nom,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(doc.taille,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (doc.verifie)
            Text('demande_detail.verified'.tr(),
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Badge header – TOUS avec fond coloré (comme sur la photo)
// ---------------------------------------------------------------------------

class _HeaderBadge extends StatelessWidget {
  final DemandeDetailStatus status;

  const _HeaderBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case DemandeDetailStatus.enAttente:
        return _badge('demandes.pending'.tr(), AppColors.statusPending, AppColors.statusPendingLight);
      case DemandeDetailStatus.enCours:
        return _badge('demandes.in_progress'.tr(), AppColors.statusInProgress, AppColors.statusInProgressLight);
      case DemandeDetailStatus.valide:
        return _badge('profile.validated'.tr(), AppColors.statusValidated, AppColors.statusValidatedLight);
      case DemandeDetailStatus.rejete:
        return _badge('profile.rejected'.tr(), AppColors.statusRejected, AppColors.statusRejectedLight);
      case DemandeDetailStatus.brouillon:
        return _badge('demandes.draft'.tr(), AppColors.statusDraft, AppColors.statusDraftLight);
    }
  }

  Widget _badge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stepper components
// ---------------------------------------------------------------------------

enum _CircleState { active, done, inactive }

class _StepData {
  final _CircleState circleState;
  final IconData icon;
  final bool lineActive;

  const _StepData({
    required this.circleState,
    required this.icon,
    required this.lineActive,
  });
}

class _StepCircle extends StatelessWidget {
  final _CircleState state;
  final IconData icon;

  const _StepCircle({required this.state, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isActive = state == _CircleState.active || state == _CircleState.done;
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