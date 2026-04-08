import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/features/kyc/domain/bloc/kyc_bloc.dart';
import 'kyc_camera_selfie_page.dart';
import 'kyc_step2_face_preview_page.dart';

class KycStep2FacePage extends StatefulWidget {
  final VoidCallback? onSuccess;
  const KycStep2FacePage({super.key, this.onSuccess});

  @override
  State<KycStep2FacePage> createState() => _KycStep2FacePageState();
}

class _KycStep2FacePageState extends State<KycStep2FacePage> {
  bool _isCapturing = false;

  Future<void> _takePhoto() async {
    setState(() => _isCapturing = true);
    final File? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const KycCameraSelfiePage(),
        fullscreenDialog: true,
      ),
    );
    setState(() => _isCapturing = false);
    if (result != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<KycBloc>(),
            child: KycStep2FacePreviewPage(
              photo: result,
              onSuccess: widget.onSuccess,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        'Prenez un selfie',
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
                    const SizedBox(height: 8),
                    Text(
                      'Prenez un selfie',
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
                      'Positionnez votre visage dans le cadre ovale',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontSize: AppConstants.fontSizeMedium,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Cadre selfie avec ovale dessiné
                    GestureDetector(
                      onTap: _isCapturing ? null : _takePhoto,
                      child: Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ovale guide visage
                            CustomPaint(
                              size: const Size(double.infinity, 300),
                              painter: _FaceOvalPainter(),
                            ),
                            // Icône personne centrée dans l'ovale
                            Positioned(
                              top: 30,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  width: 110,
                                  height: 110,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryDark,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: AppColors.white,
                                    size: 72,
                                  ),
                                ),
                              ),
                            ),
                            // Badge caméra en bas du cadre
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.camera_front, color: AppColors.white, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        _isCapturing ? 'Capture...' : 'Appuyez pour prendre le selfie',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
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
                    ),

                    const SizedBox(height: 20),
                    // Conseils
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TipItem('Regardez directement la caméra frontale'),
                          _TipItem('Assurez-vous que l\'éclairage est suffisant'),
                          _TipItem('Votre visage doit être entièrement visible'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bouton Prendre la photo
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: GestureDetector(
                onTap: _isCapturing ? null : _takePhoto,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: _isCapturing
                        ? AppColors.primaryDark.withValues(alpha: 0.6)
                        : AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_front_outlined, color: AppColors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        _isCapturing ? 'Capture en cours...' : 'Prendre le selfie',
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilySofiaSans,
                          fontWeight: FontWeight.w600,
                          fontSize: AppConstants.fontSizeLarge,
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
    );
  }
}

/// Dessine un ovale guide pour le visage avec coins de cadrage
class _FaceOvalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Ovale principal
    final ovalPaint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 16),
      width: size.width * 0.52,
      height: size.height * 0.62,
    );
    canvas.drawOval(ovalRect, ovalPaint);

    // Coins de cadrage autour de l'ovale
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const cornerLen = 18.0;
    final cx = size.width / 2;
    final cy = size.height / 2 - 16;
    final rx = size.width * 0.26;
    final ry = size.height * 0.31;

    // Haut-gauche
    canvas.drawLine(Offset(cx - rx, cy - ry + cornerLen), Offset(cx - rx, cy - ry), cornerPaint);
    canvas.drawLine(Offset(cx - rx, cy - ry), Offset(cx - rx + cornerLen, cy - ry), cornerPaint);
    // Haut-droit
    canvas.drawLine(Offset(cx + rx - cornerLen, cy - ry), Offset(cx + rx, cy - ry), cornerPaint);
    canvas.drawLine(Offset(cx + rx, cy - ry), Offset(cx + rx, cy - ry + cornerLen), cornerPaint);
    // Bas-gauche
    canvas.drawLine(Offset(cx - rx, cy + ry - cornerLen), Offset(cx - rx, cy + ry), cornerPaint);
    canvas.drawLine(Offset(cx - rx, cy + ry), Offset(cx - rx + cornerLen, cy + ry), cornerPaint);
    // Bas-droit
    canvas.drawLine(Offset(cx + rx - cornerLen, cy + ry), Offset(cx + rx, cy + ry), cornerPaint);
    canvas.drawLine(Offset(cx + rx, cy + ry), Offset(cx + rx, cy + ry - cornerLen), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TipItem extends StatelessWidget {
  final String text;
  const _TipItem(this.text);

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
