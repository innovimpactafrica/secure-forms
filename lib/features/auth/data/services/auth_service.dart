import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:secure_link/core/utils/base_url.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';

class AuthService {
  final http.Client _client;
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // POST /api/auth/register/client/step1
  Future<RegisterResponse> registerStep1(RegisterRequest request) async {
    final response = await _client.post(
      Uri.parse(BaseUrl.registerStep1),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 || response.statusCode == 201) {
      return RegisterResponse.fromJson(data);
    }
    throw Exception(data['message'] ?? 'Erreur inscription');
  }

  // POST /api/auth/login — Body : { "email": "...", "password": "..." }
  Future<LoginResponse> login({required String email, required String password}) async {
    final response = await _client.post(
      Uri.parse(BaseUrl.login),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 || response.statusCode == 201) {
      return LoginResponse.fromJson(data);
    }
    throw Exception(data['message'] ?? 'Erreur connexion');
  }

  // POST /api/auth/register/client/verify-otp
  Future<OtpVerifyResponse> verifyRegistrationOtp(OtpVerifyRequest request) async {
    final response = await _client.post(
      Uri.parse(BaseUrl.verifyRegistrationOtp),
      headers: _headers,
      body: jsonEncode({
        'sessionToken': request.sessionToken,
        'otp': request.otp,
      }),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 || response.statusCode == 201) {
      return OtpVerifyResponse.fromJson(data);
    }
    throw Exception(data['message'] ?? 'Code OTP invalide');
  }

  // POST /api/auth/resend-otp
  Future<void> resendOtp({required String email}) async {
    final response = await _client.post(
      Uri.parse(BaseUrl.resendOtp),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(data['message'] ?? 'Erreur renvoi OTP');
    }
  }

  // POST /api/auth/refresh
  Future<String> refreshAccessToken(String refreshToken) async {
    final response = await _client.post(
      Uri.parse(BaseUrl.refreshToken),
      headers: _headers,
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 || response.statusCode == 201) {
      return data['accessToken']?.toString() ?? '';
    }
    throw Exception(data['message'] ?? 'Refresh token invalide');
  }

  // POST /api/auth/setup-password
  // Body : { "token": "...", "password": "...", "confirmPassword": "..." }
  Future<SetupPasswordResponse> setupPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _client.post(
      Uri.parse(BaseUrl.setupPassword),
      headers: _headers,
      body: jsonEncode({
        'token': token,
        'password': password,
        'confirmPassword': confirmPassword,
      }),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 || response.statusCode == 201) {
      return SetupPasswordResponse.fromJson(data);
    }
    throw Exception(data['message'] ?? 'Erreur création mot de passe');
  }
}