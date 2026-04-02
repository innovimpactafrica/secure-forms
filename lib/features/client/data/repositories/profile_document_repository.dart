import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../models/profile_model.dart';
import '../services/profile_document_service.dart';

class ProfileDocumentRepository {
  final ProfileDocumentService _service;

  // Cache mémoire : documentId/url → bytes
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

  Future<void> replaceDocumentFile({
    required String token,
    required String documentId,
    File? file,
    String? issueDate,
    String? expirationDate,
  }) async {
    _fileCache.remove(documentId);
    await _deleteDiskCache(documentId);
    return _service.replaceDocumentFile(
      token: token,
      documentId: documentId,
      file: file,
      issueDate: issueDate,
      expirationDate: expirationDate,
    );
  }

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
    _fileCache.remove(documentId);
    await _deleteDiskCache(documentId);
    return _service.deleteDocument(token: token, documentId: documentId);
  }

  Future<List<int>> getDocumentFile({
    required String token,
    required String documentId,
    String? directUrl,
  }) async {
    final cacheKey = directUrl != null ? 'url:${directUrl.split('?').first}' : documentId;

    // 1. Cache mémoire
    if (_fileCache.containsKey(cacheKey)) {
      print('[Repo] Cache mémoire HIT: $documentId');
      return _fileCache[cacheKey]!;
    }

    // 2. Cache disque
    final diskBytes = await _loadDiskCache(cacheKey);
    if (diskBytes != null) {
      print('[Repo] Cache disque HIT: $documentId');
      _fileCache[cacheKey] = diskBytes;
      return diskBytes;
    }

    // 3. Téléchargement
    List<int> bytes;
    if (directUrl != null && directUrl.isNotEmpty) {
      try {
        bytes = await _service.getDocumentFileFromUrl(directUrl);
      } catch (e) {
        // URL MinIO expirée ou invalide → fallback endpoint /file avec token
        final objectKey = _extractObjectKey(directUrl);
        if (objectKey != null) {
          try {
            bytes = await _service.getDocumentFileFromStorageProxy(
              token: token,
              objectKey: objectKey,
            );
          } catch (_) {
            bytes = await _service.getDocumentFile(token: token, documentId: documentId);
          }
        } else {
          bytes = await _service.getDocumentFile(token: token, documentId: documentId);
        }
      }
    } else {
      bytes = await _service.getDocumentFile(token: token, documentId: documentId);
    }
    _fileCache[cacheKey] = bytes;
    await _saveDiskCache(cacheKey, bytes);
    return bytes;
  }

  // ── Cache disque ──────────────────────────────────────────────
  static Future<String> _diskPath(String key) async {
    final dir = await getTemporaryDirectory();
    final safe = key.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return '${dir.path}/doc_cache_$safe.bin';
  }

  static Future<Uint8List?> _loadDiskCache(String key) async {
    try {
      final file = File(await _diskPath(key));
      if (await file.exists()) return await file.readAsBytes();
    } catch (_) {}
    return null;
  }

  static Future<void> _saveDiskCache(String key, List<int> bytes) async {
    try {
      final file = File(await _diskPath(key));
      await file.writeAsBytes(bytes);
    } catch (_) {}
  }

  static Future<void> _deleteDiskCache(String key) async {
    try {
      final file = File(await _diskPath(key));
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  static void clearCache() {
    _fileCache.clear();
    // Nettoyage disque asynchrone
    getTemporaryDirectory().then((dir) {
      dir.listSync()
          .where((f) => f.path.contains('doc_cache_'))
          .forEach((f) => f.deleteSync());
    }).catchError((_) {});
  }

  static void invalidate(String documentId) {
    _fileCache.remove(documentId);
    _deleteDiskCache(documentId);
  }

  /// Extrait la objectKey depuis une URL MinIO signée
  /// Ex: https://minio.../bucket/profiles/documents/xxx.pdf?X-Amz-... → profiles/documents/xxx.pdf
  static String? _extractObjectKey(String url) {
    try {
      final uri = Uri.parse(url);
      final parts = uri.path.split('/');
      // parts[0] = '', parts[1] = bucket, parts[2..] = objectKey
      if (parts.length >= 3) {
        return parts.sublist(2).join('/');
      }
    } catch (_) {}
    return null;
  }
}
