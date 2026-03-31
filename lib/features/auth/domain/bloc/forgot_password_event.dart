abstract class ForgotPasswordEvent {
  const ForgotPasswordEvent();
}

class ForgotPasswordRequestOtpEvent extends ForgotPasswordEvent {
  final String email;
  const ForgotPasswordRequestOtpEvent(this.email);
}

class ForgotPasswordResendOtpEvent extends ForgotPasswordEvent {
  final String email;
  const ForgotPasswordResendOtpEvent(this.email);
}

class ForgotPasswordResetEvent extends ForgotPasswordEvent {
  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;
  const ForgotPasswordResetEvent({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });
}
