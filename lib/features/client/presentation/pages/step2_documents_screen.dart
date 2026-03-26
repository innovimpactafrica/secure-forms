import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/auth/domain/bloc/user_bloc.dart';
import 'package:secure_link/features/auth/domain/bloc/user_event.dart';
import 'package:secure_link/features/auth/domain/bloc/user_state.dart';
import 'package:secure_link/features/client/data/models/profile_model.dart';
import 'package:secure_link/features/client/domain/bloc/profile_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/profile_event.dart';
import 'package:secure_link/features/client/domain/bloc/profile_state.dart';
import 'package:secure_link/features/kyc/domain/bloc/kyc_bloc.dart';
import 'package:secure_link/features/kyc/presentation/pages/kyc_step2_face_page.dart';
import 'complete_profile_header.dart';
import 'document_upload_modal.dart';
import 'document_simple_upload_modal.dart';

/// Étape 2 — Upload des documents (connecté à l'API)
class Step2DocumentsScreen extends StatefulWidget {
  const Step2DocumentsScreen({super.key});

  @override
  State<Step2DocumentsScreen> createState() => _Step2DocumentsScreenState();
}

class _Step2DocumentsScreenState extends State<Step2DocumentsScreen> {
  @override
  void initState() {
    super.initState();
    // Toujours recharger pour avoir les données fraîches
    context.read<ProfileBloc>().add(const LoadDocumentTypesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileDocumentUploadedNeedsVerification) {
          // Document identité uploadé → naviguer vers KYC (verif.png + verif2.png)
          _navigateToKyc(context, state.documentType);
        } else if (state is ProfileDocumentUploadedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'profile.document_uploaded_success'.tr(),
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  color: AppColors.white,
                ),
              ),
              backgroundColor: AppColors.statusValideGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else if (state is ProfileDocumentDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'profile.document_deleted'.tr(),
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  color: AppColors.white,
                ),
              ),
              backgroundColor: AppColors.statusEnAttente,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  color: AppColors.white,
                ),
              ),
              backgroundColor: AppColors.statusRejected,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final isLoading = state is ProfileLoading || state is ProfileDocumentUploading;
          final progressValue = _getProgressValue(state);
          final progressLabel = '${(progressValue * 100).toInt()}%';
          final documentTypes = _getDocumentTypes(state);
          final uploadedDocuments = _getUploadedDocuments(state);
          final hasDocuments = uploadedDocuments.isNotEmpty;

          return Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(
              child: Column(
                children: [
                  CompleteProfileHeader(
                    progressValue: progressValue,
                    progressLabel: progressLabel,
                    subtitle: () {
                      final userState = context.read<UserBloc>().state;
                      if (userState is UserLoaded) {
                        return userState.user.displayName;
                      }
                      return '';
                    }(),
                  ),
                  Expanded(
                    child: isLoading && documentTypes.isEmpty
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(AppColors.primaryDark),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'profile.step2_title'.tr(),
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamilySofiaSans,
                                    fontSize: AppConstants.fontSizeXXLarge,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'profile.step2_subtitle'.tr(),
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamilyInter,
                                    fontSize: AppConstants.fontSizeMedium,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const _StatusLegend(),
                                const SizedBox(height: 20),

                                // Grille dynamique depuis l'API
                                _DocumentsGrid(
                                  documentTypes: documentTypes,
                                  uploadedDocuments: uploadedDocuments,
                                ),
                                const SizedBox(height: 32),

                                // Bouton VALIDER
                                SizedBox(
                                  width: double.infinity,
                                  height: AppConstants.logoutButtonHeight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (!hasDocuments) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'profile.fill_documents'.tr(),
                                              style: TextStyle(
                                                fontFamily: AppConstants.fontFamilyInter,
                                                color: AppColors.white,
                                              ),
                                            ),
                                            backgroundColor: AppColors.statusEnAttente,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      // Recharger le profil pour mettre à jour profileCompletion
                                      context.read<UserBloc>().add(
                                        LoadUserProfile(UserSession.instance.accessToken),
                                      );
                                      context.read<ProfileBloc>().add(const CompleteProfileEvent());
                                      Navigator.of(context).pushNamedAndRemoveUntil(
                                        AppRoutes.clientHome,
                                        (route) => false,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: hasDocuments
                                          ? AppColors.primaryDark
                                          : AppColors.primaryDark.withValues(alpha: 0.5),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                                      ),
                                    ),
                                    child: Text(
                                      'profile.validate'.tr(),
                                      style: TextStyle(
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToKyc(BuildContext context, DocumentTypeModel docType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => KycBloc(userId: UserSession.instance.email),
          child: KycStep2FacePage(
            onSuccess: () {
              // Dépiler : kyc_step2_face_preview + kyc_step2_face_page
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              // Recharger les documents
              context.read<ProfileBloc>().add(const LoadDocumentTypesEvent());
            },
          ),
        ),
      ),
    );
  }

  double _getProgressValue(ProfileState state) {
    if (state is ProfileDocumentsLoaded) return state.profile.progressPercent;
    if (state is ProfileDocumentUploading) return state.profile.progressPercent;
    if (state is ProfileDocumentUploadedNeedsVerification) return state.profile.progressPercent;
    if (state is ProfileDocumentUploadedSuccess) return state.profile.progressPercent;
    if (state is ProfileDocumentDeleted) return state.profile.progressPercent;
    if (state is ProfileInProgress) return state.profile.progressPercent;
    if (state is ProfileStep1Validated) return state.profile.progressPercent;
    if (state is ProfileCompleted) return state.profile.progressPercent;
    return 0.50;
  }

  List<DocumentTypeModel> _getDocumentTypes(ProfileState state) {
    if (state is ProfileDocumentsLoaded) return state.documentTypes;
    if (state is ProfileDocumentUploading) return state.documentTypes;
    if (state is ProfileDocumentUploadedNeedsVerification) return state.documentTypes;
    if (state is ProfileDocumentUploadedSuccess) return state.documentTypes;
    if (state is ProfileDocumentDeleted) return state.documentTypes;
    return [];
  }

  List<UploadedDocumentModel> _getUploadedDocuments(ProfileState state) {
    if (state is ProfileDocumentsLoaded) return state.uploadedDocuments;
    if (state is ProfileDocumentUploading) return state.uploadedDocuments;
    if (state is ProfileDocumentUploadedNeedsVerification) return state.uploadedDocuments;
    if (state is ProfileDocumentUploadedSuccess) return state.uploadedDocuments;
    if (state is ProfileDocumentDeleted) return state.uploadedDocuments;
    return [];
  }
}

// ─────────────────────────────────────────────────────────────────
// LÉGENDE DES STATUTS
// ─────────────────────────────────────────────────────────────────
class _StatusLegend extends StatelessWidget {
  const _StatusLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: [
        _LegendItem(color: AppColors.statusValideGreen, label: 'profile.validated'.tr()),
        _LegendItem(color: AppColors.statusEnAttente, label: 'profile.pending'.tr()),
        _LegendItem(color: AppColors.primary, label: 'profile.in_progress'.tr()),
        _LegendItem(color: AppColors.statusRejected, label: 'profile.rejected'.tr()),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppConstants.fontFamilyInter,
            fontSize: AppConstants.fontSizeRegular,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// GRILLE 2 colonnes — dynamique depuis l'API
// ─────────────────────────────────────────────────────────────────
class _DocumentsGrid extends StatelessWidget {
  final List<DocumentTypeModel> documentTypes;
  final List<UploadedDocumentModel> uploadedDocuments;

  const _DocumentsGrid({
    required this.documentTypes,
    required this.uploadedDocuments,
  });

  @override
  Widget build(BuildContext context) {
    if (documentTypes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text(
            'profile.no_document_types'.tr(),
            style: TextStyle(
              fontFamily: AppConstants.fontFamilyInter,
              fontSize: AppConstants.fontSizeMedium,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: documentTypes.length,
      itemBuilder: (context, index) {
        final docType = documentTypes[index];
        final uploaded = uploadedDocuments
            .where((d) => d.documentTypeId == docType.id)
            .firstOrNull;
        return _DocumentCard(
          documentType: docType,
          uploadedDocument: uploaded,
          onTap: () => _showModal(context, docType, uploaded),
          onDelete: uploaded != null
              ? () => context.read<ProfileBloc>().add(
                    DeleteProfileDocumentEvent(documentId: uploaded.id),
                  )
              : null,
        );
      },
    );
  }

  void _showModal(
    BuildContext context,
    DocumentTypeModel docType,
    UploadedDocumentModel? existing,
  ) {
    if (existing != null) {
      // Document déjà uploadé → afficher les options Visualiser / Modifier
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileBloc>(),
          child: _DocumentOptionsSheet(
            documentType: docType,
            existing: existing,
          ),
        ),
      );
      return;
    }
    // Pas encore uploadé → ouvrir directement le modal d'ajout
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: docType.isForIdentityVerification
            ? DocumentUploadModal(
                documentType: docType,
                existingDocument: existing,
              )
            : DocumentSimpleUploadModal(
                documentType: docType,
                existingDocument: existing,
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CARD DOCUMENT
// ─────────────────────────────────────────────────────────────────
class _DocumentCard extends StatelessWidget {
  final DocumentTypeModel documentType;
  final UploadedDocumentModel? uploadedDocument;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _DocumentCard({
    required this.documentType,
    required this.uploadedDocument,
    required this.onTap,
    this.onDelete,
  });

  Color _statusColor() {
    if (uploadedDocument == null) return AppColors.borderLight;
    switch (uploadedDocument!.status.toUpperCase()) {
      case 'VALIDATED':
      case 'APPROVED':
      case 'VALIDE':
        return AppColors.statusValideGreen;
      case 'PENDING':
      case 'EN_ATTENTE':
        return AppColors.statusEnAttente;
      case 'IN_PROGRESS':
      case 'EN_COURS':
        return AppColors.primary;
      case 'REJECTED':
      case 'REJETE':
        return AppColors.statusRejected;
      default:
        return AppColors.statusEnAttente;
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      // Format API: jj/mm/aaaa ou ISO
      if (date.contains('/')) return date;
      final parsed = DateTime.tryParse(date);
      if (parsed == null) return date;
      const months = [
        '', 'janv.', 'févr.', 'mars', 'avr.',
        'mai', 'juin', 'juil.', 'août',
        'sept.', 'oct.', 'nov.', 'déc.'
      ];
      return '${parsed.day} ${months[parsed.month]}${parsed.year}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDoc = uploadedDocument != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          border: Border.all(
            color: hasDoc ? _statusColor() : AppColors.borderLight,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Zone image ou icône
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.documentCardBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusSmall),
                    topRight: Radius.circular(AppConstants.radiusSmall),
                  ),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppConstants.radiusSmall),
                        topRight: Radius.circular(AppConstants.radiusSmall),
                      ),
                      child: hasDoc
                          ? _DocumentImage(documentId: uploadedDocument!.id)
                          : Center(
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 36,
                                color: AppColors.primary,
                              ),
                            ),
                    ),
                    // Bouton supprimer si document uploadé
                    if (hasDoc && onDelete != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.statusRejected.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: AppColors.statusRejected,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Bande grise en bas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.greyShade100,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppConstants.radiusSmall),
                  bottomRight: Radius.circular(AppConstants.radiusSmall),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          documentType.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontSize: 10,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (hasDoc &&
                            uploadedDocument!.expirationDate != null &&
                            uploadedDocument!.expirationDate!.isNotEmpty)
                          Text(
                            'profile.expires_on'.tr() +
                                ' ${_formatDate(uploadedDocument!.expirationDate)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilyInter,
                              fontSize: 9,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (hasDoc)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: _statusColor(),
                        shape: BoxShape.circle,
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
// WIDGET IMAGE DOCUMENT — charge via le repository (isolé du BLoC principal)
// ─────────────────────────────────────────────────────────────────
class _DocumentImage extends StatefulWidget {
  final String documentId;
  const _DocumentImage({required this.documentId});

  @override
  State<_DocumentImage> createState() => _DocumentImageState();
}

class _DocumentImageState extends State<_DocumentImage> {
  Uint8List? _bytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await context.read<ProfileBloc>().repository.getDocumentFile(
            token: UserSession.instance.accessToken,
            documentId: widget.documentId,
          );
      if (mounted) {
        setState(() {
          _bytes = Uint8List.fromList(bytes);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        color: AppColors.documentCardBackground,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
      );
    }
    if (_bytes != null) {
      return SizedBox.expand(
        child: Image.memory(
          _bytes!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.documentCardBackground,
      child: Center(
        child: Icon(
          Icons.insert_drive_file_outlined,
          size: 36,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// OPTIONS SHEET — Visualiser / Modifier
// ─────────────────────────────────────────────────────────────────
class _DocumentOptionsSheet extends StatelessWidget {
  final DocumentTypeModel documentType;
  final UploadedDocumentModel existing;

  const _DocumentOptionsSheet({
    required this.documentType,
    required this.existing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: AppConstants.modalHandleWidth,
              height: AppConstants.modalHandleHeight,
              decoration: BoxDecoration(
                color: AppColors.modalHandle,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Titre
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              documentType.title,
              style: TextStyle(
                fontFamily: AppConstants.fontFamilySofiaSans,
                fontWeight: FontWeight.w700,
                fontSize: AppConstants.fontSizeXXLarge,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Bouton Visualiser
          SizedBox(
            width: double.infinity,
            height: AppConstants.logoutButtonHeight,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppColors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => BlocProvider.value(
                    value: context.read<ProfileBloc>(),
                    child: _DocumentViewerSheet(
                      documentType: documentType,
                      existing: existing,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: Text(
                'Visualiser',
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontWeight: FontWeight.w600,
                  fontSize: AppConstants.fontSizeLarge,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bouton Modifier
          SizedBox(
            width: double.infinity,
            height: AppConstants.logoutButtonHeight,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppColors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => BlocProvider.value(
                    value: context.read<ProfileBloc>(),
                    child: documentType.isForIdentityVerification
                        ? DocumentUploadModal(
                            documentType: documentType,
                            existingDocument: existing,
                          )
                        : DocumentSimpleUploadModal(
                            documentType: documentType,
                            existingDocument: existing,
                          ),
                  ),
                );
              },
              icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryDark),
              label: Text(
                'Modifier',
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontWeight: FontWeight.w600,
                  fontSize: AppConstants.fontSizeLarge,
                  color: AppColors.primaryDark,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primaryDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// VIEWER SHEET — Affiche le document en intégralité
// ─────────────────────────────────────────────────────────────────
class _DocumentViewerSheet extends StatefulWidget {
  final DocumentTypeModel documentType;
  final UploadedDocumentModel existing;

  const _DocumentViewerSheet({
    required this.documentType,
    required this.existing,
  });

  @override
  State<_DocumentViewerSheet> createState() => _DocumentViewerSheetState();
}

class _DocumentViewerSheetState extends State<_DocumentViewerSheet> {
  Uint8List? _bytes;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      final bytes = await context.read<ProfileBloc>().repository.getDocumentFile(
            token: UserSession.instance.accessToken,
            documentId: widget.existing.id,
          );
      if (mounted) {
        setState(() {
          _bytes = Uint8List.fromList(bytes);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  bool get _isPdf {
    if (_bytes == null || _bytes!.length < 4) return false;
    // Signature PDF : %PDF
    return _bytes![0] == 0x25 && _bytes![1] == 0x50 &&
           _bytes![2] == 0x44 && _bytes![3] == 0x46;
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Container(
      height: screenH * 0.85,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              width: AppConstants.modalHandleWidth,
              height: AppConstants.modalHandleHeight,
              decoration: BoxDecoration(
                color: AppColors.modalHandle,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.documentType.title,
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontWeight: FontWeight.w700,
                  fontSize: AppConstants.fontSizeXXLarge,
                  color: AppColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, color: AppColors.textSecondary, size: AppConstants.iconSizeLarge),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Contenu
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.primaryDark),
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, color: AppColors.statusRejected, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'Impossible de charger le document',
                              style: TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                color: AppColors.textSecondary,
                                fontSize: AppConstants.fontSizeMedium,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _bytes != null
                        ? _isPdf
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.picture_as_pdf,
                                        size: 80, color: AppColors.statusRejected),
                                    const SizedBox(height: 16),
                                    Text(
                                      widget.documentType.title,
                                      style: TextStyle(
                                        fontFamily: AppConstants.fontFamilySofiaSans,
                                        fontWeight: FontWeight.w600,
                                        fontSize: AppConstants.fontSizeLarge,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Document PDF • ${(_bytes!.length / 1024).toStringAsFixed(1)} KB',
                                      style: TextStyle(
                                        fontFamily: AppConstants.fontFamilyInter,
                                        fontSize: AppConstants.fontSizeMedium,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Téléchargé avec succès ✓',
                                      style: TextStyle(
                                        fontFamily: AppConstants.fontFamilyInter,
                                        fontSize: AppConstants.fontSizeRegular,
                                        color: AppColors.statusValideGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                child: InteractiveViewer(
                                  minScale: 0.5,
                                  maxScale: 4.0,
                                  child: Image.memory(
                                    _bytes!,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Icon(
                                        Icons.insert_drive_file_outlined,
                                        size: 80,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                        : Center(
                            child: Icon(
                              Icons.insert_drive_file_outlined,
                              size: 80,
                              color: AppColors.primary,
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
