import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/utils/base_url.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/client/data/models/profile_model.dart';
import 'package:secure_link/features/client/data/repositories/profile_document_repository.dart';
import 'package:secure_link/features/client/domain/bloc/profile_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/profile_event.dart';
import 'package:secure_link/features/client/domain/bloc/profile_state.dart';
import 'document_upload_modal.dart' show showPickerSource;
import 'face_verification_screen.dart';

/// Page "Mes documents" accessible depuis le profil.
/// Charge les documents depuis GET /api/users/profile/documents
/// Design inchangé.
class MesDocumentsScreen extends StatefulWidget {
  const MesDocumentsScreen({super.key});

  @override
  State<MesDocumentsScreen> createState() => _MesDocumentsScreenState();
}

class _MesDocumentsScreenState extends State<MesDocumentsScreen> {
  final _repository = ProfileDocumentRepository();
  List<DocumentTypeModel> _documentTypes = [];
  List<UploadedDocumentModel> _uploadedDocuments = [];
  bool _isLoading = true;
  String? _error;
  // documentTypeId -> chemin fichier local pour affichage instantané
  final Map<String, String> _localFileCache = {};

  int _refreshKey = 0; // force rebuild des _DocumentImage après modification

  void _onFileSelected(String documentTypeId, String filePath) {
    setState(() => _localFileCache[documentTypeId] = filePath);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = UserSession.instance.accessToken;
    try {
      final types = await _repository.getDocumentTypes(token);
      final docs = await _repository.getDocuments(token);
      // ignore: avoid_print
      print('[MesDocumentsScreen] ${docs.length} doc(s) — backFileIds: ${docs.map((d) => "${d.documentTypeTitle}:backId=${d.backFileId}").join(", ")}');
      if (mounted) {
        setState(() {
          _documentTypes = types;
          _uploadedDocuments = docs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString().replaceAll('Exception: ', ''); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileDocumentAdded && state.requiresFaceId) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ProfileBloc>(),
                child: FaceVerificationScreen(
                  documentType: state.addedDocument.type,
                ),
              ),
            ),
          );
        } else if (state is ProfileDocumentUploadedSuccess ||
            state is ProfileDocumentUploadedNeedsVerification ||
            state is ProfileDocumentDeleted ||
            state is ProfileDocumentPatched) {
          if (state is ProfileDocumentDeleted) {
            _localFileCache.clear();
          }
          ProfileDocumentRepository.clearCache();
          // Délai pour laisser le backend finaliser l'indexation
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (!mounted) return;
            _loadData().then((_) {
              if (mounted) setState(() => _refreshKey++);
            });
          });
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.statusRejected,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              _MesDocsHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: _StatusLegend(),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppColors.primaryDark),
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Text(
                              _error!,
                              style: TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                color: AppColors.statusRejected,
                                fontSize: AppConstants.fontSizeMedium,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : RefreshIndicator(
                            color: AppColors.primaryDark,
                            onRefresh: () async {
                              setState(() { _isLoading = true; _error = null; });
                              await _loadData();
                            },
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                              child: _DocumentsGrid(
                                documentTypes: _documentTypes,
                                uploadedDocuments: _uploadedDocuments,
                                localFileCache: _localFileCache,
                                onFileSelected: _onFileSelected,
                                refreshKey: _refreshKey,
                              ),
                            ),
                          ),
              ),
              // Bouton Mettre à jour
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: AppConstants.logoutButtonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'documents.update_success'.tr(),
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilyInter,
                              color: AppColors.white,
                            ),
                          ),
                          backgroundColor: AppColors.statusValideGreen,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                      ),
                    ),
                    child: Text(
                      'documents.update_button'.tr(),
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: AppConstants.fontSizeLarge,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────
class _MesDocsHeader extends StatelessWidget {
  const _MesDocsHeader();

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
              child: Icon(Icons.arrow_back, color: AppColors.white, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'documents.my_account'.tr(),
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontSize: AppConstants.fontSizeRegular,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                'documents.title'.tr(),
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontWeight: FontWeight.w700,
                  fontSize: AppConstants.fontSizeXXLarge,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// LÉGENDE STATUTS
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
// GRILLE 2 COLONNES
// ─────────────────────────────────────────────────────────────────
class _DocumentsGrid extends StatelessWidget {
  final List<DocumentTypeModel> documentTypes;
  final List<UploadedDocumentModel> uploadedDocuments;
  final Map<String, String> localFileCache;
  final void Function(String documentTypeId, String filePath) onFileSelected;
  final int refreshKey;

  const _DocumentsGrid({
    required this.documentTypes,
    required this.uploadedDocuments,
    required this.localFileCache,
    required this.onFileSelected,
    this.refreshKey = 0,
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
          localFilePath: localFileCache[docType.id],
          onTap: () => _showUpdateModal(context, docType, uploaded),
          refreshKey: refreshKey,
        );
      },
    );
  }

  void _showUpdateModal(
    BuildContext context,
    DocumentTypeModel docType,
    UploadedDocumentModel? existing,
  ) {
    if (existing != null) {
      // Document déjà uploadé → afficher Visualiser / Modifier
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.white,
        useSafeArea: true, // protège du navbar
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileBloc>(),
          child: _DocumentOptionsSheet(
            documentType: docType,
            existing: existing,
            onFileSelected: (path) => onFileSelected(docType.id, path),
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
      useSafeArea: true, //  protège du navbar
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: _DocumentUpdateModal(
          documentType: docType,
          existingDocument: existing,
          onFileSelected: (path) => onFileSelected(docType.id, path),
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
  final String? localFilePath;
  final VoidCallback onTap;
  final int refreshKey;

  const _DocumentCard({
    required this.documentType,
    required this.uploadedDocument,
    required this.onTap,
    this.localFilePath,
    this.refreshKey = 0,
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
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusSmall),
                    topRight: Radius.circular(AppConstants.radiusSmall),
                  ),
                  child: localFilePath != null
                      ? Image.file(
                          File(localFilePath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => _DocumentImage(
                            key: ValueKey('${uploadedDocument?.id}_$refreshKey'),
                            documentId: uploadedDocument!.id,
                          ),
                        )
                      : hasDoc
                          ? (uploadedDocument!.backFileId != null
                              ? _DocumentImageDouble(
                                  key: ValueKey('${uploadedDocument!.id}_${uploadedDocument!.backFileId}_$refreshKey'),
                                  id1: uploadedDocument!.id,
                                  url1: uploadedDocument!.fileUrl,
                                  id2: uploadedDocument!.backFileId!,
                                  url2: uploadedDocument!.backFileUrl,
                                )
                              : _DocumentImage(
                                  key: ValueKey('${uploadedDocument!.id}_$refreshKey'),
                                  documentId: uploadedDocument!.id,
                                  directUrl: uploadedDocument!.fileUrl,
                                ))
                          : Center(
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 36,
                                color: AppColors.primary,
                              ),
                            ),
                ),
              ),
            ),
            // Bande grise
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
// MODAL MISE À JOUR
// ─────────────────────────────────────────────────────────────────
class _DocumentUpdateModal extends StatefulWidget {
  final DocumentTypeModel documentType;
  final UploadedDocumentModel? existingDocument;
  final void Function(String filePath)? onFileSelected;

  const _DocumentUpdateModal({
    required this.documentType,
    this.existingDocument,
    this.onFileSelected,
  });

  @override
  State<_DocumentUpdateModal> createState() => _DocumentUpdateModalState();
}

class _DocumentUpdateModalState extends State<_DocumentUpdateModal> {
  final _deliveryDateController = TextEditingController();
  final _expiryDateController = TextEditingController();
  String? _uploadedFilePath;
  String? _backFilePath;
  bool _showBack = false;
  bool _isImage = false;
  late final ProfileBloc _bloc;

  bool get _isExisting => widget.existingDocument != null;

  bool get _canEditPhoto {
    if (!_isExisting) return true;
    final s = widget.existingDocument!.status.toUpperCase();
    return s != 'VALIDATED' && s != 'APPROVED' && s != 'VALIDE';
  }

  void _confirmDelete(BuildContext context) {
    final documentId = widget.existingDocument!.id;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        title: Text(
          'documents.delete_confirm_title'.tr(),
          style: TextStyle(
            fontFamily: AppConstants.fontFamilySofiaSans,
            fontWeight: FontWeight.w700,
            fontSize: AppConstants.fontSizeLarge,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          'documents.delete_confirm_body'.tr(),
          style: TextStyle(
            fontFamily: AppConstants.fontFamilyInter,
            fontSize: AppConstants.fontSizeMedium,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'documents.cancel'.tr(),
              style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ProfileDocumentRepository.invalidate(documentId);
              _bloc.add(DeleteProfileDocumentEvent(documentId: documentId));
              if (mounted) Navigator.of(context).pop();
            },
            child: Text(
              'documents.delete'.tr(),
              style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                color: AppColors.statusRejected,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _toDisplayDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    if (raw.contains('/')) return raw;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
  }

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ProfileBloc>();
    if (widget.existingDocument != null) {
      _deliveryDateController.text = _toDisplayDate(widget.existingDocument!.issueDate);
      _expiryDateController.text = _toDisplayDate(widget.existingDocument!.expirationDate);
    }
  }

  @override
  void dispose() {
    _deliveryDateController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, TextEditingController controller,
      {bool isExpiry = false}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isExpiry ? now.add(const Duration(days: 365)) : now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryDark,
            onPrimary: AppColors.white,
          ),
        ),
        child: child ?? const SizedBox(),
      ),
    );
    if (picked != null) {
      controller.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _pickFile({bool isBack = false}) async {
    final path = await showPickerSource(context);
    if (path == null || !mounted) return;
    final ext = path.split('.').last.toLowerCase();
    if (isBack) {
      setState(() => _backFilePath = path);
    } else {
      setState(() { _uploadedFilePath = path; _isImage = ext != 'pdf'; });
      widget.onFileSelected?.call(path);
    }
  }

  void _onEnvoyer() {
    final hasExpiry = widget.documentType.hasExpirationDate;

    // Mode PATCH : modifier uniquement les dates
    if (_isExisting && _uploadedFilePath == null) {
      if (_deliveryDateController.text.isEmpty ||
          (hasExpiry && _expiryDateController.text.isEmpty)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('profile.fill_all_fields'.tr(),
                style: TextStyle(fontFamily: AppConstants.fontFamilyInter, color: AppColors.white)),
            backgroundColor: AppColors.statusRejected,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }
      _bloc.add(PatchProfileDocumentEvent(
        documentId: widget.existingDocument!.id,
        issueDate: _deliveryDateController.text.isNotEmpty ? _deliveryDateController.text : null,
        expirationDate: _expiryDateController.text.isNotEmpty ? _expiryDateController.text : null,
      ));
      if (mounted) Navigator.of(context).pop();
      return;
    }

    // Mode POST : upload nouveau fichier
    if (_uploadedFilePath == null ||
        _deliveryDateController.text.isEmpty ||
        (hasExpiry && _expiryDateController.text.isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile.fill_all_fields'.tr(),
              style: TextStyle(fontFamily: AppConstants.fontFamilyInter, color: AppColors.white)),
          backgroundColor: AppColors.statusRejected,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    _bloc.add(UploadProfileDocumentEvent(
      file: File(_uploadedFilePath!),
      backFile: _backFilePath != null ? File(_backFilePath!) : null,
      documentTypeId: widget.documentType.id,
      issueDate: _deliveryDateController.text.isNotEmpty ? _deliveryDateController.text : null,
      expirationDate: _expiryDateController.text.isNotEmpty ? _expiryDateController.text : null,
    ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final showExpiryField = widget.documentType.hasExpirationDate;

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
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _isExisting
                        ? 'documents.update_document'.tr()
                        : 'profile.add_document'.tr(),
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamilySofiaSans,
                      fontWeight: FontWeight.w700,
                      fontSize: AppConstants.fontSizeXXLarge,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                if (_isExisting)
                  GestureDetector(
                    onTap: () => _confirmDelete(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.statusRejected.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline,
                              color: AppColors.statusRejected,
                              size: AppConstants.iconSizeMedium),
                          const SizedBox(width: 4),
                          Text(
                            'documents.delete'.tr(),
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilyInter,
                              fontSize: AppConstants.fontSizeRegular,
                              color: AppColors.statusRejected,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close,
                      color: AppColors.textSecondary,
                      size: AppConstants.iconSizeLarge),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Type (lecture seule)
            _ModalLabel(text: 'profile.document_type'.tr()),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Text(
                widget.documentType.title,
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            _ModalLabel(text: 'profile.delivery_date'.tr()),
            const SizedBox(height: 6),
            _ModalDateField(
              controller: _deliveryDateController,
              hint: 'profile.delivery_date_hint'.tr(),
              onTap: () => _pickDate(context, _deliveryDateController),
            ),
            const SizedBox(height: 16),

            if (showExpiryField) ...[
              _ModalLabel(text: 'profile.expiry_date'.tr()),
              const SizedBox(height: 6),
              _ModalDateField(
                controller: _expiryDateController,
                hint: 'profile.expiry_date_hint'.tr(),
                onTap: () =>
                    _pickDate(context, _expiryDateController, isExpiry: true),
              ),
              const SizedBox(height: 16),
            ],

            // Zone upload (masquée si document validé)
            if (_canEditPhoto) ...[
              GestureDetector(
                onTap: () => _pickFile(),
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.documentCardBackground,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: _uploadedFilePath != null && _isImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                          child: Image.file(File(_uploadedFilePath!), fit: BoxFit.cover, width: double.infinity,
                              errorBuilder: (_, __, ___) => const _UploadPlaceholder(hasFile: true)))
                      : _UploadPlaceholder(hasFile: _uploadedFilePath != null),
                ),
              ),
              const SizedBox(height: 10),

              // Bouton discret ou zone verso
              if (!_showBack)
                GestureDetector(
                  onTap: () => setState(() => _showBack = true),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'profile.add_back_document'.tr(),
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontSize: AppConstants.fontSizeRegular,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                Row(
                  children: [
                    Text(
                      'profile.back_document'.tr(),
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontSize: AppConstants.fontSizeRegular,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() { _showBack = false; _backFilePath = null; }),
                      child: Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _pickFile(isBack: true),
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.documentCardBackground,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: _backFilePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                            child: Image.file(File(_backFilePath!), fit: BoxFit.cover, width: double.infinity,
                                errorBuilder: (_, __, ___) => const _UploadPlaceholder(hasFile: true)))
                        : const _UploadPlaceholder(hasFile: false),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.statusValideGreenLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  border: Border.all(color: AppColors.statusValideGreen.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline,
                        color: AppColors.statusValideGreen,
                        size: AppConstants.iconSizeMedium),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'documents.validated_no_edit'.tr(),
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontSize: AppConstants.fontSizeRegular,
                          color: AppColors.statusValideGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

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
                        BorderRadius.circular(AppConstants.radiusRound),
                  ),
                ),
                child: Text(
                  'profile.send_validation'.tr(),
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilySofiaSans,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: AppConstants.fontSizeLarge,
                  ),
                ),
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
                        BorderRadius.circular(AppConstants.radiusRound),
                  ),
                ),
                child: Text(
                  'documents.cancel'.tr(),
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilySofiaSans,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: AppConstants.fontSizeLarge,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// WIDGETS UTILITAIRES
// ─────────────────────────────────────────────────────────────────
class _ModalLabel extends StatelessWidget {
  final String text;
  const _ModalLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppConstants.fontFamilyInter,
        fontSize: AppConstants.fontSizeMedium,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
    );
  }
}

class _UploadPlaceholder extends StatelessWidget {
  final bool hasFile;
  const _UploadPlaceholder({required this.hasFile});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          hasFile ? Icons.insert_drive_file_outlined : Icons.cloud_upload_outlined,
          size: 36,
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        Text(
          hasFile ? 'profile.file_selected'.tr() : 'profile.click_upload'.tr(),
          style: TextStyle(
            fontFamily: AppConstants.fontFamilySofiaSans,
            fontWeight: FontWeight.w600,
            fontSize: AppConstants.fontSizeMedium,
            color: AppColors.primary,
          ),
        ),
        if (!hasFile)
          Text(
            'profile.file_format'.tr(),
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

class _ModalDateField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onTap;

  const _ModalDateField({
    required this.controller,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: TextStyle(
        fontFamily: AppConstants.fontFamilyInter,
        fontSize: AppConstants.fontSizeMedium,
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: AppConstants.fontFamilyInter,
          color: AppColors.hintText,
          fontSize: AppConstants.fontSizeMedium,
        ),
        suffixIcon: Icon(Icons.calendar_today_outlined,
            color: AppColors.textSecondary, size: AppConstants.iconSizeMedium),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// WIDGET IMAGE DOCUMENT — charge via le repository (isolé du BLoC)
// ─────────────────────────────────────────────────────────────────
class _DocumentImage extends StatefulWidget {
  final String documentId;
  final String? directUrl; // URL MinIO signée directe
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
    // Ne pas accéder au context ici — utiliser didChangeDependencies
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
          data[0] == 0x25 && data[1] == 0x50 &&
          data[2] == 0x44 && data[3] == 0x46;
      if (pdf) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/thumb_${widget.documentId}.pdf');
        await file.writeAsBytes(data);
        if (mounted) setState(() { _isPdf = true; _pdfPath = file.path; _loading = false; });
      } else {
        if (mounted) setState(() { _bytes = data; _loading = false; });
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
// WIDGET 2 IMAGES VERTICALES pour la card
// ─────────────────────────────────────────────────────────────────
class _DocumentImageDouble extends StatelessWidget {
  final String id1;
  final String? url1;
  final String id2;
  final String? url2;
  const _DocumentImageDouble({super.key, required this.id1, this.url1, required this.id2, this.url2});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: SizedBox.expand(child: _DocumentImage(key: ValueKey(id1), documentId: id1, directUrl: url1))),
        Container(height: 1, color: AppColors.borderLight),
        Expanded(child: SizedBox.expand(child: _DocumentImage(key: ValueKey(id2), documentId: id2, directUrl: url2))),
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
  final void Function(String filePath)? onFileSelected;

  const _DocumentOptionsSheet({
    required this.documentType,
    required this.existing,
    this.onFileSelected,
  });

  void _openSingleFileModal(BuildContext context, String fileId, String label) {
    final bloc = context.read<ProfileBloc>();
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _SingleFileUpdateModal(fileId: fileId, label: label, documentType: documentType, existing: existing),
      ),
    );
  }

  void _confirmDeleteFile(BuildContext context, String fileId, String label) {
    final bloc = context.read<ProfileBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
        title: Text('${'documents.delete'.tr()} $label', style: TextStyle(fontFamily: AppConstants.fontFamilySofiaSans, fontWeight: FontWeight.w700, fontSize: AppConstants.fontSizeLarge, color: AppColors.textDark)),
        content: Text('documents.delete_file_confirm'.tr(),
            style: TextStyle(fontFamily: AppConstants.fontFamilyInter, fontSize: AppConstants.fontSizeMedium, color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(),
              child: Text('documents.cancel'.tr(), style: TextStyle(fontFamily: AppConstants.fontFamilyInter, color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              ProfileDocumentRepository.invalidate(fileId);
              bloc.add(DeleteProfileDocumentEvent(documentId: fileId));
            },
            child: Text('documents.delete'.tr(), style: TextStyle(fontFamily: AppConstants.fontFamilyInter, color: AppColors.statusRejected, fontWeight: FontWeight.w600)),
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
            Center(child: Container(width: AppConstants.modalHandleWidth, height: AppConstants.modalHandleHeight,
                decoration: BoxDecoration(color: AppColors.modalHandle, borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 20),
            Align(alignment: Alignment.centerLeft,
                child: Text(documentType.title, style: TextStyle(fontFamily: AppConstants.fontFamilySofiaSans, fontWeight: FontWeight.w700, fontSize: AppConstants.fontSizeXXLarge, color: AppColors.textDark))),
            const SizedBox(height: 24),
            // Visualiser
            SizedBox(
              width: double.infinity, height: AppConstants.logoutButtonHeight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => _DocumentViewerPage(
                      label: documentType.title,
                      existing: existing,
                    ),
                  ));
                },
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: Text('documents.view'.tr(), style: TextStyle(fontFamily: AppConstants.fontFamilySofiaSans, fontWeight: FontWeight.w600, fontSize: AppConstants.fontSizeLarge)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, foregroundColor: AppColors.white, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusRound))),
              ),
            ),
            const SizedBox(height: 12),
            // Modifier
            _outlinedBtn(context, Icons.edit_outlined, 'documents.modify'.tr(), () {
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
            _dangerBtn(context, Icons.delete_outline, 'documents.delete'.tr(), () {
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final bp = MediaQuery.of(ctx).padding.bottom;
        return BlocProvider.value(
          value: bloc,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(child: Container(width: AppConstants.modalHandleWidth, height: AppConstants.modalHandleHeight,
                    decoration: BoxDecoration(color: AppColors.modalHandle, borderRadius: BorderRadius.circular(999)))),
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerLeft,
                    child: Text('documents.modify_choose'.tr(),
                        style: TextStyle(fontFamily: AppConstants.fontFamilySofiaSans, fontWeight: FontWeight.w700, fontSize: AppConstants.fontSizeLarge, color: AppColors.textDark))),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: AppConstants.logoutButtonHeight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      showModalBottomSheet(
                        context: ctx,
                        isScrollControlled: true,
                        backgroundColor: AppColors.white,
                        useSafeArea: true,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                        builder: (_) => BlocProvider.value(value: bloc,
                            child: _SingleFileUpdateModal(fileId: existing.id, label: 'Document 1', documentType: documentType, existing: existing)),
                      );
                    },
                    icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryDark),
                    label: Text('documents.modify_doc1'.tr(), style: TextStyle(fontFamily: AppConstants.fontFamilySofiaSans, fontWeight: FontWeight.w600, fontSize: AppConstants.fontSizeLarge, color: AppColors.primaryDark)),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.primaryDark), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusRound))),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, height: AppConstants.logoutButtonHeight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      showModalBottomSheet(
                        context: ctx,
                        isScrollControlled: true,
                        backgroundColor: AppColors.white,
                        useSafeArea: true,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                        builder: (_) => BlocProvider.value(value: bloc,
                            child: _SingleFileUpdateModal(fileId: existing.backFileId!, label: 'Document 2', documentType: documentType, existing: existing)),
                      );
                    },
                    icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryDark),
                    label: Text('documents.modify_doc2'.tr(), style: TextStyle(fontFamily: AppConstants.fontFamilySofiaSans, fontWeight: FontWeight.w600, fontSize: AppConstants.fontSizeLarge, color: AppColors.primaryDark)),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.primaryDark), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusRound))),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final bp = MediaQuery.of(ctx).padding.bottom;
        return BlocProvider.value(
          value: bloc,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(child: Container(width: AppConstants.modalHandleWidth, height: AppConstants.modalHandleHeight,
                    decoration: BoxDecoration(color: AppColors.modalHandle, borderRadius: BorderRadius.circular(999)))),
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerLeft,
                    child: Text('documents.delete_choose'.tr(),
                        style: TextStyle(fontFamily: AppConstants.fontFamilySofiaSans, fontWeight: FontWeight.w700, fontSize: AppConstants.fontSizeLarge, color: AppColors.textDark))),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: AppConstants.logoutButtonHeight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _confirmDeleteFileDirect(ctx, bloc, existing.id, 'Document 1');
                    },
                    icon: Icon(Icons.delete_outline, size: 18, color: AppColors.statusRejected),
                    label: Text('documents.delete_doc1'.tr(), style: TextStyle(fontFamily: AppConstants.fontFamilySofiaSans, fontWeight: FontWeight.w600, fontSize: AppConstants.fontSizeLarge, color: AppColors.statusRejected)),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.statusRejected), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusRound))),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, height: AppConstants.logoutButtonHeight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _confirmDeleteFileDirect(ctx, bloc, existing.backFileId!, 'Document 2');
                    },
                    icon: Icon(Icons.delete_outline, size: 18, color: AppColors.statusRejected),
                    label: Text('documents.delete_doc2'.tr(), style: TextStyle(fontFamily: AppConstants.fontFamilySofiaSans, fontWeight: FontWeight.w600, fontSize: AppConstants.fontSizeLarge, color: AppColors.statusRejected)),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.statusRejected), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusRound))),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteFileDirect(BuildContext context, ProfileBloc bloc, String fileId, String label) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
        title: Text('${'documents.delete'.tr()} $label', style: TextStyle(fontFamily: AppConstants.fontFamilySofiaSans, fontWeight: FontWeight.w700, fontSize: AppConstants.fontSizeLarge, color: AppColors.textDark)),
        content: Text('documents.delete_file_confirm'.tr(),
            style: TextStyle(fontFamily: AppConstants.fontFamilyInter, fontSize: AppConstants.fontSizeMedium, color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(),
              child: Text('documents.cancel'.tr(), style: TextStyle(fontFamily: AppConstants.fontFamilyInter, color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ProfileDocumentRepository.invalidate(fileId);
              bloc.add(DeleteProfileDocumentEvent(documentId: fileId));
            },
            child: Text('documents.delete'.tr(), style: TextStyle(fontFamily: AppConstants.fontFamilyInter, color: AppColors.statusRejected, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _outlinedBtn(BuildContext context, IconData icon, String label, VoidCallback onTap) => SizedBox(
    width: double.infinity, height: AppConstants.logoutButtonHeight,
    child: OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: AppColors.primaryDark),
      label: Text(label, style: TextStyle(fontFamily: AppConstants.fontFamilySofiaSans, fontWeight: FontWeight.w600, fontSize: AppConstants.fontSizeLarge, color: AppColors.primaryDark)),
      style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.primaryDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusRound))),
    ),
  );

  Widget _dangerBtn(BuildContext context, IconData icon, String label, VoidCallback onTap) => SizedBox(
    width: double.infinity, height: AppConstants.logoutButtonHeight,
    child: OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: AppColors.statusRejected),
      label: Text(label, style: TextStyle(fontFamily: AppConstants.fontFamilySofiaSans, fontWeight: FontWeight.w600, fontSize: AppConstants.fontSizeLarge, color: AppColors.statusRejected)),
      style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.statusRejected),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusRound))),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// MODAL MODIFICATION D'UN SEUL FICHIER
// ─────────────────────────────────────────────────────────────────
class _SingleFileUpdateModal extends StatefulWidget {
  final String fileId;
  final String label;
  final DocumentTypeModel documentType;
  final UploadedDocumentModel existing;

  const _SingleFileUpdateModal({required this.fileId, required this.label, required this.documentType, required this.existing});

  @override
  State<_SingleFileUpdateModal> createState() => _SingleFileUpdateModalState();
}

class _SingleFileUpdateModalState extends State<_SingleFileUpdateModal> {
  String? _filePath;
  String? _secondFilePath;
  late final ProfileBloc _bloc;

  @override
  void initState() { super.initState(); _bloc = context.read<ProfileBloc>(); }

  Future<void> _pickFile({bool isSecond = false}) async {
    final path = await showPickerSource(context);
    if (path == null || !mounted) return;
    setState(() => isSecond ? _secondFilePath = path : _filePath = path);
  }

  void _onEnvoyer() {
    if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Veuillez sélectionner un fichier.', style: TextStyle(fontFamily: AppConstants.fontFamilyInter, color: AppColors.white)),
        backgroundColor: AppColors.statusRejected, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    ProfileDocumentRepository.invalidate(widget.fileId);
    _bloc.add(ReplaceProfileDocumentFileEvent(
      documentId: widget.fileId,
      file: File(_filePath!),
      issueDate: widget.existing.issueDate,
      expirationDate: widget.existing.expirationDate,
    ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isImage = _filePath != null && !_filePath!.endsWith('.pdf');
    final isImage2 = _secondFilePath != null && !_secondFilePath!.endsWith('.pdf');
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 16, left: 20, right: 20, top: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: AppConstants.modalHandleWidth, height: AppConstants.modalHandleHeight,
                decoration: BoxDecoration(color: AppColors.modalHandle, borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${'documents.modify_doc_label'.tr()} ${widget.label}', style: TextStyle(fontFamily: AppConstants.fontFamilySofiaSans, fontWeight: FontWeight.w700, fontSize: AppConstants.fontSizeXXLarge, color: AppColors.textDark)),
                GestureDetector(onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, color: AppColors.textSecondary, size: AppConstants.iconSizeLarge)),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _pickFile(),
              child: Container(
                width: double.infinity, height: 140,
                decoration: BoxDecoration(color: AppColors.documentCardBackground,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
                child: _filePath != null && isImage
                    ? ClipRRect(borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                        child: Image.file(File(_filePath!), fit: BoxFit.cover, width: double.infinity))
                    : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(_filePath != null ? Icons.insert_drive_file_outlined : Icons.cloud_upload_outlined, size: 36, color: AppColors.primary),
                        const SizedBox(height: 8),
                        Text(_filePath != null ? 'documents.file_selected'.tr() : 'documents.click_to_upload'.tr(),
                            style: TextStyle(fontFamily: AppConstants.fontFamilySofiaSans, fontWeight: FontWeight.w600, fontSize: AppConstants.fontSizeMedium, color: AppColors.primary)),
                        if (_filePath == null)
                          Text('PDF, JPG, PNG jusqu\'à 10 Mo',
                              style: TextStyle(fontFamily: AppConstants.fontFamilyInter, fontSize: AppConstants.fontSizeRegular, color: AppColors.textSecondary)),
                      ]),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: AppConstants.logoutButtonHeight,
              child: ElevatedButton(onPressed: _onEnvoyer,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusRound))),
                child: Text('documents.send_for_validation'.tr(), style: TextStyle(fontFamily: AppConstants.fontFamilySofiaSans, color: AppColors.white, fontWeight: FontWeight.w600, fontSize: AppConstants.fontSizeLarge)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, height: AppConstants.logoutButtonHeight,
              child: OutlinedButton(onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.primaryDark),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusRound))),
                child: Text('documents.cancel'.tr(), style: TextStyle(fontFamily: AppConstants.fontFamilySofiaSans, color: AppColors.primaryDark, fontWeight: FontWeight.w600, fontSize: AppConstants.fontSizeLarge)),
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
// VIEWER SHEET — Affiche recto + verso avec PageView horizontal
// ─────────────────────────────────────────────────────────────────
class _DocumentViewerSheet extends StatefulWidget {
  final String label;
  final UploadedDocumentModel existing;

  const _DocumentViewerSheet({
    required this.label,
    required this.existing,
  });

  @override
  State<_DocumentViewerSheet> createState() => _DocumentViewerSheetState();
}

class _DocumentViewerSheetState extends State<_DocumentViewerSheet> {
  final List<Map<String, dynamic>> _pages = [];
  bool _loading = true;
  int _currentPage = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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
        final data = await _fetchFile(
          token: token,
          fileId: f['id'] as String,
          directUrl: f['url'] as String?,
        );
        final isPdf = data.length >= 4 &&
            data[0] == 0x25 && data[1] == 0x50 &&
            data[2] == 0x44 && data[3] == 0x46;
        if (isPdf) {
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/viewer_mes_docs_${f["id"]}.pdf');
          await file.writeAsBytes(data);
          results.add({'pdfPath': file.path});
        } else {
          results.add({'bytes': data});
        }
      } catch (e) {
        results.add({'error': e.toString()});
      }
    }
    if (mounted) setState(() { _pages.addAll(results); _loading = false; });
  }

  /// Essaie d'abord l'URL MinIO directe, fallback sur l'endpoint /file avec token
  Future<Uint8List> _fetchFile({
    required String token,
    required String fileId,
    String? directUrl,
  }) async {
    // 1. Essai URL MinIO directe
    if (directUrl != null && directUrl.isNotEmpty) {
      try {
        final res = await http.get(Uri.parse(directUrl))
            .timeout(const Duration(seconds: 20));
        if (res.statusCode == 200) return res.bodyBytes;
        // 403/expired → fallback
      } catch (_) {}
    }
    // 2. Fallback endpoint /file avec Bearer token
    final url = BaseUrl.profileDocumentFile(fileId);
    final res = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
    ).timeout(const Duration(seconds: 30));
    if (res.statusCode == 200) return res.bodyBytes;
    throw Exception('Erreur ${res.statusCode}');
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final total = _pages.length;
    return Container(
      height: screenH,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilySofiaSans,
                          fontWeight: FontWeight.w700,
                          fontSize: AppConstants.fontSizeXXLarge,
                          color: AppColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!_loading && total > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentPage + 1}/$total',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontSize: AppConstants.fontSizeRegular,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.close,
                          color: AppColors.textSecondary,
                          size: AppConstants.iconSizeLarge),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.primaryDark),
                    ),
                  )
                : total == 0
                    ? Center(child: Icon(Icons.insert_drive_file_outlined, size: 80, color: AppColors.primary))
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
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.textDark.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.swipe, color: AppColors.white, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        'documents.swipe_hint'.tr(),
                                        style: TextStyle(
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
            Icon(Icons.error_outline, color: AppColors.statusRejected, size: 48),
            const SizedBox(height: 12),
            Text(
              page['error'] as String,
              style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                color: AppColors.textSecondary,
                fontSize: AppConstants.fontSizeMedium,
              ),
            ),
          ],
        ),
      );
    }
    if (page['pdfPath'] != null) {
      return _PdfBytesViewer(filePath: page['pdfPath'] as String);
    }
    if (page['bytes'] != null) {
      return _ZoomablePage(bytes: page['bytes'] as Uint8List);
    }
    return Center(child: Icon(Icons.insert_drive_file_outlined, size: 80, color: AppColors.primary));
  }
}

// ─────────────────────────────────────────────────────────────────
// PAGE PLEIN ÉCRAN — Visualiser document (remplace le bottom sheet)
// ─────────────────────────────────────────────────────────────────
class _DocumentViewerPage extends StatefulWidget {
  final String label;
  final UploadedDocumentModel existing;
  const _DocumentViewerPage({required this.label, required this.existing});

  @override
  State<_DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<_DocumentViewerPage> {
  final List<Map<String, dynamic>> _pages = [];
  bool _loading = true;
  int _currentPage = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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
        final data = await _fetchFile(
          token: token,
          fileId: f['id'] as String,
          directUrl: f['url'] as String?,
        );
        final isPdf = data.length >= 4 &&
            data[0] == 0x25 && data[1] == 0x50 &&
            data[2] == 0x44 && data[3] == 0x46;
        if (isPdf) {
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/viewer_page_${f["id"]}.pdf');
          await file.writeAsBytes(data);
          results.add({'pdfPath': file.path});
        } else {
          results.add({'bytes': data});
        }
      } catch (e) {
        results.add({'error': e.toString()});
      }
    }
    if (mounted) setState(() { _pages.addAll(results); _loading = false; });
  }

  Future<Uint8List> _fetchFile({
    required String token,
    required String fileId,
    String? directUrl,
  }) async {
    if (directUrl != null && directUrl.isNotEmpty) {
      try {
        final res = await http.get(Uri.parse(directUrl))
            .timeout(const Duration(seconds: 20));
        if (res.statusCode == 200) return res.bodyBytes;
      } catch (_) {}
    }
    final url = BaseUrl.profileDocumentFile(fileId);
    final res = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
    ).timeout(const Duration(seconds: 30));
    if (res.statusCode == 200) return res.bodyBytes;
    throw Exception('Erreur ${res.statusCode}');
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
          widget.label,
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
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            )
          : total == 0
              ? Center(
                  child: Icon(Icons.insert_drive_file_outlined,
                      size: 80, color: AppColors.primary),
                )
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
            nightMode: false,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

// ─────────────────────────────────────────────────────────────────
// PAGE ZOOMABLE
// ─────────────────────────────────────────────────────────────────
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
            errorBuilder: (_, __, ___) => Icon(Icons.insert_drive_file_outlined, size: 80, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PDF VIEWER — affiche un PDF depuis un chemin fichier
// ─────────────────────────────────────────────────────────────────
class _PdfBytesViewer extends StatelessWidget {
  final String filePath;
  const _PdfBytesViewer({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0,
      child: SizedBox.expand(
        child: PDFView(
          filePath: filePath,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: false,
          pageFling: false,
          pageSnap: false,
          fitPolicy: FitPolicy.WIDTH,
          enableRenderDuringScale: true,
          useBestQuality: true,
          nightMode: false,
        ),
      ),
    );
  }
}
