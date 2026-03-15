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
  final String firstName;
  final String lastName;

  const LoginResponse({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.firstName,
    required this.lastName,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final nameParts = (user['name'] as String? ?? '').trim().split(' ');
    return LoginResponse(
      message: json['message'] ?? '',
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      firstName: nameParts.isNotEmpty ? nameParts.first : '',
      lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      role: user['role'] ?? '',
    );
  }
}