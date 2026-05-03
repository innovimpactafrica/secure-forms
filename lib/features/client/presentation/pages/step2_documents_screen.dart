import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';
import 'package:quick_forms/core/utils/app_routes.dart';
import 'package:quick_forms/core/utils/user_session.dart';
import 'package:quick_forms/features/auth/domain/bloc/user_bloc.dart';
import 'package:quick_forms/features/auth/domain/bloc/user_event.dart';
import 'package:quick_forms/features/auth/domain/bloc/user_state.dart';
import 'package:quick_forms/features/client/data/models/profile_model.dart';
import 'package:quick_forms/features/client/data/repositories/profile_document_repository.dart';
import 'package:quick_forms/features/client/domain/bloc/profile_bloc.dart';
import 'package:quick_forms/features/client/domain/bloc/profile_event.dart';
import 'package:quick_forms/features/client/domain/bloc/profile_state.dart';
import 'package:quick_forms/features/kyc/domain/bloc/kyc_bloc.dart';
import 'package:quick_forms/features/kyc/presentation/pages/kyc_step2_face_page.dart';
import '../widgets/complete_profile_header.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/document_upload_modal.dart'
    show DocumentUploadModal, showPickerSource;
import '../widgets/document_simple_upload_modal.dart';

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
    // Ne recharger que si pas encore de données en cache
    final state = context.read<ProfileBloc>().state;
    final hasCache = state is ProfileDocumentsLoaded ||
        state is ProfileDocumentUploadedSuccess ||
        state is ProfileDocumentUploadedNeedsVerification ||
        state is ProfileDocumentPatched ||
        state is ProfileDocumentDeleted;
    if (!hasCache) {
      context.read<ProfileBloc>().add(const LoadDocumentTypesEvent());
    }
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
          final isLoading =
              state is ProfileLoading || state is ProfileDocumentUploading;
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
                    subtitle: BlocBuilder<UserBloc, UserState>(
                      buildWhen: (_, s) => s is UserLoaded,
                      builder: (_, userState) {
                        String name = '';
                        if (userState is UserLoaded) {
                          name = userState.user.displayName;
                        } else {
                          name = context
                                  .read<UserBloc>()
                                  .cachedUser
                                  ?.displayName ??
                              '';
                        }
                        return Text(
                          name,
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontSize: AppConstants.fontSizeRegular,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPureBlack,
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: isLoading && documentTypes.isEmpty
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation(AppColors.primaryDark),
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
                                    fontFamily:
                                        AppConstants.fontFamilySofiaSans,
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
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'profile.fill_documents'.tr(),
                                              style: TextStyle(
                                                fontFamily: AppConstants
                                                    .fontFamilyInter,
                                                color: AppColors.white,
                                              ),
                                            ),
                                            backgroundColor:
                                                AppColors.statusEnAttente,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      // Recharger le profil pour mettre à jour profileCompletion
                                      context.read<UserBloc>().add(
                                            LoadUserProfile(UserSession
                                                .instance.accessToken),
                                          );
                                      context
                                          .read<ProfileBloc>()
                                          .add(const CompleteProfileEvent());
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                        AppRoutes.clientHome,
                                        (route) => false,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: hasDocuments
                                          ? AppColors.primaryDark
                                          : AppColors.primaryDark
                                              .withValues(alpha: 0.5),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.radiusRound),
                                      ),
                                    ),
                                    child: Text(
                                      'profile.validate'.tr(),
                                      style: TextStyle(
                                        fontFamily:
                                            AppConstants.fontFamilySofiaSans,
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

  void _navigateToKyc(BuildContext context, DocumentTypeModel docType) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (kycContext) => BlocProvider(
          create: (_) => KycBloc(userId: UserSession.instance.email),
          child: KycStep2FacePage(
            onSuccess: () {
              // Fermer kyc_step2_face_preview + kyc_step2_face_page
              Navigator.of(kycContext)
                ..pop() // ferme preview
                ..pop(true); // ferme face_page avec result=true
            },
          ),
        ),
      ),
    );
    // Ne recharger que si la vérification a été complétée
    if (result == true && mounted) {
      context.read<ProfileBloc>().add(const LoadDocumentTypesEvent());
    }
  }

  double _getProgressValue(ProfileState state) {
    if (state is ProfileDocumentsLoaded) return state.profile.progressPercent;
    if (state is ProfileDocumentUploading) return state.profile.progressPercent;
    if (state is ProfileDocumentUploadedNeedsVerification)
      return state.profile.progressPercent;
    if (state is ProfileDocumentUploadedSuccess)
      return state.profile.progressPercent;
    if (state is ProfileDocumentDeleted) return state.profile.progressPercent;
    if (state is ProfileInProgress) return state.profile.progressPercent;
    if (state is ProfileStep1Validated) return state.profile.progressPercent;
    if (state is ProfileCompleted) return state.profile.progressPercent;
    return 0.50;
  }

  List<DocumentTypeModel> _getDocumentTypes(ProfileState state) {
    if (state is ProfileDocumentsLoaded) return state.documentTypes;
    if (state is ProfileDocumentUploading) return state.documentTypes;
    if (state is ProfileDocumentUploadedNeedsVerification)
      return state.documentTypes;
    if (state is ProfileDocumentUploadedSuccess) return state.documentTypes;
    if (state is ProfileDocumentDeleted) return state.documentTypes;
    return [];
  }

  List<UploadedDocumentModel> _getUploadedDocuments(ProfileState state) {
    if (state is ProfileDocumentsLoaded) return state.uploadedDocuments;
    if (state is ProfileDocumentUploading) return state.uploadedDocuments;
    if (state is ProfileDocumentUploadedNeedsVerification)
      return state.uploadedDocuments;
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
        _LegendItem(
            color: AppColors.statusValideGreen,
            label: 'profile.validated'.tr()),
        _LegendItem(
            color: AppColors.statusEnAttente, label: 'profile.pending'.tr()),
        _LegendItem(
            color: AppColors.statusInProgressCircle,
            label: 'profile.in_progress'.tr()),
        _LegendItem(
            color: AppColors.statusRejected, label: 'profile.rejected'.tr()),
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
        final visibleDoc = uploaded;
        return _DocumentCard(
          documentType: docType,
          uploadedDocument: visibleDoc,
          onTap: () => _showModal(context, docType, visibleDoc),
          onDelete: visibleDoc != null
              ? () => _showDeleteConfirm(context, visibleDoc)
              : null,
        );
      },
    );
  }

  void _showDeleteConfirm(
      BuildContext context, UploadedDocumentModel uploaded) {
    final bloc = context.read<ProfileBloc>();
    final hasTwo = uploaded.backFileId != null;

    void deleteFile(String fileId, String label) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
          title: Text('${'documents.delete'.tr()} $label',
              style: TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontWeight: FontWeight.w700,
                  fontSize: AppConstants.fontSizeLarge,
                  color: AppColors.textDark)),
          content: Text('documents.delete_file_confirm'.tr(),
              style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppColors.textSecondary)),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('documents.cancel'.tr(),
                    style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        color: AppColors.textSecondary))),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ProfileDocumentRepository.invalidate(fileId);
                bloc.add(DeleteProfileDocumentEvent(documentId: fileId));
              },
              child: Text('documents.delete'.tr(),
                  style: TextStyle(
                      fontFamily: AppConstants.fontFamilyInter,
                      color: AppColors.statusRejected,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    if (!hasTwo) {
      deleteFile(uploaded.id, 'Document 1');
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        final bp = MediaQuery.of(context).padding.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                  child: Container(
                      width: AppConstants.modalHandleWidth,
                      height: AppConstants.modalHandleHeight,
                      decoration: BoxDecoration(
                          color: AppColors.modalHandle,
                          borderRadius: BorderRadius.circular(999)))),
              const SizedBox(height: 16),
              Text('documents.choose_to_delete'.tr(),
                  style: TextStyle(
                      fontFamily: AppConstants.fontFamilySofiaSans,
                      fontWeight: FontWeight.w700,
                      fontSize: AppConstants.fontSizeLarge,
                      color: AppColors.textDark)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: AppConstants.logoutButtonHeight,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    deleteFile(uploaded.id, 'Document 1');
                  },
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.statusRejected),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusRound))),
                  child: Text('documents.delete_doc1'.tr(),
                      style: TextStyle(
                          fontFamily: AppConstants.fontFamilySofiaSans,
                          fontWeight: FontWeight.w600,
                          fontSize: AppConstants.fontSizeLarge,
                          color: AppColors.statusRejected)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: AppConstants.logoutButtonHeight,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    deleteFile(uploaded.backFileId!, 'Document 2');
                  },
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.statusRejected),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusRound))),
                  child: Text('documents.delete_doc2'.tr(),
                      style: TextStyle(
                          fontFamily: AppConstants.fontFamilySofiaSans,
                          fontWeight: FontWeight.w600,
                          fontSize: AppConstants.fontSizeLarge,
                          color: AppColors.statusRejected)),
                ),
              ),
            ],
          ),
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
        useSafeArea: true, // ✅ protège du navbar
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
      useSafeArea: true, // ✅ protège du navbar
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: docType.hasExpirationDate
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
      if (date.contains('/')) return date;
      final parsed = DateTime.tryParse(date);
      if (parsed == null) return date;
      const months = [
        '',
        'janv.',
        'févr.',
        'mars',
        'avr.',
        'mai',
        'juin',
        'juil.',
        'août',
        'sept.',
        'oct.',
        'nov.',
        'déc.'
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
                  color: hasDoc ? AppColors.white : AppColors.docCardEmptyBg,
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
                          ? (uploadedDocument!.backFileId != null
                              ? _DocumentImageDouble(
                                  key: ValueKey(
                                      '${uploadedDocument!.id}_${uploadedDocument!.backFileId}_${uploadedDocument!.uploadedAt?.millisecondsSinceEpoch ?? 0}'),
                                  id1: uploadedDocument!.id,
                                  url1: uploadedDocument!.fileUrl,
                                  id2: uploadedDocument!.backFileId!,
                                  url2: uploadedDocument!.backFileUrl,
                                )
                              : _DocumentImage(
                                  key: ValueKey(
                                      '${uploadedDocument!.id}_${uploadedDocument!.uploadedAt?.millisecondsSinceEpoch ?? 0}'),
                                  documentId: uploadedDocument!.id,
                                  directUrl: uploadedDocument!.fileUrl,
                                ))
                          : Center(
                              child: SvgPicture.asset(
                                'assets/icons/ri_image-add-fill.svg',
                                width: 32,
                                height: 32,
                                colorFilter: ColorFilter.mode(
                                    AppColors.docCardAddIconColor,
                                    BlendMode.srcIn),
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
                              color: AppColors.statusRejected
                                  .withValues(alpha: 0.1),
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
  final String? directUrl;
  const _DocumentImage({super.key, required this.documentId, this.directUrl});

  @override
  State<_DocumentImage> createState() => _DocumentImageState();
}

class _DocumentImageState extends State<_DocumentImage> {
  Uint8List? _bytes;
  bool _loading = true;
  bool _isPdf = false;
  String? _pdfPath;
  ProfileDocumentRepository? _repo;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_repo == null) {
      _repo = context.read<ProfileBloc>().repository;
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await _repo!.getDocumentFile(
        token: UserSession.instance.accessToken,
        documentId: widget.documentId,
        directUrl: widget.directUrl,
      );
      final data = Uint8List.fromList(bytes);
      final pdf = data.length >= 4 &&
          data[0] == 0x25 &&
          data[1] == 0x50 &&
          data[2] == 0x44 &&
          data[3] == 0x46;
      if (pdf) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/thumb_${widget.documentId}.pdf');
        await file.writeAsBytes(data);
        if (mounted)
          setState(() {
            _isPdf = true;
            _pdfPath = file.path;
            _loading = false;
          });
      } else {
        if (mounted)
          setState(() {
            _bytes = data;
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
    if (_isPdf && _pdfPath != null) {
      return IgnorePointer(
        child: PDFView(
          filePath: _pdfPath!,
          enableSwipe: false,
          autoSpacing: false,
          pageFling: false,
          pageSnap: false,
          fitPolicy: FitPolicy.WIDTH,
          enableRenderDuringScale: false,
          useBestQuality: true,
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
// WIDGET 2 IMAGES VERTICALES (doc1 + trait + doc2) pour la card
// ─────────────────────────────────────────────────────────────────
class _DocumentImageDouble extends StatelessWidget {
  final String id1;
  final String? url1;
  final String id2;
  final String? url2;
  const _DocumentImageDouble(
      {super.key, required this.id1, this.url1, required this.id2, this.url2});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: SizedBox.expand(
                child: _DocumentImage(
                    key: ValueKey('doc1_$id1'),
                    documentId: id1,
                    directUrl: url1))),
        Container(height: 1, color: AppColors.borderLight),
        Expanded(
            child: SizedBox.expand(
                child: _DocumentImage(
                    key: ValueKey('doc2_$id2'),
                    documentId: id2,
                    directUrl: url2))),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// OPTIONS SHEET — Visualiser / Modifier / Supprimer
// ─────────────────────────────────────────────────────────────────
class _DocumentOptionsSheet extends StatelessWidget {
  final DocumentTypeModel documentType;
  final UploadedDocumentModel existing;

  const _DocumentOptionsSheet({
    required this.documentType,
    required this.existing,
  });

  void _openSingleFileModal(BuildContext context, String fileId, String label) {
    final bloc = context.read<ProfileBloc>();
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _SingleFileUpdateModal(
          fileId: fileId,
          label: label,
          documentType: documentType,
          existing: existing,
        ),
      ),
    );
  }

  void _confirmDeleteFile(BuildContext context, String fileId, String label) {
    final bloc = context.read<ProfileBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
        title: Text('${'documents.delete'.tr()} $label',
            style: TextStyle(
                fontFamily: AppConstants.fontFamilySofiaSans,
                fontWeight: FontWeight.w700,
                fontSize: AppConstants.fontSizeLarge,
                color: AppColors.textDark)),
        content: Text('documents.delete_file_confirm'.tr(),
            style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontSize: AppConstants.fontSizeMedium,
                color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('documents.cancel'.tr(),
                style: TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              ProfileDocumentRepository.invalidate(fileId);
              bloc.add(DeleteProfileDocumentEvent(documentId: fileId));
            },
            child: Text('documents.delete'.tr(),
                style: TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    color: AppColors.statusRejected,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasTwo = existing.backFileId != null;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 32 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: AppConstants.modalHandleWidth,
                height: AppConstants.modalHandleHeight,
                decoration: BoxDecoration(
                    color: AppColors.modalHandle,
                    borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(documentType.title,
                  style: TextStyle(
                      fontFamily: AppConstants.fontFamilySofiaSans,
                      fontWeight: FontWeight.w700,
                      fontSize: AppConstants.fontSizeXXLarge,
                      color: AppColors.textDark)),
            ),
            const SizedBox(height: 24),
            // Visualiser
            SizedBox(
              width: double.infinity,
              height: AppConstants.logoutButtonHeight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => _DocumentViewerPage(
                      documentType: documentType,
                      existing: existing,
                    ),
                  ));
                },
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: Text('documents.view'.tr(),
                    style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        fontWeight: FontWeight.w600,
                        fontSize: AppConstants.fontSizeLarge)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusRound)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Modifier
            _outlinedBtn(context, Icons.edit_outlined, 'documents.modify'.tr(),
                () {
              if (!hasTwo) {
                _openSingleFileModal(context, existing.id, 'Document 1');
              } else {
                final bloc = context.read<ProfileBloc>();
                Navigator.of(context).pop();
                _showSubChoiceModifier(context, bloc);
              }
            }),
            const SizedBox(height: 8),
            // Supprimer
            _dangerBtn(context, Icons.delete_outline, 'documents.delete'.tr(),
                () {
              if (!hasTwo) {
                _confirmDeleteFile(context, existing.id, 'Document 1');
              } else {
                final bloc = context.read<ProfileBloc>();
                Navigator.of(context).pop();
                _showSubChoiceSupprimer(context, bloc);
              }
            }),
          ],
        ),
      ),
    );
  }

  void _showSubChoiceModifier(BuildContext context, ProfileBloc bloc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final bp = MediaQuery.of(ctx).padding.bottom;
        return BlocProvider.value(
          value: bloc,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                    child: Container(
                        width: AppConstants.modalHandleWidth,
                        height: AppConstants.modalHandleHeight,
                        decoration: BoxDecoration(
                            color: AppColors.modalHandle,
                            borderRadius: BorderRadius.circular(999)))),
                const SizedBox(height: 16),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('documents.modify_choose'.tr(),
                        style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontWeight: FontWeight.w700,
                            fontSize: AppConstants.fontSizeLarge,
                            color: AppColors.textDark))),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: AppConstants.logoutButtonHeight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      showModalBottomSheet(
                        context: ctx,
                        isScrollControlled: true,
                        backgroundColor: AppColors.white,
                        useSafeArea: true,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20))),
                        builder: (_) => BlocProvider.value(
                            value: bloc,
                            child: _SingleFileUpdateModal(
                                fileId: existing.id,
                                label: 'Document 1',
                                documentType: documentType,
                                existing: existing)),
                      );
                    },
                    icon: Icon(Icons.edit_outlined,
                        size: 18, color: AppColors.primaryDark),
                    label: Text('documents.modify_doc1'.tr(),
                        style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontWeight: FontWeight.w600,
                            fontSize: AppConstants.fontSizeLarge,
                            color: AppColors.primaryDark)),
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryDark),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusRound))),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: AppConstants.logoutButtonHeight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      showModalBottomSheet(
                        context: ctx,
                        isScrollControlled: true,
                        backgroundColor: AppColors.white,
                        useSafeArea: true,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20))),
                        builder: (_) => BlocProvider.value(
                            value: bloc,
                            child: _SingleFileUpdateModal(
                                fileId: existing.backFileId!,
                                label: 'Document 2',
                                documentType: documentType,
                                existing: existing)),
                      );
                    },
                    icon: Icon(Icons.edit_outlined,
                        size: 18, color: AppColors.primaryDark),
                    label: Text('documents.modify_doc2'.tr(),
                        style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontWeight: FontWeight.w600,
                            fontSize: AppConstants.fontSizeLarge,
                            color: AppColors.primaryDark)),
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryDark),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusRound))),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSubChoiceSupprimer(BuildContext context, ProfileBloc bloc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final bp = MediaQuery.of(ctx).padding.bottom;
        return BlocProvider.value(
          value: bloc,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                    child: Container(
                        width: AppConstants.modalHandleWidth,
                        height: AppConstants.modalHandleHeight,
                        decoration: BoxDecoration(
                            color: AppColors.modalHandle,
                            borderRadius: BorderRadius.circular(999)))),
                const SizedBox(height: 16),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('documents.delete_choose'.tr(),
                        style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontWeight: FontWeight.w700,
                            fontSize: AppConstants.fontSizeLarge,
                            color: AppColors.textDark))),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: AppConstants.logoutButtonHeight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _confirmDeleteFileDirect(
                          ctx, bloc, existing.id, 'Document 1');
                    },
                    icon: Icon(Icons.delete_outline,
                        size: 18, color: AppColors.statusRejected),
                    label: Text('documents.delete_doc1'.tr(),
                        style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontWeight: FontWeight.w600,
                            fontSize: AppConstants.fontSizeLarge,
                            color: AppColors.statusRejected)),
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.statusRejected),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusRound))),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: AppConstants.logoutButtonHeight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _confirmDeleteFileDirect(
                          ctx, bloc, existing.backFileId!, 'Document 2');
                    },
                    icon: Icon(Icons.delete_outline,
                        size: 18, color: AppColors.statusRejected),
                    label: Text('documents.delete_doc2'.tr(),
                        style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontWeight: FontWeight.w600,
                            fontSize: AppConstants.fontSizeLarge,
                            color: AppColors.statusRejected)),
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.statusRejected),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusRound))),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteFileDirect(
      BuildContext context, ProfileBloc bloc, String fileId, String label) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
        title: Text('${'documents.delete'.tr()} $label',
            style: TextStyle(
                fontFamily: AppConstants.fontFamilySofiaSans,
                fontWeight: FontWeight.w700,
                fontSize: AppConstants.fontSizeLarge,
                color: AppColors.textDark)),
        content: Text('documents.delete_file_confirm'.tr(),
            style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontSize: AppConstants.fontSizeMedium,
                color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('documents.cancel'.tr(),
                  style: TextStyle(
                      fontFamily: AppConstants.fontFamilyInter,
                      color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ProfileDocumentRepository.invalidate(fileId);
              bloc.add(DeleteProfileDocumentEvent(documentId: fileId));
            },
            child: Text('documents.delete'.tr(),
                style: TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    color: AppColors.statusRejected,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _outlinedBtn(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.logoutButtonHeight,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: AppColors.primaryDark),
        label: Text(label,
            style: TextStyle(
                fontFamily: AppConstants.fontFamilySofiaSans,
                fontWeight: FontWeight.w600,
                fontSize: AppConstants.fontSizeLarge,
                color: AppColors.primaryDark)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primaryDark),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusRound)),
        ),
      ),
    );
  }

  Widget _dangerBtn(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.logoutButtonHeight,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: AppColors.statusRejected),
        label: Text(label,
            style: TextStyle(
                fontFamily: AppConstants.fontFamilySofiaSans,
                fontWeight: FontWeight.w600,
                fontSize: AppConstants.fontSizeLarge,
                color: AppColors.statusRejected)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.statusRejected),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusRound)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// MODAL MODIFICATION D'UN SEUL FICHIER (sans toucher l'autre)
// ─────────────────────────────────────────────────────────────────
class _SingleFileUpdateModal extends StatefulWidget {
  final String fileId;
  final String label;
  final DocumentTypeModel documentType;
  final UploadedDocumentModel existing;

  const _SingleFileUpdateModal({
    required this.fileId,
    required this.label,
    required this.documentType,
    required this.existing,
  });

  @override
  State<_SingleFileUpdateModal> createState() => _SingleFileUpdateModalState();
}

class _SingleFileUpdateModalState extends State<_SingleFileUpdateModal> {
  String? _filePath;
  String? _secondFilePath; // pour ajouter un 2ème fichier si besoin
  late final ProfileBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ProfileBloc>();
  }

  Future<void> _pickFile({bool isSecond = false}) async {
    final choice = await showPickerSource(context);
    if (choice == null || !mounted) return;

    String? path;
    if (choice == 'camera') {
      final x = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 85);
      path = x?.path;
    } else if (choice == 'gallery') {
      final x = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 85);
      path = x?.path;
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      path = result?.files.single.path;
    }

    if (path == null || !mounted) return;
    setState(() => isSecond ? _secondFilePath = path : _filePath = path);
  }

  void _onEnvoyer() {
    if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('documents.select_file_required'.tr(),
            style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                color: AppColors.white)),
        backgroundColor: AppColors.statusRejected,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    // PATCH : remplace uniquement ce fichier sans toucher l'autre
    ProfileDocumentRepository.invalidate(widget.fileId);
    _bloc.add(ReplaceProfileDocumentFileEvent(
      documentId: widget.fileId,
      file: File(_filePath!),
      issueDate: widget.existing.issueDate,
      expirationDate: widget.existing.expirationDate,
    ));
    // Ajouter un 2ème fichier uniquement si bundle à 1 fichier ET 2ème fichier sélectionné
    // On NE fait PAS de POST supplémentaire pour un bundle à 2 fichiers
    if (widget.existing.backFileId == null && _secondFilePath != null) {
      // Attendre que le PATCH soit terminé avant d'uploader le 2ème
      // Le BLoC émettra ProfileDocumentUploadedSuccess → le listener rechargera
      // On ne peut pas chaîner ici sans race condition — on informe l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Document 1 modifié. Ajoutez le 2ème fichier séparément.',
            style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                color: AppColors.white)),
        backgroundColor: AppColors.statusEnAttente,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isImage = _filePath != null && !_filePath!.endsWith('.pdf');
    final isImage2 =
        _secondFilePath != null && !_secondFilePath!.endsWith('.pdf');
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            16,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: AppConstants.modalHandleWidth,
                height: AppConstants.modalHandleHeight,
                decoration: BoxDecoration(
                    color: AppColors.modalHandle,
                    borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${'documents.modify_doc_label'.tr()} ${widget.label}',
                    style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        fontWeight: FontWeight.w700,
                        fontSize: AppConstants.fontSizeXXLarge,
                        color: AppColors.textDark)),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close,
                      color: AppColors.textSecondary,
                      size: AppConstants.iconSizeLarge),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Fichier principal
            GestureDetector(
              onTap: () => _pickFile(),
              child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.documentCardBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: _filePath != null && isImage
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusSmall),
                        child: Image.file(File(_filePath!),
                            fit: BoxFit.cover, width: double.infinity))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Icon(
                                _filePath != null
                                    ? Icons.insert_drive_file_outlined
                                    : Icons.cloud_upload_outlined,
                                size: 36,
                                color: AppColors.primary),
                            const SizedBox(height: 8),
                            Text(
                                _filePath != null
                                    ? 'documents.file_selected'.tr()
                                    : 'documents.click_to_upload'.tr(),
                                style: TextStyle(
                                    fontFamily:
                                        AppConstants.fontFamilySofiaSans,
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppConstants.fontSizeMedium,
                                    color: AppColors.primary)),
                            if (_filePath == null)
                              Text('profile.file_format'.tr(),
                                  style: TextStyle(
                                      fontFamily: AppConstants.fontFamilyInter,
                                      fontSize: AppConstants.fontSizeRegular,
                                      color: AppColors.textSecondary)),
                          ]),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: AppConstants.logoutButtonHeight,
              child: ElevatedButton(
                onPressed: _onEnvoyer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusRound)),
                ),
                child: Text('documents.send_for_validation'.tr(),
                    style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: AppConstants.fontSizeLarge)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: AppConstants.logoutButtonHeight,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primaryDark),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusRound)),
                ),
                child: Text('documents.cancel'.tr(),
                    style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                        fontSize: AppConstants.fontSizeLarge)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PAGE PLEIN ÉCRAN — Visualiser document (comme Gmail)
// ─────────────────────────────────────────────────────────────────
class _DocumentViewerPage extends StatefulWidget {
  final DocumentTypeModel documentType;
  final UploadedDocumentModel existing;

  const _DocumentViewerPage({
    required this.documentType,
    required this.existing,
  });

  @override
  State<_DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<_DocumentViewerPage> {
  final List<Map<String, dynamic>> _pages = [];
  bool _loading = true;
  int _currentPage = 0;
  late final PageController _pageController;
  late final ProfileDocumentRepository _repo;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _repo = context.read<ProfileBloc>().repository;
    _loadFiles();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    final token = UserSession.instance.accessToken;
    final files = [
      {'id': widget.existing.id, 'url': widget.existing.fileUrl},
      if (widget.existing.backFileId != null)
        {'id': widget.existing.backFileId!, 'url': widget.existing.backFileUrl},
    ];
    final results = <Map<String, dynamic>>[];
    for (final f in files) {
      try {
        final bytes = await _repo.getDocumentFile(
          token: token,
          documentId: f['id'] as String,
          directUrl: f['url'] as String?,
        );
        final data = Uint8List.fromList(bytes);
        final isPdf = data.length >= 4 &&
            data[0] == 0x25 &&
            data[1] == 0x50 &&
            data[2] == 0x44 &&
            data[3] == 0x46;
        if (isPdf) {
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/viewer_step2_${f["id"]}.pdf');
          await file.writeAsBytes(data);
          results.add({'pdfPath': file.path});
        } else {
          results.add({'bytes': data});
        }
      } catch (e) {
        results.add({'error': e.toString()});
      }
    }
    if (mounted)
      setState(() {
        _pages.addAll(results);
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final total = _pages.length;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          widget.documentType.title,
          style: const TextStyle(
            fontFamily: AppConstants.fontFamilySofiaSans,
            fontWeight: FontWeight.w600,
            fontSize: AppConstants.fontSizeLarge,
            color: AppColors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (!_loading && total > 1)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_currentPage + 1}/$total',
                  style: const TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : total == 0
              ? const Center(
                  child: Icon(Icons.insert_drive_file_outlined,
                      size: 80, color: AppColors.primary))
              : Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: total,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (_, i) => _buildPage(_pages[i]),
                    ),
                    if (total > 1 && _currentPage == 0)
                      Positioned(
                        bottom: MediaQuery.of(context).padding.bottom + 24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.swipe,
                                    color: AppColors.white, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'documents.swipe_hint'.tr(),
                                  style: const TextStyle(
                                    fontFamily: AppConstants.fontFamilyInter,
                                    fontSize: AppConstants.fontSizeRegular,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildPage(Map<String, dynamic> page) {
    if (page['error'] != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.statusRejected, size: 48),
            const SizedBox(height: 12),
            Text(
              page['error'] as String,
              style: const TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                color: AppColors.white,
                fontSize: AppConstants.fontSizeMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    if (page['pdfPath'] != null) {
      return _PdfFullViewer(filePath: page['pdfPath'] as String);
    }
    if (page['bytes'] != null) {
      return _ZoomablePage(bytes: page['bytes'] as Uint8List);
    }
    return const Center(
        child: Icon(Icons.insert_drive_file_outlined,
            size: 80, color: AppColors.primary));
  }
}

// ─────────────────────────────────────────────────────────────────
// PDF PLEIN ÉCRAN — prend tout l'espace comme Gmail
// ─────────────────────────────────────────────────────────────────
class _PdfFullViewer extends StatefulWidget {
  final String filePath;
  const _PdfFullViewer({required this.filePath});

  @override
  State<_PdfFullViewer> createState() => _PdfFullViewerState();
}

class _PdfFullViewerState extends State<_PdfFullViewer> {
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: PDFView(
            filePath: widget.filePath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            fitPolicy: FitPolicy.BOTH,
            enableRenderDuringScale: true,
            useBestQuality: true,
            onRender: (pages) {
              if (mounted) setState(() => _totalPages = pages ?? 0);
            },
            onPageChanged: (page, _) {
              if (mounted) setState(() => _currentPage = (page ?? 0) + 1);
            },
          ),
        ),
        if (_totalPages > 1)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_currentPage / $_totalPages',
                style: const TextStyle(
                  color: AppColors.white,
                  fontFamily: AppConstants.fontFamilyInter,
                  fontSize: AppConstants.fontSizeRegular,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ZoomablePage extends StatelessWidget {
  final Uint8List bytes;
  const _ZoomablePage({required this.bytes});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 4.0,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Image.memory(
            bytes,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(Icons.insert_drive_file_outlined,
                size: 80, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
