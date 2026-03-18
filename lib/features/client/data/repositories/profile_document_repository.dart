import 'dart:io';
import '../models/profile_model.dart';
import '../services/profile_document_service.dart';

class ProfileDocumentRepository {
  final ProfileDocumentService _service;

  ProfileDocumentRepository({ProfileDocumentService? service})
      : _service = service ?? ProfileDocumentService();

  Future<List<DocumentTypeModel>> getDocumentTypes(String token) =>
      _service.getDocumentTypes(token);

  Future<ProfileCompletionModel> getProfileCompletion(String token) =>
      _service.getProfileCompletion(token);

  Future<List<UploadedDocumentModel>> getDocuments(String token) =>
      _service.getDocuments(token);

  Future<UploadedDocumentModel> uploadDocument({
    required String token,
    required File file,
    required String documentTypeId,
    String? issueDate,
    String? expirationDate,
  }) =>
      _service.uploadDocument(
        token: token,
        file: file,
        documentTypeId: documentTypeId,
        issueDate: issueDate,
        expirationDate: expirationDate,
      );

  Future<void> patchDocument({
    required String token,
    required String documentId,
    String? issueDate,
    String? expirationDate,
  }) =>
      _service.patchDocument(
        token: token,
        documentId: documentId,
        issueDate: issueDate,
        expirationDate: expirationDate,
      );

  Future<void> deleteDocument({
    required String token,
    required String documentId,
  }) =>
      _service.deleteDocument(token: token, documentId: documentId);

  Future<List<int>> getDocumentFile({
    required String token,
    required String documentId,
  }) =>
      _service.getDocumentFile(token: token, documentId: documentId);
}
