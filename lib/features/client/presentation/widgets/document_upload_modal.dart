import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/services/mlkit_ocr_service.dart';
import 'package:secure_link/features/client/data/models/profile_model.dart';
import 'package:secure_link/features/client/domain/bloc/profile_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/profile_event.dart';
import 'package:secure_link/features/client/domain/bloc/profile_state.dart';
import '../pages/document_scanner_page.dart';

// ─────────────────────────────────────────────────────────────────
// MODAL UPLOAD DOCUMENT AVEC VÉRIFICATION D'IDENTITÉ
// (Pièce d'identité, Permis de conduire, Photo d'identité)
// ─────────────────────────────────────────────────────────────────
class DocumentUploadModal extends StatefulWidget {
  final DocumentTypeModel documentType;
  final UploadedDocumentModel? existingDocument;

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
  String? _backFilePath;
  bool _showBack = false; // verso masqué par défaut
  bool _isScanning = false; // OCR en cours
  late final ProfileBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ProfileBloc>();
    if (widget.existingDocument != null) {
      _deliveryDateController.text = widget.existingDocument!.issueDate ?? '';
      _expiryDateController.text = widget.existingDocument!.expirationDate ?? '';
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

  Future<void> _pickFile({bool isBack = false}) async {
    final choice = await showPickerSource(context);
    if (choice == null) return;

    String? picked;
    if (choice == 'camera' && !isBack && widget.documentType.hasExpirationDate) {
      // Prendre une photo sur doc avec expiration → scanner OCR
      picked = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const DocumentScannerPage()),
      );
    } else if (choice == 'camera') {
      final x = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
      picked = x?.path;
    } else if (choice == 'gallery') {
      final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
      picked = x?.path;
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      picked = result?.files.single.path;
    }

    if (picked == null) return;
    if (isBack) {
      setState(() => _backFilePath = picked);
    } else {
      setState(() => _uploadedFilePath = picked);
      if (widget.documentType.hasExpirationDate) {
        await _runOcr(picked!);
      }
    }
  }

  Future<void> _runOcr(String filePath) async {
    setState(() => _isScanning = true);
    try {
      final result = await MlKitOcrService.extractDatesFromDocument(File(filePath));
      if (!mounted) return;
      if (result.issueDate != null && _deliveryDateController.text.isEmpty) {
        _deliveryDateController.text = result.issueDate!;
      }
      if (result.expirationDate != null && _expiryDateController.text.isEmpty) {
        _expiryDateController.text = result.expirationDate!;
      }
      if (result.hasDates) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Dates détectées automatiquement ✓',
              style: TextStyle(fontFamily: AppConstants.fontFamilyInter, color: AppColors.white),
            ),
            backgroundColor: AppColors.statusValideGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _onEnvoyer() {
    final hasDates = widget.documentType.hasExpirationDate;

    if (_uploadedFilePath == null ||
        (hasDates && _deliveryDateController.text.isEmpty) ||
        (hasDates && _expiryDateController.text.isEmpty)) {
      if (!mounted) return;
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    _bloc.add(
      UploadProfileDocumentEvent(
        file: File(_uploadedFilePath!),
        backFile: _backFilePath != null ? File(_backFilePath!) : null,
        documentTypeId: widget.documentType.id,
        issueDate: _deliveryDateController.text.isNotEmpty
            ? _deliveryDateController.text
            : null,
        expirationDate: _expiryDateController.text.isNotEmpty
            ? _expiryDateController.text
            : null,
      ),
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasExpiry = widget.documentType.hasExpirationDate;

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: Padding(
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
                    child: Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: AppConstants.iconSizeLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Type de document (lecture seule)
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

              // Zone upload principale (en premier pour déclencher l'OCR)
              GestureDetector(
                onTap: _isScanning ? null : () => _pickFile(),
                child: _UploadZone(
                  filePath: _uploadedFilePath,
                  isScanning: _isScanning,
                ),
              ),
              const SizedBox(height: 10),

              // Bouton discret "Ajouter un autre document" ou zone verso
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
                  child: _UploadZone(filePath: _backFilePath),
                ),
              ],
              const SizedBox(height: 16),

              // Dates (uniquement si hasExpirationDate: true) — après l'upload pour l'OCR
              if (hasExpiry) ...[
                _ModalLabel(text: 'profile.delivery_date'.tr()),
                const SizedBox(height: 6),
                _ModalDateField(
                  controller: _deliveryDateController,
                  hint: 'profile.delivery_date_hint'.tr(),
                  onTap: () => _pickDate(context, _deliveryDateController),
                ),
                const SizedBox(height: 16),
                _ModalLabel(text: 'profile.expiry_date'.tr()),
                const SizedBox(height: 6),
                _ModalDateField(
                  controller: _expiryDateController,
                  hint: 'profile.expiry_date_hint'.tr(),
                  onTap: () => _pickDate(context, _expiryDateController, isExpiry: true),
                ),
                const SizedBox(height: 16),
              ],

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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// WIDGETS UTILITAIRES
// ─────────────────────────────────────────────────────────────────

/// Affiche le bottom sheet de choix de source (galerie / caméra / fichier)
/// Retourne le chemin du fichier sélectionné ou null
Future<String?> showPickerSource(BuildContext context) async {
  return showModalBottomSheet<String>(
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
            leading: Icon(Icons.photo_library_outlined, color: AppColors.primary),
            title: Text('profile.gallery'.tr(),
                style: TextStyle(fontFamily: AppConstants.fontFamilyInter, color: AppColors.textDark, fontWeight: FontWeight.w500)),
            onTap: () => Navigator.pop(context, 'gallery'),
          ),
          ListTile(
            leading: Icon(Icons.camera_alt_outlined, color: AppColors.primary),
            title: Text('profile.take_photo'.tr(),
                style: TextStyle(fontFamily: AppConstants.fontFamilyInter, color: AppColors.textDark, fontWeight: FontWeight.w500)),
            onTap: () => Navigator.pop(context, 'camera'),
          ),
          ListTile(
            leading: Icon(Icons.insert_drive_file_outlined, color: AppColors.primary),
            title: Text('profile.pick_file'.tr(),
                style: TextStyle(fontFamily: AppConstants.fontFamilyInter, color: AppColors.textDark, fontWeight: FontWeight.w500)),
            onTap: () => Navigator.pop(context, 'file'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Zone d'upload générique (recto ou verso)
class _UploadZone extends StatelessWidget {
  final String? filePath;
  final bool isScanning;
  const _UploadZone({this.filePath, this.isScanning = false});

  bool get _isImage {
    if (filePath == null) return false;
    final ext = filePath!.split('.').last.toLowerCase();
    return ext == 'jpg' || ext == 'jpeg' || ext == 'png';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.docUploadBg,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(color: AppColors.docUploadBorder, width: 1),
      ),
      child: isScanning
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lecture des dates en cours...',
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    fontSize: AppConstants.fontSizeRegular,
                    color: AppColors.primary,
                  ),
                ),
              ],
            )
          : filePath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  child: _isImage
                      ? Image.file(File(filePath!), fit: BoxFit.cover, width: double.infinity,
                          errorBuilder: (_, __, ___) => const _UploadPlaceholder(hasFile: true))
                      : const _UploadPlaceholder(hasFile: true),
                )
              : const _UploadPlaceholder(hasFile: false),
    );
  }
}

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
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.docUploadIconBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/televerser.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hasFile ? 'profile.file_selected'.tr() : 'profile.click_upload'.tr(),
          style: TextStyle(
            fontFamily: AppConstants.fontFamilySofiaSans,
            fontWeight: FontWeight.w600,
            fontSize: AppConstants.fontSizeMedium,
            color: AppColors.docUploadClickText,
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
        suffixIcon: Icon(
          Icons.calendar_today_outlined,
          color: AppColors.textSecondary,
          size: AppConstants.iconSizeMedium,
        ),
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
