import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/auth_request.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc({AuthRepository? repository})
      : _repository = repository ?? AuthRepository(),
        super(AuthInitial()) {
    on<RegisterRequested>(_onRegisterRequested);
    on<LoginRequested>(_onLoginRequested);
    on<OtpVerifyRequested>(_onOtpVerifyRequested);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<SetupPasswordRequested>(_onSetupPasswordRequested);
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _repository.register(event.request);
      emit(RegisterSuccess(email: event.request.email, sessionToken: response.sessionToken));
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _repository.login(email: event.email, password: event.password);
      emit(LoginSuccess(
        accessToken: response.accessToken,
        firstName: response.firstName,
        lastName: response.lastName,
      ));
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onOtpVerifyRequested(OtpVerifyRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _repository.verifyOtp(OtpVerifyRequest(
        email: event.email,
        otp: event.otp,
        sessionToken: event.sessionToken,
      ));
      emit(OtpVerifySuccess(
        email: response.email.isNotEmpty ? response.email : event.email,
        message: response.message,
      ));
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onResendOtpRequested(ResendOtpRequested event, Emitter<AuthState> emit) async {
    try {
      await _repository.resendOtp(email: event.email);
      emit(OtpResendSuccess());
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSetupPasswordRequested(SetupPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _repository.setupPassword(
        token: event.token,
        password: event.password,
        confirmPassword: event.confirmPassword,
      );
      emit(PasswordSetupSuccess());
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}