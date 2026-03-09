class RegisterRequest {
  final String lastName;
  final String firstName;
  final String email;
  final String phone;
  final String address;
  final String dateOfBirth;
  final String gender;
  final String maritalStatus;

  const RegisterRequest({
    required this.lastName,
    required this.firstName,
    required this.email,
    required this.phone,
    required this.address,
    required this.dateOfBirth,
    required this.gender,
    required this.maritalStatus,
  });

  Map<String, dynamic> toJson() => {
        'lastName': lastName,
        'firstName': firstName,
        'email': email,
        'phone': phone,
        'address': address,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'maritalStatus': maritalStatus,
      };
}

class OtpVerifyRequest {
  final String email;
  final String otp;
  final String sessionToken;

  const OtpVerifyRequest({
    required this.email,
    required this.otp,
    required this.sessionToken,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'otp': otp,
        'sessionToken': sessionToken,
      };
}

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}