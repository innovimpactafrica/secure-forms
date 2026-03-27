import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/utils/base_url.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/client/data/models/profile_model.dart';
import 'package:secure_link/features/client/data/repositories/profile_document_repository.dart';
import 'package:secure_link/features/client/domain/bloc/profile_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/profile_event.dart';
import 'package:secure_link/features/client/domain/bloc/profile_state.dart';
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
    // ignore: avoid_print
    print('[MesDocumentsScreen] Chargement documents — token présent: ${token.isNotEmpty}');
    try {
      final types = await _repository.getDocumentTypes(token);
      final docs = await _repository.getDocuments(token);
      // ignore: avoid_print
      print('[MesDocumentsScreen] ${types.length} type(s) | ${docs.length} document(s) uploadé(s)');
      if (mounted) {
        setState(() {
          _documentTypes = types;
          _uploadedDocuments = docs;
          _isLoading = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('[MesDocumentsScreen] ERREUR: $e');
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
          // Vider le cache local des fichiers affichés
          if (state is ProfileDocumentDeleted) {
            _localFileCache.clear();
          }
          _loadData();
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
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                            child: _DocumentsGrid(
                              documentTypes: _documentTypes,
                              uploadedDocuments: _uploadedDocuments,
                              localFileCache: _localFileCache,
                              onFileSelected: _onFileSelected,
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

  const _DocumentsGrid({
    required this.documentTypes,
    required this.uploadedDocuments,
    required this.localFileCache,
    required this.onFileSelected,
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
        useSafeArea: true, // ✅ protège du navbar
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
      useSafeArea: true, // ✅ protège du navbar
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

  const _DocumentCard({
    required this.documentType,
    required this.uploadedDocument,
    required this.onTap,
    this.localFilePath,
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
                            key: ValueKey(uploadedDocument?.id ?? ''),
                            documentId: uploadedDocument!.id,
                          ),
                        )
                      : hasDoc
                          ? _DocumentImage(
                              key: ValueKey(uploadedDocument!.id + (uploadedDocument!.uploadedAt?.toIso8601String() ?? '')),
                              documentId: uploadedDocument!.id,
                            )
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

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.white,
      useSafeArea: true, // ✅ protège du navbar pour la sélection photo/galerie
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: Text('profile.gallery'.tr(),
                  style: TextStyle(
                      fontFamily: AppConstants.fontFamilyInter,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              title: Text('profile.take_photo'.tr(),
                  style: TextStyle(
                      fontFamily: AppConstants.fontFamilyInter,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    final XFile? picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked != null && mounted) {
      setState(() {
        _uploadedFilePath = picked.path;
        _isImage = true;
      });
      widget.onFileSelected?.call(picked.path);
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
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.documentCardBackground,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: _uploadedFilePath != null && _isImage
                      ? ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusSmall),
                          child: Image.file(
                            File(_uploadedFilePath!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) =>
                                const _UploadPlaceholder(hasFile: true),
                          ),
                        )
                      : _UploadPlaceholder(hasFile: _uploadedFilePath != null),
                ),
              ),
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
  const _DocumentImage({super.key, required this.documentId});

  @override
  State<_DocumentImage> createState() => _DocumentImageState();
}

class _DocumentImageState extends State<_DocumentImage> {
  Uint8List? _bytes;
  bool _loading = true;
  late final ProfileDocumentRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = context.read<ProfileBloc>().repository;
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await _repo.getDocumentFile(
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
  final void Function(String filePath)? onFileSelected;

  const _DocumentOptionsSheet({
    required this.documentType,
    required this.existing,
    this.onFileSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 32 + bottomPadding), // ✅ espace au-dessus du navbar
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
                  useSafeArea: true, // ✅ protège du navbar
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => _DocumentViewerSheet(
                    label: documentType.title,
                    documentId: existing.id,
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
                  useSafeArea: true, // ✅ protège du navbar
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => BlocProvider.value(
                    value: context.read<ProfileBloc>(),
                    child: _DocumentUpdateModal(
                      documentType: documentType,
                      existingDocument: existing,
                      onFileSelected: onFileSelected,
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
// VIEWER SHEET — charge le fichier via l'API avec token
// ─────────────────────────────────────────────────────────────────
class _DocumentViewerSheet extends StatefulWidget {
  final String label;
  final String documentId;

  const _DocumentViewerSheet({
    required this.label,
    required this.documentId,
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
      final token = UserSession.instance.accessToken;
      final url = BaseUrl.profileDocumentFile(widget.documentId);
      // ignore: avoid_print
      print('[DocumentViewer] GET $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
      );
      // ignore: avoid_print
      print('[DocumentViewer] status=${response.statusCode} contentType=${response.headers['content-type']} size=${response.bodyBytes.length}');
      if (response.statusCode == 200) {
        if (mounted) setState(() { _bytes = response.bodyBytes; _loading = false; });
      } else {
        if (mounted) setState(() { _loading = false; _error = 'Erreur ${response.statusCode}'; });
      }
    } catch (e) {
      // ignore: avoid_print
      print('[DocumentViewer] ERROR: $e');
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  bool get _isPdf {
    if (_bytes == null || _bytes!.length < 4) return false;
    return _bytes![0] == 0x25 && _bytes![1] == 0x50 &&
           _bytes![2] == 0x44 && _bytes![3] == 0x46;
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      height: screenH * 0.85,
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomPadding), // ✅ espace au-dessus du navbar
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
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.close,
                    color: AppColors.textSecondary,
                    size: AppConstants.iconSizeLarge),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                            Icon(Icons.error_outline,
                                color: AppColors.statusRejected, size: 48),
                            const SizedBox(height: 12),
                            Text(_error!,
                                style: TextStyle(
                                  fontFamily: AppConstants.fontFamilyInter,
                                  color: AppColors.textSecondary,
                                  fontSize: AppConstants.fontSizeMedium,
                                )),
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
                                      widget.label,
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