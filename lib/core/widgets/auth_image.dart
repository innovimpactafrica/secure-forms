import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:secure_link/core/utils/user_session.dart';

/// Charge une image en essayant d'abord l'URL directe (MinIO sans token),
/// puis fallback sur l'URL avec Bearer token → Image.memory.
/// Même logique que _DocumentImage dans mes_documents_screen.dart.
class AuthImage extends StatefulWidget {
  final String url;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget Function() fallback;

  const AuthImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    required this.fallback,
    this.fit = BoxFit.cover,
  });

  @override
  State<AuthImage> createState() => _AuthImageState();
}

class _AuthImageState extends State<AuthImage> {
  bool _loading = true;
  String? _directUrl;   // URL MinIO directe → CachedNetworkImage
  Uint8List? _bytes;    // fallback avec token → Image.memory

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    try {
      // 1. Essai URL directe sans token (MinIO public/signé)
      final res = await http
          .get(Uri.parse(widget.url))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        if (mounted) setState(() { _directUrl = widget.url; _loading = false; });
        return;
      }
    } catch (_) {}

    // 2. Fallback : même URL avec Bearer token
    try {
      final res = await http.get(
        Uri.parse(widget.url),
        headers: {'Authorization': 'Bearer ${UserSession.instance.accessToken}'},
      ).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        if (mounted) setState(() { _bytes = res.bodyBytes; _loading = false; });
        return;
      }
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      );
    }
    if (_directUrl != null) {
      return CachedNetworkImage(
        imageUrl: _directUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (_, __) => SizedBox(
          width: widget.width,
          height: widget.height,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
        ),
        errorWidget: (_, __, ___) => widget.fallback(),
      );
    }
    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (_, __, ___) => widget.fallback(),
      );
    }
    return widget.fallback();
  }
}
