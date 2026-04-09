import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';

class SignatureScreen extends StatefulWidget {
  final String requestId;
  final String? wsUrl;
  final String? sessionId;

  const SignatureScreen({
    super.key,
    required this.requestId,
    this.wsUrl,
    this.sessionId,
  });

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen>
    with SingleTickerProviderStateMixin {
  final List<List<Offset>> _strokes = [];
  List<Offset> _current = [];
  WebSocketChannel? _channel;
  bool _wsConnected = false;
  bool _isSending = false;
  bool _signatureDone = false;
  final GlobalKey _canvasKey = GlobalKey();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _connectWebSocket();
  }

  void _connectWebSocket() {
    final url = widget.wsUrl ?? 'wss://secure.innovimpactdev.cloud/ws/signature';
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      // Envoyer un message d'identification
      _channel!.sink.add(jsonEncode({
        'type': 'join',
        'sessionId': widget.sessionId ?? widget.requestId,
        'role': 'signer',
      }));
      setState(() => _wsConnected = true);
    } catch (_) {
      setState(() => _wsConnected = false);
    }
  }

  void _sendPoint(Offset point, String type) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode({
      'type': type,
      'x': point.dx,
      'y': point.dy,
      'sessionId': widget.sessionId ?? widget.requestId,
    }));
  }

  void _clearSignature() {
    setState(() {
      _strokes.clear();
      _current = [];
      _signatureDone = false;
    });
    _channel?.sink.add(jsonEncode({
      'type': 'clear',
      'sessionId': widget.sessionId ?? widget.requestId,
    }));
  }

  Future<void> _confirmSignature() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('signature.empty_signature'.tr()),
          backgroundColor: AppColors.statusRejected,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall)),
        ),
      );
      return;
    }
    setState(() => _isSending = true);

    // Capturer l'image du canvas
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        final base64Img =
            base64Encode(byteData!.buffer.asUint8List());

        _channel?.sink.add(jsonEncode({
          'type': 'signature_done',
          'sessionId': widget.sessionId ?? widget.requestId,
          'requestId': widget.requestId,
          'imageBase64': base64Img,
        }));
      }
    } catch (_) {}

    setState(() {
      _isSending = false;
      _signatureDone = true;
    });
    _showSuccessSheet();
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => _SuccessSheet(
        onDone: () {
          Navigator.of(context).pop(); // ferme le sheet
          Navigator.of(context).pop(); // retour
        },
      ),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildInfoBanner(),
            Expanded(child: _buildCanvas()),
            _buildToolbar(),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
        vertical: 12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showExitConfirm(),
            child: Container(
              width: AppConstants.avatarSizeSmall,
              height: AppConstants.avatarSizeSmall,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back,
                  color: AppColors.textDark,
                  size: AppConstants.iconSizeMedium),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'signature.title'.tr(),
                  style: const TextStyle(
                    fontFamily: AppConstants.fontFamilySofiaSans,
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${'signature.request_id'.tr()} ${widget.requestId}',
                  style: const TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    fontSize: AppConstants.fontSizeRegular,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Indicateur WebSocket
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Opacity(
              opacity: _wsConnected ? _pulseAnim.value : 1.0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _wsConnected
                      ? AppColors.statusValideGreen.withValues(alpha: 0.12)
                      : AppColors.statusRejected.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusRound),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _wsConnected
                            ? AppColors.statusValideGreen
                            : AppColors.statusRejected,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _wsConnected ? 'Live' : 'Off',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontSize: AppConstants.fontSizeRegular,
                        fontWeight: FontWeight.w600,
                        color: _wsConnected
                            ? AppColors.statusValideGreen
                            : AppColors.statusRejected,
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

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppConstants.paddingLarge, 12, AppConstants.paddingLarge, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              color: AppColors.primary, size: AppConstants.iconSizeMedium),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'signature.info_banner'.tr(),
              style: const TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontSize: AppConstants.fontSizeRegular,
                color: AppColors.primary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: _strokes.isEmpty
              ? AppColors.borderLight
              : AppColors.primary.withValues(alpha: 0.4),
          width: _strokes.isEmpty ? 1.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Stack(
          children: [
            // Watermark guide
            if (_strokes.isEmpty)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.draw_outlined,
                        size: 48,
                        color: AppColors.borderLight),
                    const SizedBox(height: 8),
                    Text(
                      'signature.draw_hint'.tr(),
                      style: const TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontSize: AppConstants.fontSizeMedium,
                        color: AppColors.borderLight,
                      ),
                    ),
                  ],
                ),
              ),
            // Ligne de base signature
            Positioned(
              bottom: 60,
              left: 32,
              right: 32,
              child: Container(
                height: 1,
                color: AppColors.borderLight,
              ),
            ),
            Positioned(
              bottom: 44,
              left: 32,
              child: Text(
                'signature.sign_here'.tr(),
                style: const TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontSize: AppConstants.fontSizeRegular,
                  color: AppColors.borderLight,
                ),
              ),
            ),
            // Zone de dessin
            RepaintBoundary(
              key: _canvasKey,
              child: GestureDetector(
                onPanStart: (d) {
                  setState(() {
                    _current = [d.localPosition];
                    _strokes.add(_current);
                  });
                  _sendPoint(d.localPosition, 'start');
                },
                onPanUpdate: (d) {
                  setState(() => _current.add(d.localPosition));
                  _sendPoint(d.localPosition, 'draw');
                },
                onPanEnd: (_) {
                  if (_current.isNotEmpty) {
                    _sendPoint(_current.last, 'end');
                  }
                },
                child: CustomPaint(
                  painter: _SignaturePainter(_strokes),
                  child: Container(
                    color: Colors.transparent,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge),
      child: Row(
        children: [
          // Bouton effacer
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _strokes.isEmpty ? null : _clearSignature,
              icon: const Icon(Icons.refresh_rounded,
                  size: AppConstants.iconSizeMedium),
              label: Text('signature.clear'.tr()),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                disabledForegroundColor:
                    AppColors.textSecondary.withValues(alpha: 0.3),
                side: BorderSide(
                  color: _strokes.isEmpty
                      ? AppColors.borderLight
                      : AppColors.borderGray,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusSmall),
                ),
                textStyle: const TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Indicateur traits
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusSmall),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.gesture,
                    size: AppConstants.iconSizeMedium,
                    color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  '${_strokes.length}',
                  style: const TextStyle(
                    fontFamily: AppConstants.fontFamilySofiaSans,
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: EdgeInsets.only(
        left: AppConstants.paddingLarge,
        right: AppConstants.paddingLarge,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppConstants.logoutButtonHeight,
        child: ElevatedButton(
          onPressed: (_strokes.isEmpty || _isSending || _signatureDone)
              ? null
              : _confirmSignature,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            disabledBackgroundColor:
                AppColors.primaryDark.withValues(alpha: 0.4),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusRound),
            ),
          ),
          child: _isSending
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_outlined,
                        color: AppColors.white,
                        size: AppConstants.iconSizeMedium),
                    const SizedBox(width: 8),
                    Text(
                      'signature.confirm_button'.tr(),
                      style: const TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: AppConstants.fontSizeLarge,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _showExitConfirm() {
    if (_strokes.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.radiusMedium)),
        title: Text(
          'signature.exit_title'.tr(),
          style: const TextStyle(
            fontFamily: AppConstants.fontFamilySofiaSans,
            fontWeight: FontWeight.w700,
            fontSize: AppConstants.fontSizeLarge,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          'signature.exit_message'.tr(),
          style: const TextStyle(
            fontFamily: AppConstants.fontFamilyInter,
            fontSize: AppConstants.fontSizeMedium,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'signature.cancel'.tr(),
              style: const TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusRejected,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusRound)),
            ),
            child: Text(
              'signature.exit_confirm'.tr(),
              style: const TextStyle(
                fontFamily: AppConstants.fontFamilySofiaSans,
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Painter ──────────────────────────────────────────────────────────────────

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  _SignaturePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryDark
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length == 1) {
        canvas.drawCircle(stroke[0], 1.4, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path();
      path.moveTo(stroke[0].dx, stroke[0].dy);
      for (int i = 1; i < stroke.length - 1; i++) {
        final mid = Offset(
          (stroke[i].dx + stroke[i + 1].dx) / 2,
          (stroke[i].dy + stroke[i + 1].dy) / 2,
        );
        path.quadraticBezierTo(
            stroke[i].dx, stroke[i].dy, mid.dx, mid.dy);
      }
      path.lineTo(stroke.last.dx, stroke.last.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) => true;
}

// ── Success Bottom Sheet ──────────────────────────────────────────────────────

class _SuccessSheet extends StatelessWidget {
  final VoidCallback onDone;
  const _SuccessSheet({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXLarge)),
      ),
      padding: EdgeInsets.only(
        left: AppConstants.paddingXLarge,
        right: AppConstants.paddingXLarge,
        top: AppConstants.paddingXLarge,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: AppConstants.modalHandleWidth,
            height: AppConstants.modalHandleHeight,
            decoration: BoxDecoration(
              color: AppColors.borderGray,
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusRound),
            ),
          ),
          const SizedBox(height: 24),
          // Icône succès
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.statusValideGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline_rounded,
                color: AppColors.statusValideGreen, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            'signature.success_title'.tr(),
            style: const TextStyle(
              fontFamily: AppConstants.fontFamilySofiaSans,
              fontSize: AppConstants.fontSizeXLarge,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'signature.success_message'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppConstants.fontFamilyInter,
              fontSize: AppConstants.fontSizeMedium,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: AppConstants.logoutButtonHeight,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusRound),
                ),
              ),
              child: Text(
                'signature.done_button'.tr(),
                style: const TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: AppConstants.fontSizeLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
