import 'package:equatable/equatable.dart';
import '../../data/models/auth_request.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RegisterRequested extends AuthEvent {
  final RegisterRequest request;
  RegisterRequested(this.request);
  @override
  List<Object?> get props => [request];
}

class LoginRequested extends AuthEvent {
  final String? email;
  final String? phone;
  final String password;
  LoginRequested({this.email, this.phone, required this.password});
  @override
  List<Object?> get props => [email, phone, password];
}

class OtpVerifyRequested extends AuthEvent {
  final String email;
  final String otp;
  final String sessionToken;
  OtpVerifyRequested({
    required this.email,
    required this.otp,
    required this.sessionToken,
  });
  @override
  List<Object?> get props => [email, otp, sessionToken];
}

class ResendOtpRequested extends AuthEvent {
  final String email;
  ResendOtpRequested({required this.email});
  @override
  List<Object?> get props => [email];
}

class SetupPasswordRequested extends AuthEvent {
  final String token;
  final String password;
  final String confirmPassword;
  SetupPasswordRequested({
    required this.token,
    required this.password,
    required this.confirmPassword,
  });
  @override
  List<Object?> get props => [token, password, confirmPassword];
}
