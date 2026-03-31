import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/features/auth/data/services/forgot_password_service.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ForgotPasswordService _service;

  ForgotPasswordBloc({ForgotPasswordService? service})
      : _service = service ?? ForgotPasswordService(),
        super(const ForgotPasswordInitial()) {
    on<ForgotPasswordRequestOtpEvent>(_onRequestOtp);
    on<ForgotPasswordResendOtpEvent>(_onResendOtp);
    on<ForgotPasswordResetEvent>(_onReset);
  }

  Future<void> _onRequestOtp(
    ForgotPasswordRequestOtpEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    try {
      await _service.requestOtp(email: event.email);
      emit(const ForgotPasswordOtpSent());
    } catch (e) {
      emit(ForgotPasswordError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onResendOtp(
    ForgotPasswordResendOtpEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    try {
      await _service.resendOtp(email: event.email);
      emit(const ForgotPasswordOtpResent());
    } catch (e) {
      emit(ForgotPasswordError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onReset(
    ForgotPasswordResetEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    try {
      await _service.resetPassword(
        email: event.email,
        otp: event.otp,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );
      emit(const ForgotPasswordResetSuccess());
    } catch (e) {
      emit(ForgotPasswordError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
