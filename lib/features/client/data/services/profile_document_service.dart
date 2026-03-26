import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:secure_link/core/utils/base_url.dart';
import 'package:secure_link/core/utils/http_client.dart';
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
    required String documentTypeId,
    String? issueDate,
    String? expirationDate,
  }) async {
    final url = BaseUrl.profileDocuments;
    final fileName = file.path.split(Platform.pathSeparator).last;
    final fileSize = await file.length();
    _log('POST $url | documentTypeId=$documentTypeId | file=$fileName | size=${(fileSize / 1024).toStringAsFixed(1)}KB');
    if (issueDate != null) _log('issueDate=$issueDate');
    if (expirationDate != null) _log('expirationDate=$expirationDate');

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(_authHeaders(token));
    request.fields['documentTypeId'] = documentTypeId;
    if (issueDate != null && issueDate.isNotEmpty) {
      request.fields['issueDate'] = issueDate;
    }
    if (expirationDate != null && expirationDate.isNotEmpty) {
      request.fields['expirationDate'] = expirationDate;
    }

    final ext = fileName.split('.').last.toLowerCase();
    final mime = ext == 'png'
        ? 'image/png'
        : ext == 'pdf'
            ? 'application/pdf'
            : 'image/jpeg';
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: MediaType.parse(mime),
    ));

    _log('Envoi multipart en cours...');
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    _log('POST $url → ${response.statusCode}');
    _log('Réponse body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _log('Upload réussi ✓ id=${data['id']} status=${data['status']}');
      return UploadedDocumentModel.fromJson(data);
    }
    final err = jsonDecode(response.body) as Map<String, dynamic>;
    _log('ERREUR upload: ${err['message']}');
    throw Exception(err['message'] ?? 'Erreur upload document');
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
    if (issueDate != null && issueDate.isNotEmpty) body['issueDate'] = issueDate;
    if (expirationDate != null && expirationDate.isNotEmpty) body['expirationDate'] = expirationDate;
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

  /// GET /api/users/profile/documents/{documentId}/file
  Future<List<int>> getDocumentFile({
    required String token,
    required String documentId,
  }) async {
    final url = BaseUrl.profileDocumentFile(documentId);
    _log('GET $url');
    final response = await _client.get(
      Uri.parse(url),
      headers: _authHeaders(token),
    );
    _log('GET $url → ${response.statusCode} | ${response.bodyBytes.length} bytes');
    if (response.statusCode == 200) return response.bodyBytes;
    _log('ERREUR: document $documentId non trouvé');
    throw Exception('Document non trouvé');
  }
}
