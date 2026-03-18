import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:secure_link/core/utils/base_url.dart';
import '../models/user_profile_model.dart';

class UserProfileService {
  final http.Client _client;
  UserProfileService({http.Client? client}) : _client = client ?? http.Client();

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

  /// PATCH /api/users/me/profile — upload photo de profil (et infos personnelles)
  Future<void> updateProfilePicture({
    required String accessToken,
    required File picture,
  }) async {
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

  /// GET /api/users/me/profile-picture
  Future<List<int>> getProfilePicture(String accessToken) async {
    final response = await _client.get(
      Uri.parse(BaseUrl.getProfilePicture),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    print('=== GET /users/me/profile-picture STATUS: ${response.statusCode} ===');
    if (response.statusCode == 200) return response.bodyBytes;
    throw Exception('Aucune photo de profil');
  }
}
