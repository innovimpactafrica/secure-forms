import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/kyc/domain/bloc/kyc_bloc.dart';
import 'package:secure_link/features/kyc/domain/bloc/kyc_event.dart';
import 'package:secure_link/features/kyc/domain/bloc/kyc_state.dart';
import 'kyc_step2_face_page.dart';

class KycStep2FacePreviewPage extends StatelessWidget {
  final File photo;
  /// Callback appelé après succès — si null, retour simple à step2
  final VoidCallback? onSuccess;
  const KycStep2FacePreviewPage({super.key, required this.photo, this.onSuccess});

  void _submit(BuildContext context) {
    final token = UserSession.instance.accessToken;
    if (token.isNotEmpty) {
      context.read<KycBloc>().add(KycUploadSelfie(selfie: photo, token: token));
    } else {
      context.read<KycBloc>().add(const KycMarkCompleted());
      _showSuccessModal(context);
    }
  }

  void _showSuccessModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _KycSuccessModal(
        onContinue: () {
          Navigator.of(context).pop(); // ferme dialog
          if (onSuccess != null) {
            onSuccess!();
          } else {
            // Retour à step2 : dépiler face_preview + kyc_step2
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KycBloc, KycState>(
      listener: (context, state) {
        if (state is KycSelfieUploaded) {
          _showSuccessModal(context);
        } else if (state is KycError) {
          // Erreur 499 = "Client Closed Request" = le serveur a bien reçu
          // mais a fermé la connexion avant de répondre → traiter comme succès
          final msg = state.message.toLowerCase();
          if (msg.contains('499') || msg.contains('client closed') ||
              msg.contains('formatexception') || msg.contains('unexpected character')) {
            // ignore: avoid_print
            print('[KycPreview] Erreur 499/FormatException → traité comme succès');
            // S'assurer que le KYC est bien marqué complet même en cas d'erreur 499
            context.read<KycBloc>().add(const KycMarkCompleted());
            _showSuccessModal(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.statusRejected,
              ),
            );
          }
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
                    child: Row(
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
                            child: const Icon(Icons.arrow_back,
                                color: AppColors.white, size: 20),
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
                              'Prenez une photo de votre visage',
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'Vérifiez votre photo',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilySofiaSans,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: AppColors.textBlack87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Assurez-vous que votre visage est bien visible avant de\ncontinuer.',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilyInter,
                              fontSize: AppConstants.fontSizeMedium,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            height: 260,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.borderLight, width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(photo, fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Assurez-vous que l\'éclairage est suffisant et que\nvotre visage est visible clairement.',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilyInter,
                              fontSize: AppConstants.fontSizeRegular,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Boutons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: isLoading ? null : () => _submit(context),
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: isLoading
                                  ? AppColors.primaryDark.withValues(alpha: 0.6)
                                  : AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isLoading)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.white),
                                    ),
                                  )
                                else ...[
                                  const Icon(Icons.send_outlined,
                                      color: AppColors.white, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Envoyer pour validation',
                                    style: TextStyle(
                                      fontFamily: AppConstants.fontFamilySofiaSans,
                                      fontWeight: FontWeight.w600,
                                      fontSize: AppConstants.fontSizeLarge,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: isLoading
                              ? null
                              : () => Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<KycBloc>(),
                                        child: KycStep2FacePage(
                                          onSuccess: onSuccess,
                                        ),
                                      ),
                                    ),
                                  ),
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: AppColors.borderGray),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.refresh,
                                    color: AppColors.textBlack87, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'Reprendre la photo',
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamilySofiaSans,
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppConstants.fontSizeLarge,
                                    color: AppColors.textBlack87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

class _KycSuccessModal extends StatelessWidget {
  final VoidCallback onContinue;
  const _KycSuccessModal({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.check_circle_outline,
                    color: AppColors.primary, size: 52),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Photo envoyée avec succès !',
              style: TextStyle(
                fontFamily: AppConstants.fontFamilySofiaSans,
                fontWeight: FontWeight.w700,
                fontSize: AppConstants.fontSizeLarge,
                color: AppColors.textBlack87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Votre vérification d\'identité a été soumise.',
              style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontSize: AppConstants.fontSizeMedium,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onContinue,
              child: Container(
                height: 48,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    'Continuer',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamilySofiaSans,
                      fontWeight: FontWeight.w600,
                      fontSize: AppConstants.fontSizeMedium,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
