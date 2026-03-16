import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/features/auth/domain/bloc/user_bloc.dart';
import 'package:secure_link/features/auth/domain/bloc/user_state.dart';
import 'package:secure_link/features/client/data/models/profile_model.dart';
import 'package:secure_link/features/client/domain/bloc/profile_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/profile_event.dart';
import 'package:secure_link/features/client/domain/bloc/profile_state.dart';
import 'face_verification_screen.dart';
import 'complete_profile_header.dart';

/// Étape 2 — Upload des documents
/// TODO: connecter l'upload réel à l'API
class Step2DocumentsScreen extends StatelessWidget {
  const Step2DocumentsScreen({super.key});

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
       
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.statusRejected,
            ),
          );
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final profile = _getProfile(state);
          final progressValue = profile.progressPercent;
          final progressLabel = '${(progressValue * 100).toInt()}%';
          final hasDocuments = profile.documents.isNotEmpty;

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
                    child: SingleChildScrollView(
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
                          _DocumentsGrid(documents: profile.documents),
                          const SizedBox(height: 32),

                          // ── Bouton VALIDER — toujours visible ──
                          SizedBox(
                            width: double.infinity,
                            height: AppConstants.logoutButtonHeight,
                            child: ElevatedButton(
                              // APRÈS
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
  // 1 — Dispatcher l'event AVANT de naviguer
  context.read<ProfileBloc>().add(const CompleteProfileEvent());
  // 2 — Naviguer vers Home
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
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.radiusRound),
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

  ProfileModel _getProfile(ProfileState state) {
    if (state is ProfileInProgress) return state.profile;
    if (state is ProfileStep1Validated) return state.profile;
    if (state is ProfileDocumentAdded) return state.profile;
    if (state is ProfileFaceVerificationSuccess) return state.profile;
    if (state is ProfileFaceVerificationFailed) return state.profile;
    if (state is ProfileCompleted) return state.profile;
    return const ProfileModel(progressPercent: 0.50);
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
// GRILLE 2 colonnes
// ─────────────────────────────────────────────────────────────────
class _DocumentsGrid extends StatelessWidget {
  final List<DocumentModel> documents;

  const _DocumentsGrid({required this.documents});

  @override
  Widget build(BuildContext context) {
    final types = DocumentType.all;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final doc = documents.where((d) => d.type == type).firstOrNull;
        return _DocumentCard(
          type: type,
          document: doc,
          onTap: () => _showUploadModal(context, type, doc),
        );
      },
    );
  }

  void _showUploadModal(
      BuildContext context, String documentType, DocumentModel? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: DocumentUploadModal(
          documentType: documentType,
          existingDocument: existing,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CARD DOCUMENT — zone bleue claire + bande grise en bas avec nom
// ─────────────────────────────────────────────────────────────────
class _DocumentCard extends StatelessWidget {
  final String type;
  final DocumentModel? document;
  final VoidCallback onTap;

  const _DocumentCard({
    required this.type,
    required this.document,
    required this.onTap,
  });

  Color _statusColor() {
    if (document == null) return AppColors.borderLight;
    switch (document!.status) {
      case DocumentStatus.validated:
        return AppColors.statusValideGreen;
      case DocumentStatus.pending:
        return AppColors.statusEnAttente;
      case DocumentStatus.inProgress:
        return AppColors.primary;
      case DocumentStatus.rejected:
        return AppColors.statusRejected;
    }
  }

  String _formatDate(String date) {
  try {
    final parts = date.split('/');
    if (parts.length != 3) return date;
    final day = parts[0];
    final month = int.parse(parts[1]);
    final year = parts[2];
    const months = [
      '', 'janv.', 'févr.', 'mars', 'avr.',
      'mai', 'juin', 'juil.', 'août',
      'sept.', 'oct.', 'nov.', 'déc.'
    ];
    return '$day ${months[month]}$year';
  } catch (_) {
    return date;
  }
}

  @override
  Widget build(BuildContext context) {
    final hasDoc = document != null;
    final filePath = document?.filePath;
    final isImage = filePath != null &&
        (filePath.endsWith('.jpg') ||
            filePath.endsWith('.jpeg') ||
            filePath.endsWith('.png'));

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
            // ── Zone bleue claire avec image ou icône ──
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusSmall),
                    topRight: Radius.circular(AppConstants.radiusSmall),
                  ),
                ),
                child: hasDoc && isImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppConstants.radiusSmall),
                          topRight: Radius.circular(AppConstants.radiusSmall),
                        ),
                        child: Image.file(
                          File(filePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              Icons.check_circle_outline,
                              size: 36,
                              color: _statusColor(),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          hasDoc
                              ? Icons.check_circle_outline
                              : Icons.add_photo_alternate_outlined,
                          size: 36,
                          color: hasDoc ? _statusColor() : AppColors.primary,
                        ),
                      ),
              ),
            ),

            // ── Bande grise en bas avec nom + point statut ──
            // ── Bande grise en bas avec nom + date expiration si validé ──
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
              type.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontSize: 10,
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
            // Afficher la date d'expiration si document uploadé
           if (hasDoc && document!.expiryDate.isNotEmpty &&
    DocumentType.hasExpiryDate.contains(type))
              Text(
                'profile.expires_on'.tr() + ' ${_formatDate(document!.expiryDate)}',
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
// MODAL UPLOAD — file picker réel + aperçu image
// ─────────────────────────────────────────────────────────────────
class DocumentUploadModal extends StatefulWidget {
  final String documentType;
  final DocumentModel? existingDocument;

  const DocumentUploadModal({
    super.key,
    required this.documentType,
    this.existingDocument,
  });

  @override
  State<DocumentUploadModal> createState() => _DocumentUploadModalState();
}

class _DocumentUploadModalState extends State<DocumentUploadModal> {
  final _deliveryDateController = TextEditingController();
  final _expiryDateController = TextEditingController();
  String? _uploadedFilePath;
  bool _isImage = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingDocument != null) {
      _deliveryDateController.text = widget.existingDocument!.deliveryDate;
      _expiryDateController.text = widget.existingDocument!.expiryDate;
      _uploadedFilePath = widget.existingDocument!.filePath;
      _isImage = _uploadedFilePath != null &&
          (_uploadedFilePath!.endsWith('.jpg') ||
              _uploadedFilePath!.endsWith('.jpeg') ||
              _uploadedFilePath!.endsWith('.png'));
    }
  }
 
  @override
  void dispose() {
    _deliveryDateController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController controller, {
    bool isExpiry = false,
  }) async {
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

    // Choisir source : galerie ou caméra
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: Text(
                'profile.gallery'.tr(),
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title: Text(
                'profile.take_photo'.tr(),
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _uploadedFilePath = picked.path;
        _isImage = true;
      });
    }
  }

  void _onEnvoyer() {
    if (_deliveryDateController.text.isEmpty ||
        _expiryDateController.text.isEmpty ||
        _uploadedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'profile.fill_all_fields'.tr(),
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
      return;
    }

    // TODO: API — OCR vérification dates + upload fichier serveur
    context.read<ProfileBloc>().add(
          AddDocumentEvent(
            document: DocumentModel(
              type: widget.documentType,
              deliveryDate: _deliveryDateController.text,
              expiryDate: _expiryDateController.text,
              filePath: _uploadedFilePath!,
              status: DocumentStatus.pending,
            ),
          ),
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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

            // Titre + fermeture
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'profile.add_document'.tr(),
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilySofiaSans,
                    fontWeight: FontWeight.w700,
                    fontSize: AppConstants.fontSizeXXLarge,
                    color: AppColors.textDark,
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
            const SizedBox(height: 20),

            // Type de document (lecture seule)
            _ModalLabel(text: 'profile.document_type'.tr()),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Text(
                widget.documentType.tr(),
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date de délivrance
            _ModalLabel(text: 'profile.delivery_date'.tr()),
            const SizedBox(height: 6),
            _ModalDateField(
              controller: _deliveryDateController,
              hint: 'profile.delivery_date_hint'.tr(),
              onTap: () => _pickDate(context, _deliveryDateController),
            ),
            const SizedBox(height: 16),

            // Date d'expiration
            _ModalLabel(text: 'profile.expiry_date'.tr()),
            const SizedBox(height: 6),
            _ModalDateField(
              controller: _expiryDateController,
              hint: 'profile.expiry_date_hint'.tr(),
              onTap: () =>
                  _pickDate(context, _expiryDateController, isExpiry: true),
            ),
            const SizedBox(height: 16),

            // ── Zone upload : affiche l'aperçu si image choisie ──
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusSmall),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
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

            // Bouton Envoyer pour validation
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

            // Bouton Enregistrer
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
                  'profile.save'.tr(),
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
          hasFile
              ? Icons.insert_drive_file_outlined
              : Icons.cloud_upload_outlined,
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
            color: AppColors.textSecondary,
            size: AppConstants.iconSizeMedium),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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