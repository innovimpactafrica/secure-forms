import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';

/// Écran de scan de document avec cadre guide (style iOS/Android natif)
/// Retourne le chemin du fichier recadré ou null si annulé
class DocumentScannerPage extends StatefulWidget {
  const DocumentScannerPage({super.key});

  @override
  State<DocumentScannerPage> createState() => _DocumentScannerPageState();
}

class _DocumentScannerPageState extends State<DocumentScannerPage> {
  CameraController? _controller;
  bool _isCapturing = false;
  bool _cameraReady = false;

  // Ratio carte d'identité standard : 85.6mm x 54mm = 1.586
  static const double _cardRatio = 85.6 / 54.0;
  // Largeur du cadre = 88% de l'écran
  static const double _frameWidthRatio = 0.88;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    // Caméra arrière
    final back = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _controller = CameraController(
      back,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
    if (mounted) setState(() => _cameraReady = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      final xFile = await _controller!.takePicture();
      final croppedPath = await _cropToFrame(xFile.path);
      if (mounted) Navigator.of(context).pop(croppedPath);
    } catch (e) {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  /// Recadre l'image pour ne garder que la zone du cadre
  Future<String> _cropToFrame(String imagePath) async {
    final screenSize = MediaQuery.of(context).size;
    final frameWidth = screenSize.width * _frameWidthRatio;
    final frameHeight = frameWidth / _cardRatio;
    final frameTop = (screenSize.height - frameHeight) / 2;
    final frameLeft = (screenSize.width - frameWidth) / 2;

    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return imagePath;

    // Calculer les ratios entre l'image réelle et l'écran
    final scaleX = original.width / screenSize.width;
    final scaleY = original.height / screenSize.height;

    final cropX = (frameLeft * scaleX).round().clamp(0, original.width);
    final cropY = (frameTop * scaleY).round().clamp(0, original.height);
    final cropW =
        (frameWidth * scaleX).round().clamp(1, original.width - cropX);
    final cropH =
        (frameHeight * scaleY).round().clamp(1, original.height - cropY);

    final cropped = img.copyCrop(
      original,
      x: cropX,
      y: cropY,
      width: cropW,
      height: cropH,
    );

    final dir = await getTemporaryDirectory();
    final outPath =
        '${dir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(outPath).writeAsBytes(img.encodeJpg(cropped, quality: 95));
    return outPath;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final frameWidth = screenSize.width * _frameWidthRatio;
    final frameHeight = frameWidth / _cardRatio;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Preview caméra
          if (_cameraReady && _controller != null)
            Positioned.fill(
              child: CameraPreview(_controller!),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),

          // Overlay sombre avec découpe du cadre
          if (_cameraReady)
            Positioned.fill(
              child: CustomPaint(
                painter: _ScanOverlayPainter(
                  frameWidth: frameWidth,
                  frameHeight: frameHeight,
                ),
              ),
            ),

          // Coins du cadre (style scanner)
          if (_cameraReady)
            Center(
              child: SizedBox(
                width: frameWidth,
                height: frameHeight,
                child: CustomPaint(
                  painter: _FrameCornersPainter(),
                ),
              ),
            ),

          // Instructions
          if (_cameraReady)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Bouton retour
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Placez votre document dans le cadre',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamilySofiaSans,
                      color: Colors.white,
                      fontSize: AppConstants.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Assurez-vous que toutes les informations sont lisibles',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamilyInter,
                      color: Colors.white70,
                      fontSize: AppConstants.fontSizeRegular,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          // Bouton capture
          if (_cameraReady)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _isCapturing ? null : _capture,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white30, width: 4),
                    ),
                    child: _isCapturing
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryDark,
                            ),
                          )
                        : const Icon(Icons.camera_alt,
                            color: AppColors.primaryDark, size: 32),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Overlay sombre avec trou transparent pour le cadre
class _ScanOverlayPainter extends CustomPainter {
  final double frameWidth;
  final double frameHeight;

  const _ScanOverlayPainter(
      {required this.frameWidth, required this.frameHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.55);
    final frameLeft = (size.width - frameWidth) / 2;
    final frameTop = (size.height - frameHeight) / 2;
    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(frameLeft, frameTop, frameWidth, frameHeight),
      const Radius.circular(12),
    );
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(frameRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Coins du cadre style scanner
class _FrameCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 24.0;
    const r = 12.0;

    // Coin haut-gauche
    canvas.drawLine(Offset(r, 0), Offset(cornerLen, 0), paint);
    canvas.drawLine(Offset(0, r), Offset(0, cornerLen), paint);
    canvas.drawArc(
        const Rect.fromLTWH(0, 0, r * 2, r * 2), 3.14, -1.57, false, paint);

    // Coin haut-droit
    canvas.drawLine(
        Offset(size.width - cornerLen, 0), Offset(size.width - r, 0), paint);
    canvas.drawLine(
        Offset(size.width, r), Offset(size.width, cornerLen), paint);
    canvas.drawArc(Rect.fromLTWH(size.width - r * 2, 0, r * 2, r * 2), 0, -1.57,
        false, paint);

    // Coin bas-gauche
    canvas.drawLine(
        Offset(0, size.height - cornerLen), Offset(0, size.height - r), paint);
    canvas.drawLine(
        Offset(r, size.height), Offset(cornerLen, size.height), paint);
    canvas.drawArc(Rect.fromLTWH(0, size.height - r * 2, r * 2, r * 2), 3.14,
        1.57, false, paint);

    // Coin bas-droit
    canvas.drawLine(Offset(size.width, size.height - cornerLen),
        Offset(size.width, size.height - r), paint);
    canvas.drawLine(Offset(size.width - cornerLen, size.height),
        Offset(size.width - r, size.height), paint);
    canvas.drawArc(
        Rect.fromLTWH(size.width - r * 2, size.height - r * 2, r * 2, r * 2),
        0,
        1.57,
        false,
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
