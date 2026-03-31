abstract class ForgotPasswordState {
  const ForgotPasswordState();
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

class ForgotPasswordOtpSent extends ForgotPasswordState {
  const ForgotPasswordOtpSent();
}

class ForgotPasswordOtpResent extends ForgotPasswordState {
  const ForgotPasswordOtpResent();
}

class ForgotPasswordResetSuccess extends ForgotPasswordState {
  const ForgotPasswordResetSuccess();
}

class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  const ForgotPasswordError(this.message);
}
