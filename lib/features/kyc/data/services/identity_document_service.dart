import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:quick_forms/core/utils/base_url.dart';
import 'package:quick_forms/core/utils/http_client.dart';
import '../models/identity_document_model.dart';

class IdentityDocumentService {
  final http.Client _client;
  IdentityDocumentService({http.Client? client})
      : _client = client ?? HttpClientSingleton.instance;

  Map<String, String> _authHeaders(String token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  void _log(String msg) {
    // ignore: avoid_print
    print('[IdentityDocumentService] $msg');
  }

  /// GET /api/users/profile/identity-verification-document-types
  Future<List<KycDocTypeModel>> getKycDocumentTypes(String token) async {
    final url = BaseUrl.kycDocumentTypes;
    _log('GET $url');
    final response =
        await _client.get(Uri.parse(url), headers: _authHeaders(token));
    _log('GET $url → ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => KycDocTypeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Erreur types KYC: ${response.statusCode}');
  }

  /// GET /api/users/profile/identity-documents
  Future<List<IdentityDocumentModel>> getDocuments(String token) async {
    final url = BaseUrl.identityDocuments;
    _log('GET $url');
    final response = await _client.get(
      Uri.parse(url),
      headers: _authHeaders(token),
    );
    _log('GET $url → ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _log('${data.length} document(s) reçu(s)');
      return data
          .map((e) => IdentityDocumentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _log('ERREUR: ${data['message']}');
    throw Exception(data['message'] ?? 'Erreur récupération documents');
  }

  /// POST /api/users/profile/identity-documents
  /// kind = RECTO | VERSO | SELFIE
  Future<UploadDocumentResponse> uploadDocument({
    required String token,
    required File file,
    required String kind,
    String documentTypeId = '',
  }) async {
    final url = BaseUrl.identityDocuments;
    final fileSize = await file.length();
    final fileName = file.path.split(Platform.pathSeparator).last;
    _log(
        'POST $url | kind=$kind | documentTypeId=$documentTypeId | file=$fileName | size=${(fileSize / 1024).toStringAsFixed(1)}KB');

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(_authHeaders(token));
    request.fields['kind'] = kind;
    if (documentTypeId.isNotEmpty) {
      request.fields['documentTypeId'] = documentTypeId;
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
    _log('POST $url kind=$kind → ${response.statusCode}');
    _log('Réponse body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _log('Upload $kind réussi ✓ id=${data['id']} status=${data['status']}');
      return UploadDocumentResponse.fromJson(data);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _log('ERREUR upload $kind: ${data['message']}');
    throw Exception(data['message'] ?? 'Erreur upload document');
  }

  /// GET /api/users/profile/identity-documents/{documentId}/file
  Future<List<int>> getDocumentFile({
    required String token,
    required String documentId,
  }) async {
    final url = BaseUrl.identityDocumentFile(documentId);
    _log('GET $url');
    final response = await _client.get(
      Uri.parse(url),
      headers: _authHeaders(token),
    );
    _log(
        'GET $url → ${response.statusCode} | ${response.bodyBytes.length} bytes');
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    _log('ERREUR: document $documentId non trouvé');
    throw Exception('Document non trouvé');
  }
}
