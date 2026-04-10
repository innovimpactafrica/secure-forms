import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:socket_io_client/socket_io_client.dart' as sio;
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/utils/user_session.dart';

// URL Socket.IO backend
const _kSocketUrl = 'https://api.secure.innovimpactdev.cloud';

class SignatureScreen extends StatefulWidget {
  final String requestId;
  final String? wsUrl;
  final String? sessionId;
  final bool checkUserMatch;
  final Future<void> Function()? onUserMismatch;

  const SignatureScreen({
    super.key,
    required this.requestId,
    this.wsUrl,
    this.sessionId,
    this.checkUserMatch = false,
    this.onUserMismatch,
  });

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen>
    with SingleTickerProviderStateMixin {
  final List<List<Offset>> _strokes = [];
  List<Offset> _current = [];
  sio.Socket? _socket;
  bool _connected = false;
  bool _isSending = false;
  bool _signatureDone = false;
  final GlobalKey _canvasKey = GlobalKey();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // Taille du canvas pour normaliser les coordonnées (comme Angular)
  Size _canvasSize = Size.zero;

  String get _sid =>
      (widget.sessionId?.isNotEmpty == true) ? widget.sessionId! : widget.requestId;

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
    _connectSocket();
  }

  void _connectSocket() {
    _socket = sio.io(
      '$_kSocketUrl/realtime-signature',
      sio.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/api/socket.io')
          .enableForceNewConnection()
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[Socket.IO] connecté au namespace /realtime-signature');
      _socket!.emit('join', {'sessionId': _sid, 'role': 'mobile'});
      if (mounted) setState(() => _connected = true);
    });

    _socket!.onDisconnect((_) {
      debugPrint('[Socket.IO] déconnecté');
      if (mounted) setState(() => _connected = false);
    });

    _socket!.onConnectError((err) {
      debugPrint('[Socket.IO] erreur connexion: $err');
      if (mounted) setState(() => _connected = false);
    });

    // Écouter user_mismatch si même utilisateur requis
    _socket!.on('user_mismatch', (_) {
      if (widget.checkUserMatch) widget.onUserMismatch?.call();
    });

    _socket!.connect();
  }

  // Normaliser les coordonnées comme Angular (0..1)
  Map<String, double> _normalize(Offset local) {
    if (_canvasSize == Size.zero) return {'x': 0, 'y': 0};
    return {
      'x': (local.dx / _canvasSize.width).clamp(0.0, 1.0),
      'y': (local.dy / _canvasSize.height).clamp(0.0, 1.0),
    };
  }

  void _onPanStart(DragStartDetails d) {
    setState(() {
      _current = [d.localPosition];
      _strokes.add(_current);
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_current.isEmpty) return;
    final prev = _current.last;
    setState(() => _current.add(d.localPosition));

    // Émettre stroke exactement comme Angular
    final a = _normalize(prev);
    final b = _normalize(d.localPosition);
    _socket?.emit('stroke', {
      'sessionId': _sid,
      'color': '#0B3C5C',
      'width': 2,
      'points': [
        {'x': a['x'], 'y': a['y'], 't': DateTime.now().millisecondsSinceEpoch},
        {'x': b['x'], 'y': b['y'], 't': DateTime.now().millisecondsSinceEpoch},
      ],
    });
  }

  void _onPanEnd(DragEndDetails _) {}

  void _clearSignature() {
    setState(() {
      _strokes.clear();
      _current = [];
      _signatureDone = false;
    });
    _socket?.emit('clear', {'sessionId': _sid});
  }

  Future<void> _confirmSignature() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('signature.empty_signature'.tr()),
        backgroundColor: AppColors.statusRejected,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall)),
      ));
      return;
    }
    setState(() => _isSending = true);

    try {
      // Émettre done comme Angular
      _socket?.emit('done', {'sessionId': _sid});

      setState(() {
        _isSending = false;
        _signatureDone = true;
      });
      _showSuccessSheet();
    } catch (e) {
      setState(() => _isSending = false);
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => _SuccessSheet(
        onDone: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildInfoBanner(),
                  _buildCanvas(),
                  _buildToolbar(),
                  _buildBottomActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primaryDark,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 16,
        left: AppConstants.paddingLarge,
        right: AppConstants.paddingLarge,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showExitConfirm,
            child: Container(
              width: AppConstants.avatarSizeSmall,
              height: AppConstants.avatarSizeSmall,
              decoration: BoxDecoration(
                color: AppColors.whiteOverlay,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back,
                  color: AppColors.white, size: AppConstants.iconSizeMedium),
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
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${'signature.request_id'.tr()} $_sid',
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    fontSize: AppConstants.fontSizeRegular,
                    color: AppColors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Opacity(
              opacity: _connected ? _pulseAnim.value : 1.0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _connected
                      ? AppColors.statusValideGreen.withValues(alpha: 0.2)
                      : AppColors.statusRejected.withValues(alpha: 0.2),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusRound),
                  border: Border.all(
                    color: _connected
                        ? AppColors.statusValideGreen.withValues(alpha: 0.4)
                        : AppColors.statusRejected.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _connected
                            ? AppColors.statusValideGreen
                            : AppColors.statusRejected,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _connected ? 'Live' : 'Off',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontSize: AppConstants.fontSizeRegular,
                        fontWeight: FontWeight.w600,
                        color: _connected
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
          AppConstants.paddingLarge, 16, AppConstants.paddingLarge, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
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
      height: 320,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
            return Stack(
              children: [
                if (_strokes.isEmpty)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.draw_outlined,
                            size: 48, color: AppColors.borderLight),
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
                Positioned(
                  bottom: 48,
                  left: 32,
                  right: 32,
                  child: Container(height: 1, color: AppColors.borderLight),
                ),
                Positioned(
                  bottom: 32,
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
                RepaintBoundary(
                  key: _canvasKey,
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      child: Row(
        children: [
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
                padding: const EdgeInsets.symmetric(vertical: 14),
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
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppConstants.logoutButtonHeight,
        child: ElevatedButton(
          onPressed:
              (_strokes.isEmpty || _isSending || _signatureDone)
                  ? null
                  : _confirmSignature,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            disabledBackgroundColor:
                AppColors.primaryDark.withValues(alpha: 0.4),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
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
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
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

// ── Painter ───────────────────────────────────────────────────────────────────

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
        path.quadraticBezierTo(stroke[i].dx, stroke[i].dy, mid.dx, mid.dy);
      }
      path.lineTo(stroke.last.dx, stroke.last.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) => true;
}

// ── Success Sheet ─────────────────────────────────────────────────────────────

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
          Container(
            width: AppConstants.modalHandleWidth,
            height: AppConstants.modalHandleHeight,
            decoration: BoxDecoration(
              color: AppColors.borderGray,
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            ),
          ),
          const SizedBox(height: 24),
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
                  borderRadius: BorderRadius.circular(AppConstants.radiusRound),
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
