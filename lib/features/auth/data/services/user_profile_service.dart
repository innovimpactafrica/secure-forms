import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:secure_link/core/utils/base_url.dart';
import 'package:secure_link/core/utils/http_client.dart';
import '../models/user_profile_model.dart';

class UserProfileService {
  final http.Client _client;
  UserProfileService({http.Client? client}) : _client = client ?? HttpClientSingleton.instance;

  // Cache mémoire de la photo
  static Uint8List? _pictureCache;
  static String? _pictureCacheUserId;

  Future<UserProfileModel> getProfile(String accessToken) async {
    final response = await _client.get(
      Uri.parse(BaseUrl.getUserProfile),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    print('=== GET /auth/profile STATUS: ${response.statusCode} ===');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return UserProfileModel.fromJson(data);
    }
    throw Exception(data['message'] ?? 'Erreur récupération profil');
  }

  /// PATCH /api/users/me/profile — upload photo de profil
  Future<void> updateProfilePicture({
    required String accessToken,
    required File picture,
  }) async {
    // Invalider le cache photo
    _pictureCache = null;
    _pictureCacheUserId = null;
    await _deleteCachedPicture();

    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse(BaseUrl.updateUserProfile),
    );
    request.headers['Authorization'] = 'Bearer $accessToken';
    final ext = picture.path.split('.').last.toLowerCase();
    final mime = ext == 'png' ? 'image/png' : ext == 'webp' ? 'image/webp' : 'image/jpeg';
    request.files.add(await http.MultipartFile.fromPath(
      'profilePicture',
      picture.path,
      contentType: MediaType.parse(mime),
    ));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    print('=== PATCH /users/me/profile STATUS: ${response.statusCode} ===');
    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(data['message'] ?? 'Erreur mise à jour photo');
    }
  }

  /// GET /api/users/me/profile-picture — avec cache mémoire + disque
  Future<List<int>> getProfilePicture(String accessToken, {String? userId}) async {
    // 1. Cache mémoire
    if (_pictureCache != null && (userId == null || userId == _pictureCacheUserId)) {
      print('=== PROFILE PICTURE: cache mémoire HIT ===');
      return _pictureCache!;
    }

    // 2. Cache disque
    final cached = await _loadCachedPicture(userId);
    if (cached != null) {
      print('=== PROFILE PICTURE: cache disque HIT ===');
      _pictureCache = cached;
      _pictureCacheUserId = userId;
      return cached;
    }

    // 3. API
    print('=== PROFILE PICTURE: téléchargement API ===');
    final response = await _client.get(
      Uri.parse(BaseUrl.getProfilePicture),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    print('=== GET /users/me/profile-picture STATUS: ${response.statusCode} ===');
    if (response.statusCode == 200) {
      final bytes = Uint8List.fromList(response.bodyBytes);
      _pictureCache = bytes;
      _pictureCacheUserId = userId;
      await _saveCachedPicture(bytes, userId);
      return bytes;
    }
    throw Exception('Aucune photo de profil');
  }

  static Future<String> _cacheFilePath(String? userId) async {
    final dir = await getTemporaryDirectory();
    final suffix = userId != null ? '_$userId' : '';
    return '${dir.path}/profile_picture$suffix.cache';
  }

  static Future<Uint8List?> _loadCachedPicture(String? userId) async {
    try {
      final path = await _cacheFilePath(userId);
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) return bytes;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> _saveCachedPicture(Uint8List bytes, String? userId) async {
    try {
      final path = await _cacheFilePath(userId);
      await File(path).writeAsBytes(bytes);
    } catch (_) {}
  }

  static Future<void> _deleteCachedPicture() async {
    try {
      final dir = await getTemporaryDirectory();
      final files = dir.listSync().where((f) => f.path.contains('profile_picture'));
      for (final f in files) { await f.delete(); }
    } catch (_) {}
  }

  /// Invalider le cache (appeler après changement de photo)
  static void invalidateCache() {
    _pictureCache = null;
    _pictureCacheUserId = null;
  }
}
