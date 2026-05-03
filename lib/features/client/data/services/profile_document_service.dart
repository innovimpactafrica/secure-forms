import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:quick_forms/core/utils/base_url.dart';
import 'package:quick_forms/core/utils/http_client.dart';
import '../models/profile_model.dart';

class ProfileDocumentService {
  final http.Client _client;

  ProfileDocumentService({http.Client? client})
      : _client = client ?? HttpClientSingleton.instance;

  Map<String, String> _authHeaders(String token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  void _log(String msg) {
    // ignore: avoid_print
    print('[ProfileDocumentService] $msg');
  }

  /// GET /api/users/profile/document-types
  Future<List<DocumentTypeModel>> getDocumentTypes(String token) async {
    final url = BaseUrl.profileDocumentTypes;
    _log('GET $url');
    final response = await _client.get(
      Uri.parse(url),
      headers: _authHeaders(token),
    );
    _log('GET $url → ${response.statusCode}');
    _log('Body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _log('${data.length} type(s) de document reçu(s)');
      return data
          .map((e) => DocumentTypeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final err = jsonDecode(response.body) as Map<String, dynamic>;
    _log('ERREUR getDocumentTypes: ${err['message']}');
    throw Exception(err['message'] ?? 'Erreur récupération types de documents');
  }

  /// GET /api/users/profile/completion
  Future<ProfileCompletionModel> getProfileCompletion(String token) async {
    final url = BaseUrl.profileCompletion;
    _log('GET $url');
    final response = await _client.get(
      Uri.parse(url),
      headers: _authHeaders(token),
    );
    _log('GET $url → ${response.statusCode}');
    _log('Body: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _log('Complétion: ${data['completion']}%');
      return ProfileCompletionModel.fromJson(data);
    }
    final err = jsonDecode(response.body) as Map<String, dynamic>;
    _log('ERREUR getProfileCompletion: ${err['message']}');
    throw Exception(err['message'] ?? 'Erreur récupération complétion profil');
  }

  /// GET /api/users/profile/documents
  Future<List<UploadedDocumentModel>> getDocuments(String token) async {
    final url = BaseUrl.profileDocuments;
    _log('GET $url');
    final response = await _client.get(
      Uri.parse(url),
      headers: _authHeaders(token),
    );
    _log('GET $url → ${response.statusCode}');
    _log('Body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _log('${data.length} document(s) uploadé(s) reçu(s)');
      return data
          .map((e) => UploadedDocumentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final err = jsonDecode(response.body) as Map<String, dynamic>;
    _log('ERREUR getDocuments: ${err['message']}');
    throw Exception(err['message'] ?? 'Erreur récupération documents');
  }

  /// POST /api/users/profile/documents (multipart)
  Future<UploadedDocumentModel> uploadDocument({
    required String token,
    required File file,
    File? backFile,
    required String documentTypeId,
    String? issueDate,
    String? expirationDate,
  }) async {
    final url = BaseUrl.profileDocuments;
    final fileName = file.path.split(Platform.pathSeparator).last;
    final fileSize = await file.length();
    _log(
        'POST $url | documentTypeId=$documentTypeId | file=$fileName | size=${(fileSize / 1024).toStringAsFixed(1)}KB');
    if (issueDate != null) _log('issueDate=$issueDate');
    if (expirationDate != null) _log('expirationDate=$expirationDate');
    _log(
        'token vide: ${token.isEmpty} | Authorization header: Bearer ${token.length > 20 ? token.substring(0, 20) : token}...');
    _log('backFile présent: ${backFile != null}');
    if (backFile != null) {
      final backName = backFile.path.split(Platform.pathSeparator).last;
      final backSize = await backFile.length();
      _log(
          'backFile=$backName | size=${(backSize / 1024).toStringAsFixed(1)}KB');
    }

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(_authHeaders(token));
    request.fields['documentTypeId'] = documentTypeId;
    if (issueDate != null && issueDate.isNotEmpty) {
      request.fields['issueDate'] = issueDate;
    }
    if (expirationDate != null && expirationDate.isNotEmpty) {
      request.fields['expirationDate'] = expirationDate;
    }

    String mimeFor(String path) {
      final ext = path.split('.').last.toLowerCase();
      if (ext == 'png') return 'image/png';
      if (ext == 'pdf') return 'application/pdf';
      return 'image/jpeg';
    }

    request.files.add(await http.MultipartFile.fromPath(
      'files',
      file.path,
      contentType: MediaType.parse(mimeFor(file.path)),
    ));

    if (backFile != null) {
      _log('Ajout verso avec champ="files": ${backFile.path}');
      request.files.add(await http.MultipartFile.fromPath(
        'files',
        backFile.path,
        contentType: MediaType.parse(mimeFor(backFile.path)),
      ));
    }

    // ── LOG COMPLET de la requête multipart ──────────────────────
    _log('=== MULTIPART REQUEST DETAILS ===');
    _log('URL: $url');
    _log('Fields envoyés:');
    request.fields.forEach((k, v) => _log('  $k = $v'));
    _log('Files envoyés:');
    for (final f in request.files) {
      _log(
          '  field="${f.field}" filename="${f.filename}" contentType=${f.contentType} length=${f.length}');
    }
    _log('=================================');

    _log('Envoi multipart en cours...');
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    _log('POST $url → ${response.statusCode}');
    _log('Response headers: ${response.headers}');
    _log('Réponse body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      // Le backend retourne un tableau [{...}, {...}] ou un objet {...}
      final Map<String, dynamic> data = decoded is List
          ? (decoded.first as Map<String, dynamic>)
          : (decoded as Map<String, dynamic>);
      _log('Upload réussi ✓ id=${data['id']} status=${data['status']}');
      return UploadedDocumentModel.fromJson(data);
    }
    final err = jsonDecode(response.body) as Map<String, dynamic>;
    _log('ERREUR upload: ${err['message']}');
    throw Exception(err['message'] ?? 'Erreur upload document');
  }

  /// PATCH /api/users/profile/documents/{id} — remplace le fichier et/ou les dates
  Future<void> replaceDocumentFile({
    required String token,
    required String documentId,
    File? file,
    String? issueDate,
    String? expirationDate,
  }) async {
    final url = BaseUrl.deleteProfileDocument(documentId);
    _log('PATCH $url (multipart)');

    final request = http.MultipartRequest('PATCH', Uri.parse(url));
    request.headers.addAll(_authHeaders(token));

    // Convertir les dates ISO en jj/mm/aaaa si nécessaire
    String? _toDisplayDate(String? raw) {
      if (raw == null || raw.isEmpty) return null;
      if (raw.contains('/')) return raw; // déjà au bon format
      final parsed = DateTime.tryParse(raw);
      if (parsed == null) return raw;
      return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
    }

    final formattedIssue = _toDisplayDate(issueDate);
    final formattedExpiry = _toDisplayDate(expirationDate);

    if (formattedIssue != null) {
      request.fields['issueDate'] = formattedIssue;
      _log('issueDate=$formattedIssue');
    }
    if (formattedExpiry != null) {
      request.fields['expirationDate'] = formattedExpiry;
      _log('expirationDate=$formattedExpiry');
    }

    if (file != null) {
      final ext = file.path.split('.').last.toLowerCase();
      String mime = 'image/jpeg';
      if (ext == 'png') mime = 'image/png';
      if (ext == 'pdf') mime = 'application/pdf';
      request.files.add(await http.MultipartFile.fromPath('file', file.path,
          contentType: MediaType.parse(mime)));
      _log('Fichier de remplacement: ${file.path}');
    }

    _log('Fields: ${request.fields}');
    _log('Files: ${request.files.map((f) => f.filename).toList()}');

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    _log('PATCH $url → ${response.statusCode} | body: ${response.body}');
    if (response.statusCode == 200) {
      _log('Document $documentId modifié ✓');
      return;
    }
    throw Exception('Erreur modification document: ${response.body}');
  }

  /// PATCH /api/users/profile/documents/{id}
  Future<void> patchDocument({
    required String token,
    required String documentId,
    String? issueDate,
    String? expirationDate,
  }) async {
    final url = BaseUrl.deleteProfileDocument(documentId);
    _log('PATCH $url');
    final body = <String, String>{};
    if (issueDate != null && issueDate.isNotEmpty)
      body['issueDate'] = issueDate;
    if (expirationDate != null && expirationDate.isNotEmpty)
      body['expirationDate'] = expirationDate;
    final response = await _client.patch(
      Uri.parse(url),
      headers: {..._authHeaders(token), 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    _log('PATCH $url → ${response.statusCode}');
    if (response.statusCode == 200) {
      _log('Document $documentId modifié ✓');
      return;
    }
    _log('ERREUR patch document $documentId: ${response.body}');
    throw Exception('Erreur modification document');
  }

  /// DELETE /api/users/profile/documents/{documentId}
  Future<void> deleteDocument({
    required String token,
    required String documentId,
  }) async {
    final url = BaseUrl.deleteProfileDocument(documentId);
    _log('DELETE $url');
    final response = await _client.delete(
      Uri.parse(url),
      headers: _authHeaders(token),
    );
    _log('DELETE $url → ${response.statusCode}');
    if (response.statusCode == 204 || response.statusCode == 200) {
      _log('Document $documentId supprimé ✓');
      return;
    }
    _log('ERREUR delete document $documentId: ${response.body}');
    throw Exception('Erreur suppression document');
  }

  /// GET fichier depuis URL MinIO signée directe (sans token)
  /// Si 403/404 → fallback via /api/storage/files/{objectKey} avec token
  Future<List<int>> getDocumentFileFromUrl(String url) async {
    _log('GET MinIO direct: $url');
    final response = await _client.get(Uri.parse(url)).timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw Exception('MinIO timeout'),
        );
    _log('MinIO → ${response.statusCode} | ${response.bodyBytes.length} bytes');
    if (response.statusCode == 200) return response.bodyBytes;
    // URL expirée → extraire la objectKey et utiliser le proxy stable
    if (response.statusCode == 403 || response.statusCode == 404) {
      final objectKey = _extractObjectKey(url);
      if (objectKey != null) {
        _log('MinIO expiré → fallback proxy: $objectKey');
        throw Exception('EXPIRED'); // sera capturé par le repository
      }
    }
    throw Exception('Erreur téléchargement MinIO: ${response.statusCode}');
  }

  /// Extrait la objectKey depuis une URL MinIO signée
  /// Ex: https://minio.../profiles/documents/xxx.pdf?X-Amz-... → profiles/documents/xxx.pdf
  String? _extractObjectKey(String url) {
    try {
      final uri = Uri.parse(url);
      // Le path commence par / suivi du bucket puis de la clé
      // Ex: /secure-forms-bucket/profiles/documents/xxx.pdf
      final parts = uri.path.split('/');
      if (parts.length >= 3) {
        // Ignorer le premier segment vide et le bucket
        return parts.sublist(2).join('/');
      }
    } catch (_) {}
    return null;
  }

  /// GET /api/storage/files/{objectKey} — proxy stable (URL ne périme pas)
  Future<List<int>> getDocumentFileFromStorageProxy({
    required String token,
    required String objectKey,
  }) async {
    final url = BaseUrl.storageFile(objectKey);
    _log('GET storage proxy: $url');
    final response = await _client
        .get(
          Uri.parse(url),
          headers: _authHeaders(token),
        )
        .timeout(const Duration(seconds: 30));
    _log(
        'Storage proxy → ${response.statusCode} | ${response.bodyBytes.length} bytes');
    if (response.statusCode == 200) return response.bodyBytes;
    throw Exception('Erreur storage proxy: ${response.statusCode}');
  }

  /// GET /api/users/profile/documents/{documentId}/file
  Future<List<int>> getDocumentFile({
    required String token,
    required String documentId,
  }) async {
    final url = BaseUrl.profileDocumentFile(documentId);
    _log('GET $url');
    final response = await _client
        .get(
          Uri.parse(url),
          headers: _authHeaders(token),
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Timeout téléchargement document'),
        );
    _log(
        'GET $url → ${response.statusCode} | ${response.bodyBytes.length} bytes');
    if (response.statusCode == 200) return response.bodyBytes;
    _log('ERREUR: document $documentId non trouvé');
    throw Exception('Document non trouvé');
  }
}
