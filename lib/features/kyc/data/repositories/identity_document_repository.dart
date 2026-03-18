import 'dart:io';
import '../models/identity_document_model.dart';
import '../services/identity_document_service.dart';

class IdentityDocumentRepository {
  final IdentityDocumentService _service;

  IdentityDocumentRepository({IdentityDocumentService? service})
      : _service = service ?? IdentityDocumentService();

  Future<List<IdentityDocumentModel>> getDocuments(String token) =>
      _service.getDocuments(token);

  Future<UploadDocumentResponse> uploadDocument({
    required String token,
    required File file,
    required String kind,
  }) =>
      _service.uploadDocument(token: token, file: file, kind: kind);

  Future<List<int>> getDocumentFile({
    required String token,
    required String documentId,
  }) =>
      _service.getDocumentFile(token: token, documentId: documentId);
}
