import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:camera/camera.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/features/client/domain/bloc/profile_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/profile_event.dart';
import 'package:secure_link/features/client/domain/bloc/profile_state.dart';


/// Écran de vérification d'identité par Face ID
/// Affiché après l'upload d'un document qui nécessite une vérification faciale
/// TODO: connecter au vrai SDK de reconnaissance faciale (ex: AWS Rekognition,
/// Azure Face API, ou local_auth) quand l'API sera disponible
class FaceVerificationScreen extends StatefulWidget {
  final String documentType;

  const FaceVerificationScreen({super.key, required this.documentType});

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  bool _isScanning = false;
  bool _scanComplete = false;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
        _startScan();
      }
    } catch (e) {
      debugPrint('Erreur initialisation caméra: $e');
      if (mounted) _startScan();
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  void _startScan() {
    setState(() => _isScanning = true);
    // TODO: API — démarrer la vraie capture caméra + envoi au serveur
    // Pour l'instant : simulation de 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _scanComplete = true;
        });
        // Simuler un succès (TODO: remplacer par le résultat réel de l'API)
        _onVerificationSuccess();
      }
    });
  }

  void _onVerificationSuccess() {
    context.read<ProfileBloc>().add(
          FaceVerificationSuccessEvent(documentType: widget.documentType),
        );
    // Afficher un feedback visuel puis naviguer
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(
        onContinue: () {
          Navigator.of(context).pop(); // ferme dialog
          Navigator.of(context).pop(); // retour à step2
        },
      ),
    );
  }

  void _onRecommencer() {
    setState(() {
      _isScanning = false;
      _scanComplete = false;
    });
    _scanController.reset();
    _startScan();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileFaceVerificationFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'face_verification.verification_failed'.tr() + ' : ${state.reason}. ' + 'face_verification.please_retry'.tr()),
              backgroundColor: AppColors.statusRejected,
            ),
          );
        }
      },
      child: Scaffold(
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
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'face_verification.title'.tr(),
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        fontWeight: FontWeight.w700,
                        fontSize: AppConstants.fontSizeXXLarge,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              // Contenu principal
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Titre
                      Text(
                        'face_verification.video_title'.tr(),
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilySofiaSans,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'face_verification.position_face'.tr(),
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontSize: AppConstants.fontSizeMedium,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // Cadre de scan avec caméra
                      _FaceFrame(
                        isScanning: _isScanning,
                        cameraController: _cameraController,
                        isCameraInitialized: _isCameraInitialized,
                      ),
                      const SizedBox(height: 32),

                      // "Analyse de votre visage..."
                      Text(
                        _scanComplete
                            ? 'face_verification.analysis_complete'.tr()
                            : 'face_verification.analyzing'.tr(),
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontSize: AppConstants.fontSizeLarge,
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Indicateur de scan circulaire
                      _ScanIndicator(
                        controller: _scanController,
                        isComplete: _scanComplete,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _scanComplete ? 'face_verification.completed'.tr() : 'face_verification.scan_in_progress'.tr(),
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontSize: AppConstants.fontSizeMedium,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bouton "Recommencer"
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: AppConstants.logoutButtonHeight,
                  child: OutlinedButton.icon(
                    onPressed: _isScanning ? null : _onRecommencer,
                    icon: Icon(
                      Icons.play_circle_filled,
                      color: AppColors.statusRejected,
                      size: AppConstants.iconSizeMedium,
                    ),
                    label: Text(
                      'face_verification.restart'.tr(),
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                        fontSize: AppConstants.fontSizeLarge,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusRound),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CADRE DE SCAN DU VISAGE
// ─────────────────────────────────────────────────────────────────
class _FaceFrame extends StatelessWidget {
  final bool isScanning;
  final CameraController? cameraController;
  final bool isCameraInitialized;

  const _FaceFrame({
    required this.isScanning,
    required this.cameraController,
    required this.isCameraInitialized,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Flux caméra en arrière-plan
            if (isCameraInitialized && cameraController != null)
              Positioned.fill(
                child: CameraPreview(cameraController!),
              )
            else
              // Fallback si caméra non disponible
              Container(
                color: AppColors.greyShade200,
                child: Center(
                  child: Icon(
                    Icons.person_outline,
                    size: 140,
                    color: AppColors.white,
                  ),
                ),
              ),
            // 4 coins du cadre par-dessus
            Positioned(top: 0, left: 0, child: _Corner()),
            Positioned(
                top: 0,
                right: 0,
                child: Transform.rotate(angle: 1.5708, child: _Corner())),
            Positioned(
                bottom: 0,
                left: 0,
                child: Transform.rotate(angle: -1.5708, child: _Corner())),
            Positioned(
                bottom: 0,
                right: 0,
                child: Transform.rotate(angle: 3.1416, child: _Corner())),
          ],
        ),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(painter: _CornerPainter(color: AppColors.primary)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;

  _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────
// INDICATEUR CIRCULAIRE DE SCAN
// ─────────────────────────────────────────────────────────────────
class _ScanIndicator extends StatelessWidget {
  final AnimationController controller;
  final bool isComplete;

  const _ScanIndicator({
    required this.controller,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (isComplete) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.statusValideGreen.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_circle,
          color: AppColors.statusValideGreen,
          size: 36,
        ),
      );
    }

    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: controller,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(AppColors.borderLight),
            ),
          ),
          Icon(
            Icons.face_outlined,
            color: AppColors.primary,
            size: 24,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// DIALOG SUCCÈS
// ─────────────────────────────────────────────────────────────────
class _SuccessDialog extends StatelessWidget {
  final VoidCallback onContinue;

  const _SuccessDialog({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user,
              color: AppColors.statusValideGreen, size: 56),
          const SizedBox(height: 16),
          Text(
            'face_verification.document_verified'.tr(),
            style: TextStyle(
              fontFamily: AppConstants.fontFamilySofiaSans,
              fontWeight: FontWeight.w700,
              fontSize: AppConstants.fontSizeXXLarge,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'face_verification.identity_confirmed'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppConstants.fontFamilyInter,
              fontSize: AppConstants.fontSizeMedium,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusRound),
                ),
              ),
              child: Text(
                'face_verification.continue'.tr(),
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}