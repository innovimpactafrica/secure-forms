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
import 'kyc_camera_document_page.dart';
import 'kyc_doc_type_page.dart';
import 'kyc_step2_face_page.dart';

class KycStep1IdPage extends StatefulWidget {
  final KycDocType docType;
  const KycStep1IdPage({super.key, required this.docType});

  @override
  State<KycStep1IdPage> createState() => _KycStep1IdPageState();
}

class _KycStep1IdPageState extends State<KycStep1IdPage> {
  File? _frontImage;
  File? _backImage;

  String get _docLabel => widget.docType == KycDocType.cni
      ? 'Carte Nationale d\'identité'
      : 'Passeport';

  Future<void> _captureImage(bool isFront) async {
    final label = isFront
        ? 'RECTO de votre $_docLabel'
        : 'VERSO de votre $_docLabel';
    final File? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => KycCameraDocumentPage(title: label),
        fullscreenDialog: true,
      ),
    );
    if (result != null) {
      setState(() {
        if (isFront) {
          _frontImage = result;
        } else {
          _backImage = result;
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
                                  _docLabel,
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
                                _InstructionItem('Placez votre document dans le cadre'),
                                _InstructionItem('Assurez-vous que le document est bien éclairé'),
                                _InstructionItem('Toutes les informations doivent être lisibles'),
                                _InstructionItem('Évitez les reflets et les ombres'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Face avant
                          Text(
                            'Face avant (Recto)',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilySofiaSans,
                              fontWeight: FontWeight.w600,
                              fontSize: AppConstants.fontSizeMedium,
                              color: AppColors.textBlack87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _CaptureBox(
                            image: _frontImage,
                            label: 'Prenez une photo RECTO de votre $_docLabel',
                            onCapture: () => _captureImage(true),
                            onRetake: () => setState(() => _frontImage = null),
                          ),
                          const SizedBox(height: 24),

                          // Face arrière
                          Text(
                            'Face arrière (Verso)',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilySofiaSans,
                              fontWeight: FontWeight.w600,
                              fontSize: AppConstants.fontSizeMedium,
                              color: AppColors.textBlack87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _CaptureBox(
                            image: _backImage,
                            label: 'Prenez une photo VERSO de votre $_docLabel',
                            onCapture: () => _captureImage(false),
                            onRetake: () => setState(() => _backImage = null),
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
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
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

// ─────────────────────────────────────────────────────────────────
// Cadre de capture avec guide visuel
// ─────────────────────────────────────────────────────────────────
class _CaptureBox extends StatelessWidget {
  final File? image;
  final String label;
  final VoidCallback onCapture;
  final VoidCallback onRetake;

  const _CaptureBox({
    required this.image,
    required this.label,
    required this.onCapture,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      // Photo prise — afficher avec bouton reprendre
      return Column(
        children: [
          Container(
            width: double.infinity,
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(image!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onRetake,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, color: AppColors.primary, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Reprendre la photo',
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Cadre guide + bouton capture
    return GestureDetector(
      onTap: onCapture,
      child: Container(
        width: double.infinity,
        height: 210,
        decoration: BoxDecoration(
          color: AppColors.primaryDark.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, color: AppColors.white, size: 40),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppConstants.fontFamilySofiaSans,
                fontWeight: FontWeight.w600,
                fontSize: AppConstants.fontSizeRegular,
                color: AppColors.textBlack87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Appuyez pour prendre la photo',
              style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontSize: AppConstants.fontSizeSmall,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
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
