class RegisterResponse {
  final String message;
  final String sessionToken;
  final String expiresIn;
  final String otpExpiresIn;
  final String nextStep;

  const RegisterResponse({
    required this.message,
    required this.sessionToken,
    required this.expiresIn,
    required this.otpExpiresIn,
    required this.nextStep,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] ?? '',
      sessionToken: json['sessionToken'] ?? '',
      expiresIn: json['expiresIn']?.toString() ?? '',
      otpExpiresIn: json['otpExpiresIn']?.toString() ?? '',
      nextStep: json['nextStep'] ?? '',
    );
  }
}

class OtpVerifyResponse {
  final String message;
  final String email;
  final bool verified;
  final String nextStep;

  const OtpVerifyResponse({
    required this.message,
    required this.email,
    required this.verified,
    required this.nextStep,
  });

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) {
    return OtpVerifyResponse(
      message: json['message'] ?? '',
      email: json['email'] ?? '',
      verified: json['verified'] ?? false,
      nextStep: json['nextStep'] ?? '',
    );
  }
}

class SetupPasswordResponse {
  final String message;
  final String accessToken;
  final String refreshToken;

  const SetupPasswordResponse({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
  });

  factory SetupPasswordResponse.fromJson(Map<String, dynamic> json) {
    return SetupPasswordResponse(
      message: json['message'] ?? '',
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }
}

class LoginResponse {
  final String message;
  final String accessToken;
  final String refreshToken;

  const LoginResponse({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }
}