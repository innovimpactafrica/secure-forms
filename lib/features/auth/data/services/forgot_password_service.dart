import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:secure_link/core/utils/base_url.dart';

class ForgotPasswordService {
  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<void> requestOtp({required String email}) async {
    final response = await _client
        .post(
          Uri.parse(BaseUrl.forgotPasswordRequestOtp),
          headers: _headers,
          body: jsonEncode({'email': email}),
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(data['message'] ?? 'Erreur envoi OTP');
    }
  }

  Future<void> resendOtp({required String email}) async {
    final response = await _client
        .post(
          Uri.parse(BaseUrl.forgotPasswordResendOtp),
          headers: _headers,
          body: jsonEncode({'email': email}),
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(data['message'] ?? 'Erreur renvoi OTP');
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _client
        .post(
          Uri.parse(BaseUrl.forgotPasswordReset),
          headers: _headers,
          body: jsonEncode({
            'email': email,
            'otp': otp,
            'newPassword': newPassword,
            'confirmPassword': confirmPassword,
          }),
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(data['message'] ?? 'Erreur réinitialisation');
    }
  }
}
