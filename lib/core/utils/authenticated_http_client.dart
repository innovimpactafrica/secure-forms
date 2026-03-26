import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:secure_link/core/utils/base_url.dart';
import 'package:secure_link/core/utils/session_storage.dart';
import 'package:secure_link/core/utils/user_session.dart';

/// Client HTTP qui intercepte les 401 et rafraîchit automatiquement le token.
/// Toutes les requêtes qui échouent avec 401 sont relancées avec le nouveau token.
class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  bool _isRefreshing = false;

  AuthenticatedHttpClient._();
  static final AuthenticatedHttpClient instance = AuthenticatedHttpClient._();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Toujours injecter le token le plus récent depuis UserSession
    final token = UserSession.instance.accessToken;
    if (token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final response = await _inner.send(request);

    // Si 401 et pas déjà en train de refresh → tenter le refresh
    if (response.statusCode == 401 && !_isRefreshing) {
      final refreshToken = UserSession.instance.refreshToken;
      if (refreshToken.isEmpty) return response;

      _isRefreshing = true;
      try {
        // ignore: avoid_print
        print('[AuthenticatedHttpClient] 401 détecté → refresh token...');
        final newToken = await _refreshToken(refreshToken);
        if (newToken.isEmpty) return response;

        UserSession.instance.accessToken = newToken;
        await SessionStorage.instance.save(
          token: newToken,
          refreshToken: refreshToken,
          name: UserSession.instance.name,
          email: UserSession.instance.email,
          role: UserSession.instance.role,
          userId: UserSession.instance.userId,
        );
        // ignore: avoid_print
        print('[AuthenticatedHttpClient] Token rafraîchi ✓ → relance requête');

        final retryRequest = await _copyRequest(request, newToken);
        return _inner.send(retryRequest);
      } catch (e) {
        // ignore: avoid_print
        print('[AuthenticatedHttpClient] Refresh échoué: $e');
        return response;
      } finally {
        _isRefreshing = false;
      }
    }

    return response;
  }

  Future<String> _refreshToken(String refreshToken) async {
    final response = await _inner.post(
      Uri.parse(BaseUrl.refreshToken),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['accessToken']?.toString() ?? '';
    }
    return '';
  }

  /// Copie la requête avec le nouveau token.
  /// Pour MultipartRequest : relit les fichiers depuis leur chemin d'origine.
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
              f.field,
              f.filename!,
              contentType: f.contentType,
            ));
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
