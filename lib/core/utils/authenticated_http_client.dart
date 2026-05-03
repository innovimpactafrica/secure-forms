import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_forms/core/utils/base_url.dart';
import 'package:quick_forms/core/utils/navigator_key.dart';
import 'package:quick_forms/core/utils/session_storage.dart';
import 'package:quick_forms/core/utils/user_session.dart';

/// Client HTTP qui intercepte les 401 et rafraîchit automatiquement le token.
/// Toutes les requêtes parallèles attendent le même refresh (pas de double refresh).
class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  static const _timeout = Duration(seconds: 30);

  // Future partagé : toutes les requêtes en attente utilisent le même refresh
  Future<String>? _refreshFuture;

  AuthenticatedHttpClient._();
  static final AuthenticatedHttpClient instance = AuthenticatedHttpClient._();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Injecter le token frais depuis UserSession
    final token = UserSession.instance.accessToken;
    if (token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final http.StreamedResponse response;
    try {
      response = await _inner.send(request).timeout(_timeout);
    } on Exception {
      rethrow;
    }

    if (response.statusCode != 401) return response;

    // ── 401 détecté ──
    print('[AuthenticatedHttpClient] 401 sur ${request.url.path} → refresh...');

    final refreshToken = UserSession.instance.refreshToken;
    if (refreshToken.isEmpty) {
      print('[AuthenticatedHttpClient] Pas de refresh token → logout');
      _forceLogout();
      return response;
    }

    try {
      // Un seul refresh partagé pour toutes les requêtes parallèles
      final newToken = await _getOrStartRefresh(refreshToken);

      if (newToken.isEmpty) {
        print('[AuthenticatedHttpClient] Refresh échoué → logout');
        _forceLogout();
        return response;
      }

      print(
          '[AuthenticatedHttpClient] Token rafraîchi ✓ → relance ${request.url.path}');
      final retryRequest = await _copyRequest(request, newToken);
      return _inner.send(retryRequest).timeout(_timeout);
    } catch (e) {
      print('[AuthenticatedHttpClient] Erreur refresh: $e → logout');
      _forceLogout();
      return response;
    }
  }

  /// Démarre un refresh ou retourne le Future déjà en cours
  Future<String> _getOrStartRefresh(String refreshToken) {
    _refreshFuture ??= _doRefresh(refreshToken).whenComplete(() {
      _refreshFuture = null;
    });
    return _refreshFuture!;
  }

  /// Appelé depuis le splash pour refresh proactif
  Future<String> ensureFreshToken() async {
    final refreshToken = UserSession.instance.refreshToken;
    if (refreshToken.isEmpty) return UserSession.instance.accessToken;
    return _getOrStartRefresh(refreshToken);
  }

  Future<String> _doRefresh(String refreshToken) async {
    print('[AuthenticatedHttpClient] _doRefresh → POST /auth/refresh');
    try {
      final response = await _inner
          .post(
            Uri.parse(BaseUrl.refreshToken),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(_timeout);

      print('[AuthenticatedHttpClient] refresh status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newToken = data['accessToken']?.toString() ?? '';
        if (newToken.isNotEmpty) {
          UserSession.instance.accessToken = newToken;
          await SessionStorage.instance.save(
            token: newToken,
            refreshToken: refreshToken,
            name: UserSession.instance.name,
            email: UserSession.instance.email,
            role: UserSession.instance.role,
            userId: UserSession.instance.userId,
          );
          print('[AuthenticatedHttpClient] Nouveau token sauvegardé ✓');
        }
        return newToken;
      }

      // Refresh token expiré ou invalide
      print(
          '[AuthenticatedHttpClient] Refresh refusé (${response.statusCode})');
      return '';
    } catch (e) {
      print('[AuthenticatedHttpClient] Erreur réseau refresh: $e');
      return '';
    }
  }

  void _forceLogout() {
    SessionStorage.instance.clear();
    UserSession.instance.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    });
  }

  Future<http.BaseRequest> _copyRequest(
      http.BaseRequest original, String newToken) async {
    if (original is http.Request) {
      final r = http.Request(original.method, original.url);
      r.headers.addAll(original.headers);
      r.headers['Authorization'] = 'Bearer $newToken';
      r.bodyBytes = original.bodyBytes;
      return r;
    }
    if (original is http.MultipartRequest) {
      final r = http.MultipartRequest(original.method, original.url);
      r.headers.addAll(original.headers);
      r.headers['Authorization'] = 'Bearer $newToken';
      r.fields.addAll(original.fields);
      for (final f in original.files) {
        if (f.filename != null) {
          try {
            r.files.add(await http.MultipartFile.fromPath(f.field, f.filename!,
                contentType: f.contentType));
          } catch (_) {
            r.files.add(f);
          }
        } else {
          r.files.add(f);
        }
      }
      return r;
    }
    original.headers['Authorization'] = 'Bearer $newToken';
    return original;
  }
}
