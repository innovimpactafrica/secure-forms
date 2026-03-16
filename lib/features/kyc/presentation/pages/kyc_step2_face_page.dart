import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/features/kyc/domain/bloc/kyc_bloc.dart';
import 'kyc_step2_face_preview_page.dart';

class KycStep2FacePage extends StatefulWidget {
  const KycStep2FacePage({super.key});

  @override
  State<KycStep2FacePage> createState() => _KycStep2FacePageState();
}

class _KycStep2FacePageState extends State<KycStep2FacePage> {
  File? _capturedPhoto; // ignore: unused_field
  bool _isCapturing = false;
  final _picker = ImagePicker();

  Future<void> _takePhoto() async {
    setState(() => _isCapturing = true);
    await Future.delayed(const Duration(milliseconds: 500));
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    setState(() => _isCapturing = false);
    if (picked != null && mounted) {
      setState(() => _capturedPhoto = File(picked.path));
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<KycBloc>(),
            child: KycStep2FacePreviewPage(photo: File(picked.path)),
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
                      'Prenez une photo de votre visage',
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
                      'Positionnez votre visage dans le cadre',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontSize: AppConstants.fontSizeMedium,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      height: 240,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF6F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(160, 200),
                            painter: _FaceOutlinePainter(),
                          ),
                          Positioned(
                            bottom: 24,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: AppColors.white, size: 26),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isCapturing ? 'Capture en cours...' : 'Photo en cours...',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        fontWeight: FontWeight.w500,
                        fontSize: AppConstants.fontSizeMedium,
                        color: AppColors.textBlack87,
                      ),
                    ),
                    const SizedBox(height: 8),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _takePhoto,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt_outlined, color: AppColors.white, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Prendre la photo',
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
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => setState(() => _capturedPhoto = null),
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
                          const Icon(Icons.refresh, color: AppColors.textBlack87, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Recommencer',
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
  }
}

class _FaceOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.75,
        height: size.height * 0.85,
      ),
      paint,
    );

    final eyePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawArc(
      Rect.fromCenter(center: Offset(size.width * 0.38, size.height * 0.42), width: 18, height: 10),
      0, 3.14, false, eyePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(size.width * 0.62, size.height * 0.42), width: 18, height: 10),
      0, 3.14, false, eyePaint,
    );

    final nosePath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.48)
      ..lineTo(size.width * 0.46, size.height * 0.58)
      ..lineTo(size.width * 0.54, size.height * 0.58);
    canvas.drawPath(nosePath, eyePaint);

    canvas.drawArc(
      Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.65), width: 36, height: 16),
      0, 3.14, false, eyePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
