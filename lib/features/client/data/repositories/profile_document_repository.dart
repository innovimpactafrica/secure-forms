import 'dart:io';
import '../models/profile_model.dart';
import '../services/profile_document_service.dart';

class ProfileDocumentRepository {
  final ProfileDocumentService _service;

  // Cache mémoire des fichiers documents : documentId → bytes
  // Évite de re-télécharger 1-2MB à chaque rebuild
  static final Map<String, List<int>> _fileCache = {};

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
    File? backFile,
    required String documentTypeId,
    String? issueDate,
    String? expirationDate,
  }) =>
      _service.uploadDocument(
        token: token,
        file: file,
        backFile: backFile,
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
  }) async {
    // Invalider le cache quand un document est supprimé
    _fileCache.remove(documentId);
    return _service.deleteDocument(token: token, documentId: documentId);
  }

  Future<List<int>> getDocumentFile({
    required String token,
    required String documentId,
  }) async {
    // Retourner depuis le cache si disponible
    if (_fileCache.containsKey(documentId)) {
      // ignore: avoid_print
      print('[ProfileDocumentRepository] Cache HIT pour $documentId');
      return _fileCache[documentId]!;
    }
    // ignore: avoid_print
    print('[ProfileDocumentRepository] Cache MISS pour $documentId — téléchargement...');
    final bytes = await _service.getDocumentFile(token: token, documentId: documentId);
    _fileCache[documentId] = bytes;
    return bytes;
  }

  /// Vider le cache (utile après upload d'un nouveau document)
  static void clearCache() => _fileCache.clear();
  static void invalidate(String documentId) => _fileCache.remove(documentId);
}
