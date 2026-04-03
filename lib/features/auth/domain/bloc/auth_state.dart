import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

class RegisterSuccess extends AuthState {
  final String email;
  final String sessionToken;
  RegisterSuccess({required this.email, required this.sessionToken});
  @override
  List<Object?> get props => [email, sessionToken];
}

class OtpVerifySuccess extends AuthState {
  final String email;
  final String message;
  OtpVerifySuccess({required this.email, required this.message});
  @override
  List<Object?> get props => [email, message];
}

class OtpResendSuccess extends AuthState {}

// Mot de passe créé avec succès
class PasswordSetupSuccess extends AuthState {}

// Connexion réussie
class LoginSuccess extends AuthState {
  final String accessToken;
  final String refreshToken;
  final String firstName;
  final String lastName;
  LoginSuccess({
    required this.accessToken,
    required this.refreshToken,
    required this.firstName,
    required this.lastName,
  });
  @override
  List<Object?> get props => [accessToken, refreshToken, firstName, lastName];
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure({required this.message});
  @override
  List<Object?> get props => [message];
}

// Inscription partielle — l'utilisateur n'a pas encore créé son mot de passe
class LoginIncomplete extends AuthState {
  final String email;
  LoginIncomplete({required this.email});
  @override
  List<Object?> get props => [email];
}