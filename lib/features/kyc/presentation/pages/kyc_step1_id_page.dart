import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/kyc/domain/bloc/kyc_bloc.dart';
import 'package:secure_link/features/kyc/domain/bloc/kyc_event.dart';
import 'package:secure_link/features/kyc/domain/bloc/kyc_state.dart';
import 'kyc_step2_face_page.dart';

class KycStep1IdPage extends StatefulWidget {
  const KycStep1IdPage({super.key});

  @override
  State<KycStep1IdPage> createState() => _KycStep1IdPageState();
}

class _KycStep1IdPageState extends State<KycStep1IdPage> {
  File? _frontImage;
  File? _backImage;
  final _picker = ImagePicker();

  Future<void> _pickImage(bool isFront, ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(picked.path);
        } else {
          _backImage = File(picked.path);
        }
      });
    }
  }

  int get _uploadedCount => (_frontImage != null ? 1 : 0) + (_backImage != null ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    return BlocListener<KycBloc, KycState>(
      listener: (context, state) {
        if (state is KycIdDocumentsUploaded) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<KycBloc>(),
                child: const KycStep2FacePage(),
              ),
            ),
          );
        } else if (state is KycError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.statusRejected,
            ),
          );
        }
      },
      child: BlocBuilder<KycBloc, KycState>(
        builder: (context, kycState) {
          final isLoading = kycState is KycUploading;
          return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vérification d\'identité',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilySofiaSans,
                              fontWeight: FontWeight.w600,
                              fontSize: AppConstants.fontSizeLarge,
                              color: AppColors.textBlack87,
                            ),
                          ),
                          Text(
                            'Téléversez votre pièce d\'identité',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilyInter,
                              fontSize: AppConstants.fontSizeRegular,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _uploadedCount / 2,
                            backgroundColor: AppColors.progressBar,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$_uploadedCount/2',
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontSize: AppConstants.fontSizeRegular,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instructions
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Instructions',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilySofiaSans,
                              fontWeight: FontWeight.w600,
                              fontSize: AppConstants.fontSizeMedium,
                              color: AppColors.textBlack87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _InstructionItem('Assurez-vous que votre document est bien éclairé'),
                          _InstructionItem('Toutes les informations doivent être lisibles'),
                          _InstructionItem('Évitez les reflets et les ombres'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Face avant
                    Text(
                      'Face avant',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        fontWeight: FontWeight.w600,
                        fontSize: AppConstants.fontSizeMedium,
                        color: AppColors.textBlack87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _PhotoUploadBox(
                      image: _frontImage,
                      onCamera: () => _pickImage(true, ImageSource.camera),
                      onGallery: () => _pickImage(true, ImageSource.gallery),
                    ),
                    const SizedBox(height: 20),

                    // Face arrière
                    Text(
                      'Face arrière',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        fontWeight: FontWeight.w600,
                        fontSize: AppConstants.fontSizeMedium,
                        color: AppColors.textBlack87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _PhotoUploadBox(
                      image: _backImage,
                      onCamera: () => _pickImage(false, ImageSource.camera),
                      onGallery: () => _pickImage(false, ImageSource.gallery),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bouton Continuer
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: GestureDetector(
                onTap: (_uploadedCount == 2 && !isLoading)
                    ? () {
                        final token = UserSession.instance.accessToken;
                        if (token.isNotEmpty) {
                          context.read<KycBloc>().add(KycUploadIdDocuments(
                                recto: _frontImage!,
                                verso: _backImage!,
                                token: token,
                              ));
                        } else {
                          // Sans token (test) → navigation directe
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<KycBloc>(),
                                child: const KycStep2FacePage(),
                              ),
                            ),
                          );
                        }
                      }
                    : null,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: (_uploadedCount == 2 && !isLoading)
                        ? AppColors.primaryDark
                        : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: (_uploadedCount == 2 && !isLoading)
                          ? AppColors.primaryDark
                          : AppColors.borderGray,
                    ),
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryDark),
                            ),
                          )
                        : Text(
                            'Continuer',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilySofiaSans,
                              fontWeight: FontWeight.w600,
                              fontSize: AppConstants.fontSizeLarge,
                              color: (_uploadedCount == 2 && !isLoading)
                                  ? AppColors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                  ),
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
}

class _InstructionItem extends StatelessWidget {
  final String text;
  const _InstructionItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontSize: AppConstants.fontSizeRegular,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoUploadBox extends StatelessWidget {
  final File? image;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _PhotoUploadBox({required this.image, required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: image != null ? AppColors.primary : AppColors.borderGray,
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.file(image!, height: 160, fit: BoxFit.cover),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  Icon(Icons.camera_alt_outlined, size: 36, color: AppColors.textSecondary),
                  const SizedBox(height: 8),
                  Text(
                    'Prendre une photo',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamilySofiaSans,
                      fontWeight: FontWeight.w500,
                      fontSize: AppConstants.fontSizeMedium,
                      color: AppColors.textBlack87,
                    ),
                  ),
                  Text(
                    'ou sélectionnez depuis votre galerie',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamilyInter,
                      fontSize: AppConstants.fontSizeRegular,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: onCamera,
                        child: Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 26),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: onGallery,
                        child: Icon(Icons.upload_outlined, color: AppColors.primary, size: 26),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
