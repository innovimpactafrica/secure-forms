import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;
  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  Future<RegisterResponse> register(RegisterRequest request) async {
    return _authService.registerStep1(request);
  }

  Future<LoginResponse> login({required String email, required String password}) async {
    return _authService.login(email: email, password: password);
  }

  Future<OtpVerifyResponse> verifyOtp(OtpVerifyRequest request) async {
    return _authService.verifyRegistrationOtp(request);
  }

  Future<void> resendOtp({required String email}) async {
    return _authService.resendOtp(email: email);
  }

  Future<SetupPasswordResponse> setupPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    return _authService.setupPassword(
      token: token,
      password: password,
      confirmPassword: confirmPassword,
    );
  }
}