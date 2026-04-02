import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:secure_link/core/utils/base_url.dart';
import 'package:secure_link/core/utils/session_storage.dart';
import 'package:secure_link/core/utils/user_session.dart';

/// Client HTTP qui intercepte les 401 et rafraîchit automatiquement le token.
class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  bool _isRefreshing = false;
  Future<String>? _refreshFuture; // évite les refreshs parallèles
  static const _timeout = Duration(seconds: 30);

  AuthenticatedHttpClient._();
  static final AuthenticatedHttpClient instance = AuthenticatedHttpClient._();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
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

    if (response.statusCode == 401 && !_isRefreshing) {
      final refreshToken = UserSession.instance.refreshToken;
      if (refreshToken.isEmpty) return response;

      _isRefreshing = true;
      try {
        print('[AuthenticatedHttpClient] 401 détecté → refresh token...');
        final newToken = await _doRefresh(refreshToken);
        if (newToken.isEmpty) return response;
        print('[AuthenticatedHttpClient] Token rafraîchi ✓ → relance requête');
        final retryRequest = await _copyRequest(request, newToken);
        return _inner.send(retryRequest);
      } catch (e) {
        print('[AuthenticatedHttpClient] Refresh échoué: $e');
        return response;
      } finally {
        _isRefreshing = false;
      }
    }

    return response;
  }

  /// Appelé par le viewer avant un téléchargement direct (compute/isolate).
  /// Garantit que UserSession.accessToken est valide.
  Future<String> ensureFreshToken() async {
    // Si un refresh est déjà en cours, attendre qu'il se termine
    if (_refreshFuture != null) return _refreshFuture!;

    final refreshToken = UserSession.instance.refreshToken;
    if (refreshToken.isEmpty) return UserSession.instance.accessToken;

    _refreshFuture = _doRefresh(refreshToken).then((newToken) {
      _refreshFuture = null;
      return newToken.isNotEmpty ? newToken : UserSession.instance.accessToken;
    }).catchError((_) {
      _refreshFuture = null;
      return UserSession.instance.accessToken;
    });

    return _refreshFuture!;
  }

  Future<String> _doRefresh(String refreshToken) async {
    final response = await _inner.post(
      Uri.parse(BaseUrl.refreshToken),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
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
      }
      return newToken;
    }
    return '';
  }

  Future<String> _refreshToken(String refreshToken) => _doRefresh(refreshToken);

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
            r.files.add(await http.MultipartFile.fromPath(
              f.field, f.filename!, contentType: f.contentType));
          } catch (_) { r.files.add(f); }
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
