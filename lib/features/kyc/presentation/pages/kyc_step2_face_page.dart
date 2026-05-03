import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';
import 'package:quick_forms/features/kyc/domain/bloc/kyc_bloc.dart';
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
    context.locale;
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
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'kyc.title'.tr(),
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilySofiaSans,
                          fontWeight: FontWeight.w600,
                          fontSize: AppConstants.fontSizeLarge,
                          color: AppColors.textBlack87,
                        ),
                      ),
                      Text(
                        'kyc.selfie_title'.tr(),
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
                      'kyc.selfie_title'.tr(),
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
                      'kyc.selfie_subtitle'.tr(),
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontSize: AppConstants.fontSizeMedium,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: _isCapturing ? null : _takePhoto,
                      child: Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1.5),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(double.infinity, 300),
                              painter: _FaceOvalPainter(),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: const Alignment(0, -0.12),
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryDark,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: AppColors.white,
                                    size: 140,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.camera_front,
                                          color: AppColors.white, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        _isCapturing
                                            ? 'kyc.capturing'.tr()
                                            : 'kyc.tap_selfie'.tr(),
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
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TipItem('kyc.tip1'.tr()),
                          _TipItem('kyc.tip2'.tr()),
                          _TipItem('kyc.tip3'.tr()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                      const Icon(Icons.camera_front_outlined,
                          color: AppColors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        _isCapturing
                            ? 'kyc.capturing_selfie'.tr()
                            : 'kyc.taking_selfie'.tr(),
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

class _FaceOvalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const cornerLen = 18.0;
    final cx = size.width / 2;
    final cy = size.height / 2 - 16;
    final rx = size.width * 0.22;
    final ry = size.height * 0.26;

    canvas.drawLine(Offset(cx - rx, cy - ry + cornerLen),
        Offset(cx - rx, cy - ry), cornerPaint);
    canvas.drawLine(Offset(cx - rx, cy - ry),
        Offset(cx - rx + cornerLen, cy - ry), cornerPaint);
    canvas.drawLine(Offset(cx + rx - cornerLen, cy - ry),
        Offset(cx + rx, cy - ry), cornerPaint);
    canvas.drawLine(Offset(cx + rx, cy - ry),
        Offset(cx + rx, cy - ry + cornerLen), cornerPaint);
    canvas.drawLine(Offset(cx - rx, cy + ry - cornerLen),
        Offset(cx - rx, cy + ry), cornerPaint);
    canvas.drawLine(Offset(cx - rx, cy + ry),
        Offset(cx - rx + cornerLen, cy + ry), cornerPaint);
    canvas.drawLine(Offset(cx + rx - cornerLen, cy + ry),
        Offset(cx + rx, cy + ry), cornerPaint);
    canvas.drawLine(Offset(cx + rx, cy + ry),
        Offset(cx + rx, cy + ry - cornerLen), cornerPaint);
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
          Text('• ',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
