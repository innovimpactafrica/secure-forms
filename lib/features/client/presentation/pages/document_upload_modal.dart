import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/features/client/data/models/profile_model.dart';
import 'package:secure_link/features/client/domain/bloc/profile_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/profile_event.dart';


// ─────────────────────────────────────────────────────────────────
// MODAL UPLOAD DOCUMENT (Figma Screen 4)
// ─────────────────────────────────────────────────────────────────
class DocumentUploadModal extends StatefulWidget {
  final String documentType;

  const DocumentUploadModal({super.key, required this.documentType});

  @override
  State<DocumentUploadModal> createState() => _DocumentUploadModalState();
}

class _DocumentUploadModalState extends State<DocumentUploadModal> {
  final _deliveryDateController = TextEditingController();
  final _expiryDateController = TextEditingController();
  String? _uploadedFilePath;

  @override
  void dispose() {
    _deliveryDateController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
      BuildContext context, TextEditingController controller,
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
        child: child!,
      ),
    );
    if (picked != null) {
      controller.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void _simulateFileUpload() {
    // TODO: API — implémenter le vrai file picker + upload
    setState(() {
      _uploadedFilePath = 'document_simule.pdf';
    });
  }

  void _onEnvoyer() {
    if (_deliveryDateController.text.isEmpty ||
        _expiryDateController.text.isEmpty ||
        _uploadedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile.fill_all_fields'.tr()),
          backgroundColor: AppColors.statusRejected,
        ),
      );
      return;
    }

    // TODO: API — vérification des dates (délivrance/expiration vs OCR photo)
    // Actuellement simulation locale
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: bottomInset + bottomPadding + 16,
          left: 20,
          right: 20,
          top: 16,
        ),
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
            Text(
              'profile.document_type'.tr(),
              style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Text(
                widget.documentType,
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date de délivrance
            Text(
              'profile.delivery_date'.tr(),
              style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            _ModalDateField(
              controller: _deliveryDateController,
              hint: 'profile.delivery_date_hint'.tr(),
              onTap: () => _pickDate(context, _deliveryDateController),
            ),
            const SizedBox(height: 16),

            // Date d'expiration
            Text(
              'profile.expiry_date'.tr(),
              style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            _ModalDateField(
              controller: _expiryDateController,
              hint: 'profile.expiry_date_hint'.tr(),
              onTap: () =>
                  _pickDate(context, _expiryDateController, isExpiry: true),
            ),
            const SizedBox(height: 16),

            // Zone upload fichier
            GestureDetector(
              onTap: _simulateFileUpload,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Icon(
                      _uploadedFilePath != null
                          ? Icons.check_circle_outline
                          : Icons.cloud_upload_outlined,
                      size: 36,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _uploadedFilePath != null
                          ? _uploadedFilePath!
                          : 'profile.click_upload'.tr(),
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        fontWeight: FontWeight.w600,
                        fontSize: AppConstants.fontSizeMedium,
                        color: AppColors.primary,
                      ),
                    ),
                    if (_uploadedFilePath == null)
                      Text(
                        'profile.file_format'.tr(),
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontSize: AppConstants.fontSizeRegular,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
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

            // Bouton Enregistrer (brouillon)
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
// CHAMP DATE DANS LA MODAL
// ─────────────────────────────────────────────────────────────────
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