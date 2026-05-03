import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';
import 'package:quick_forms/features/client/data/models/profile_model.dart';
import 'package:quick_forms/features/client/domain/bloc/profile_bloc.dart';
import 'package:quick_forms/features/client/domain/bloc/profile_event.dart';
import 'package:quick_forms/features/client/domain/bloc/profile_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'document_upload_modal.dart' show showPickerSource;

/// Modal d'ajout de document SANS vérification d'identité
/// Design : docsvi.png
/// Type de document (lecture seule) + zone upload + bouton Enregistrer
class DocumentSimpleUploadModal extends StatefulWidget {
  final DocumentTypeModel documentType;
  final UploadedDocumentModel? existingDocument;

  const DocumentSimpleUploadModal({
    super.key,
    required this.documentType,
    this.existingDocument,
  });

  @override
  State<DocumentSimpleUploadModal> createState() =>
      _DocumentSimpleUploadModalState();
}

class _DocumentSimpleUploadModalState extends State<DocumentSimpleUploadModal> {
  File? _selectedFile;
  File? _backFile;
  bool _isImage = false;
  bool _showBack = false; // verso masqué par défaut
  late final ProfileBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ProfileBloc>();
  }

  Future<void> _pickFile({bool isBack = false}) async {
    final choice = await showPickerSource(context);
    if (choice == null || !mounted) return;

    String? path;
    if (choice == 'gallery') {
      final x = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 85);
      path = x?.path;
    } else if (choice == 'camera') {
      final x = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 85);
      path = x?.path;
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      path = result?.files.single.path;
    }

    if (path == null || !mounted) return;
    final file = File(path);
    final ext = path.split('.').last.toLowerCase();
    if (isBack) {
      setState(() => _backFile = file);
    } else {
      setState(() {
        _selectedFile = file;
        _isImage = ext != 'pdf';
      });
    }
  }

  void _onEnregistrer() {
    if (_selectedFile == null) {
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    _bloc.add(
      UploadProfileDocumentEvent(
        file: _selectedFile!,
        backFile: _backFile,
        documentTypeId: widget.documentType.id,
      ),
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: Padding(
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
              const SizedBox(height: 24),

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
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              const SizedBox(height: 20),

              // Zone upload principale
              GestureDetector(
                onTap: () => _pickFile(),
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.docUploadBg,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusSmall),
                    border:
                        Border.all(color: AppColors.docUploadBorder, width: 1),
                  ),
                  child: _selectedFile != null && _isImage
                      ? ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusSmall),
                          child: Image.file(_selectedFile!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) =>
                                  const _UploadPlaceholder(hasFile: true)))
                      : _UploadPlaceholder(hasFile: _selectedFile != null),
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
                      Icon(Icons.add_circle_outline,
                          size: 16, color: AppColors.primary),
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
                      onTap: () => setState(() {
                        _showBack = false;
                        _backFile = null;
                      }),
                      child: Icon(Icons.close,
                          size: 16, color: AppColors.textSecondary),
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
                      color: AppColors.docUploadBg,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSmall),
                      border: Border.all(
                          color: AppColors.docUploadBorder, width: 1),
                    ),
                    child: _backFile != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusSmall),
                            child: Image.file(_backFile!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) =>
                                    const _UploadPlaceholder(hasFile: true)))
                        : const _UploadPlaceholder(hasFile: false),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Bouton Enregistrer (seul bouton — design docsvi.png)
              SizedBox(
                width: double.infinity,
                height: AppConstants.logoutButtonHeight,
                child: ElevatedButton(
                  onPressed: _onEnregistrer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusRound),
                    ),
                  ),
                  child: Text(
                    'profile.save'.tr(),
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamilySofiaSans,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: AppConstants.fontSizeLarge,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
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
              colorFilter:
                  const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
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
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'profile.file_format'.tr(),
              style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontSize: AppConstants.fontSizeRegular,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
