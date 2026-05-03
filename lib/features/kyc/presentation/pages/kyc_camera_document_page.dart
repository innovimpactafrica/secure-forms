import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';

/// Écran caméra plein écran avec cadre de scan document en overlay.
/// Retourne un [File] ou null si annulé.
class KycCameraDocumentPage extends StatefulWidget {
  final String title; // ex: "RECTO de votre CNI"
  const KycCameraDocumentPage({super.key, required this.title});

  @override
  State<KycCameraDocumentPage> createState() => _KycCameraDocumentPageState();
}

class _KycCameraDocumentPageState extends State<KycCameraDocumentPage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isReady = false;
  bool _isTaking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'Aucune caméra disponible');
        return;
      }
      // Caméra arrière pour document
      final rear = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final ctrl = CameraController(
        rear,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await ctrl.initialize();
      if (!mounted) return;
      setState(() {
        _controller = ctrl;
        _isReady = true;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isTaking)
      return;
    setState(() => _isTaking = true);
    try {
      final xfile = await _controller!.takePicture();
      if (mounted) Navigator.of(context).pop(File(xfile.path));
    } catch (e) {
      setState(() => _isTaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Live feed ──
          if (_isReady && _controller != null)
            CameraPreview(_controller!)
          else if (_error != null)
            Center(
              child: Text(_error!,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),

          // ── Overlay sombre autour du cadre ──
          if (_isReady)
            CustomPaint(
              painter: _DocumentOverlayPainter(),
            ),

          // ── Titre en haut ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    Text(
                      'Prenez une photo',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontSize: AppConstants.fontSizeMedium,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bouton fermer ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(null),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 22),
              ),
            ),
          ),

          // ── Bouton capture en bas ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  children: [
                    Text(
                      'Placez le document dans le cadre',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontSize: AppConstants.fontSizeRegular,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _isTaking ? null : _capture,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          color: _isTaking ? Colors.white38 : Colors.white24,
                        ),
                        child: Center(
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: _isTaking
                                ? const Padding(
                                    padding: EdgeInsets.all(14),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryDark,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Overlay sombre avec découpe rectangulaire + coins de scan colorés
class _DocumentOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Dimensions du cadre document (format carte ID paysage)
    final frameW = size.width * 0.82;
    final frameH = frameW * 0.63; // ratio carte ID
    final frameL = (size.width - frameW) / 2;
    final frameT = (size.height - frameH) / 2 - 20;
    final frameR = frameL + frameW;
    final frameB = frameT + frameH;
    const r = 14.0; // rayon coins

    final frameRect = RRect.fromLTRBR(
        frameL, frameT, frameR, frameB, const Radius.circular(r));

    // Fond sombre avec trou
    final darkPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()..addRRect(frameRect);
    final overlayPath =
        Path.combine(PathOperation.difference, fullPath, holePath);
    canvas.drawPath(overlayPath, darkPaint);

    // Bordure du cadre
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(frameRect, borderPaint);

    // Coins de scan colorés
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cLen = 28.0;

    // Haut-gauche
    canvas.drawLine(Offset(frameL + r, frameT),
        Offset(frameL + r + cLen, frameT), cornerPaint);
    canvas.drawLine(Offset(frameL, frameT + r),
        Offset(frameL, frameT + r + cLen), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(frameL, frameT, r * 2, r * 2), 3.14159,
        -1.5708, false, cornerPaint);

    // Haut-droit
    canvas.drawLine(Offset(frameR - r - cLen, frameT),
        Offset(frameR - r, frameT), cornerPaint);
    canvas.drawLine(Offset(frameR, frameT + r),
        Offset(frameR, frameT + r + cLen), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(frameR - r * 2, frameT, r * 2, r * 2), 4.71239,
        -1.5708, false, cornerPaint);

    // Bas-gauche
    canvas.drawLine(Offset(frameL, frameB - r - cLen),
        Offset(frameL, frameB - r), cornerPaint);
    canvas.drawLine(Offset(frameL + r, frameB),
        Offset(frameL + r + cLen, frameB), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(frameL, frameB - r * 2, r * 2, r * 2), 1.5708,
        -1.5708, false, cornerPaint);

    // Bas-droit
    canvas.drawLine(Offset(frameR, frameB - r - cLen),
        Offset(frameR, frameB - r), cornerPaint);
    canvas.drawLine(Offset(frameR - r - cLen, frameB),
        Offset(frameR - r, frameB), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(frameR - r * 2, frameB - r * 2, r * 2, r * 2),
        0, -1.5708, false, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
