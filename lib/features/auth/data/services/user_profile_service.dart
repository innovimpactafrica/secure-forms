import 'dart:convert';
import 'package:http/http.dart' as http;
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
}
