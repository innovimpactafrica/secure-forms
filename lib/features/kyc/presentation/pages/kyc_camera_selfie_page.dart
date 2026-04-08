import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';

/// Écran caméra plein écran avec ovale de scan selfie en overlay.
/// Retourne un [File] ou null si annulé.
class KycCameraSelfiePage extends StatefulWidget {
  const KycCameraSelfiePage({super.key});

  @override
  State<KycCameraSelfiePage> createState() => _KycCameraSelfiePageState();
}

class _KycCameraSelfiePageState extends State<KycCameraSelfiePage>
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
      // Caméra frontale pour selfie
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final ctrl = CameraController(
        front,
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
    if (_controller == null || !_controller!.value.isInitialized || _isTaking) return;
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

          // ── Overlay sombre avec découpe ovale ──
          if (_isReady)
            CustomPaint(
              painter: _SelfieOverlayPainter(),
            ),

          // ── Titre en haut ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    Text(
                      'Prenez un selfie',
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
                      'Positionnez votre visage dans le cadre',
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
                      'Regardez directement la caméra',
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

/// Overlay sombre avec découpe ovale + coins de cadrage colorés
class _SelfieOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ovalW = size.width * 0.72;
    final ovalH = ovalW * 1.28; // ratio portrait visage
    final cx = size.width / 2;
    final cy = size.height / 2 - 30;

    final ovalRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: ovalW,
      height: ovalH,
    );

    // Fond sombre avec trou ovale
    final darkPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()..addOval(ovalRect);
    final overlayPath = Path.combine(PathOperation.difference, fullPath, holePath);
    canvas.drawPath(overlayPath, darkPaint);

    // Bordure ovale fine blanche
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(ovalRect, borderPaint);

    // Coins de cadrage colorés (aux 4 extrémités de l'ovale)
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cLen = 24.0;
    final rx = ovalW / 2;
    final ry = ovalH / 2;

    // Haut-gauche
    canvas.drawLine(Offset(cx - rx, cy - ry + cLen), Offset(cx - rx, cy - ry), cornerPaint);
    canvas.drawLine(Offset(cx - rx, cy - ry), Offset(cx - rx + cLen, cy - ry), cornerPaint);
    // Haut-droit
    canvas.drawLine(Offset(cx + rx - cLen, cy - ry), Offset(cx + rx, cy - ry), cornerPaint);
    canvas.drawLine(Offset(cx + rx, cy - ry), Offset(cx + rx, cy - ry + cLen), cornerPaint);
    // Bas-gauche
    canvas.drawLine(Offset(cx - rx, cy + ry - cLen), Offset(cx - rx, cy + ry), cornerPaint);
    canvas.drawLine(Offset(cx - rx, cy + ry), Offset(cx - rx + cLen, cy + ry), cornerPaint);
    // Bas-droit
    canvas.drawLine(Offset(cx + rx - cLen, cy + ry), Offset(cx + rx, cy + ry), cornerPaint);
    canvas.drawLine(Offset(cx + rx, cy + ry), Offset(cx + rx, cy + ry - cLen), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
