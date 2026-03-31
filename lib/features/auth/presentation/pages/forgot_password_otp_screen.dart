import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/features/auth/domain/bloc/forgot_password_bloc.dart';
import 'package:secure_link/features/auth/domain/bloc/forgot_password_event.dart';
import 'package:secure_link/features/auth/domain/bloc/forgot_password_state.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final String email;
  const ForgotPasswordOtpScreen({super.key, required this.email});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  late final ForgotPasswordBloc _bloc;

  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _bloc = ForgotPasswordBloc();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _canResend = false;
      _secondsRemaining = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        if (mounted) setState(() => _canResend = true);
      } else {
        if (mounted) setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _timer?.cancel();
    _bloc.close();
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  String _formatTimer() {
    final m = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onVerify() {
    if (_otpCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('forgot_password.enter_4_digits'.tr()),
        backgroundColor: AppColors.statusRejected,
      ));
      return;
    }
    // Navigation directe vers reset password — l'OTP sera validé côté reset
    Navigator.of(context).pushNamed(
      AppRoutes.resetPassword,
      arguments: {'email': widget.email, 'otp': _otpCode},
    );
  }

  void _onResend() {
    if (!_canResend) return;
    setState(() => _errorMessage = null);
    _bloc.add(ForgotPasswordResendOtpEvent(widget.email));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordOtpResent) {
            _startTimer();
            setState(() => _errorMessage = null);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('forgot_password.resend_available'.tr()),
              backgroundColor: AppColors.primary,
            ));
          } else if (state is ForgotPasswordError) {
            setState(() => _errorMessage = state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is ForgotPasswordLoading;
          return Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingLarge,
                      vertical: AppConstants.paddingLarge,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: AppConstants.avatarSizeSmall,
                            height: AppConstants.avatarSizeSmall,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.borderLight),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: AppColors.textDark,
                                size: AppConstants.iconSizeMedium),
                          ),
                        ),
                        Image.asset('assets/images/secureforms_logo.png',
                            height: 82, fit: BoxFit.contain),
                      ],
                    ),
                  ),

                  // Contenu
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.paddingLarge,
                        AppConstants.paddingLarge,
                        AppConstants.paddingLarge,
                        AppConstants.paddingXLarge,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'forgot_password.otp_title'.tr(),
                            style: const TextStyle(
                              fontFamily: AppConstants.fontFamilySofiaSans,
                              fontSize: AppConstants.fontSizeTitle,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'forgot_password.otp_subtitle'.tr(),
                            style: const TextStyle(
                              fontFamily: AppConstants.fontFamilyInter,
                              fontSize: AppConstants.fontSizeMedium,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'forgot_password.otp_sent_info'.tr(),
                            style: const TextStyle(
                              fontFamily: AppConstants.fontFamilyInter,
                              fontSize: AppConstants.fontSizeRegular,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Cases OTP
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(4, (index) {
                              return _OtpBox(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 3) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                  setState(() {});
                                },
                              );
                            }),
                          ),
                          const SizedBox(height: 16),

                          // Timer ou "peut renvoyer"
                          if (!_canResend)
                            Text(
                              '${'forgot_password.resend_in'.tr()}${_formatTimer()}',
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            )
                          else
                            Text(
                              'forgot_password.resend_available'.tr(),
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                color: AppColors.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),

                          // Message d'erreur
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeRegular,
                                color: AppColors.statusRejected,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],

                          const SizedBox(height: 32),

                          // Bouton Vérifier
                          SizedBox(
                            width: double.infinity,
                            height: AppConstants.logoutButtonHeight,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _onVerify,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDark,
                                disabledBackgroundColor:
                                    AppColors.primaryDark.withValues(alpha: 0.6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.radiusRound),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.white),
                                    )
                                  : Text(
                                      'forgot_password.verify_button'.tr(),
                                      style: const TextStyle(
                                        fontFamily:
                                            AppConstants.fontFamilySofiaSans,
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: AppConstants.fontSizeLarge,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Annuler
                          GestureDetector(
                            onTap: () => Navigator.of(context)
                                .pushNamedAndRemoveUntil(
                                    AppRoutes.login, (route) => false),
                            child: Text(
                              'forgot_password.cancel'.tr(),
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Pas reçu de code ?
                          Text(
                            'forgot_password.no_code'.tr(),
                            style: const TextStyle(
                              fontFamily: AppConstants.fontFamilyInter,
                              fontSize: AppConstants.fontSizeMedium,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Bouton Renvoyer
                          SizedBox(
                            width: double.infinity,
                            height: AppConstants.logoutButtonHeight,
                            child: ElevatedButton(
                              onPressed: (_canResend && !isLoading)
                                  ? _onResend
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _canResend
                                    ? AppColors.primary
                                    : AppColors.borderLight,
                                disabledBackgroundColor: AppColors.borderLight,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.radiusRound),
                                ),
                              ),
                              child: Text(
                                'forgot_password.resend_button'.tr(),
                                style: TextStyle(
                                  fontFamily: AppConstants.fontFamilySofiaSans,
                                  color: _canResend
                                      ? AppColors.white
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppConstants.fontSizeLarge,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// CASE OTP
// ═══════════════════════════════════════════════
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isFilled = controller.text.isNotEmpty;
    return Container(
      width: AppConstants.otpBoxSize,
      height: AppConstants.otpBoxSize,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        onChanged: onChanged,
        style: const TextStyle(
          fontFamily: AppConstants.fontFamilySofiaSans,
          fontSize: AppConstants.fontSizeXXLarge,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            borderSide: BorderSide(
              color: isFilled ? AppColors.primary : AppColors.borderLight,
              width: isFilled
                  ? AppConstants.borderWidthMedium
                  : AppConstants.borderWidthThin,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            borderSide: BorderSide(
              color: isFilled ? AppColors.primary : AppColors.borderLight,
              width: isFilled
                  ? AppConstants.borderWidthMedium
                  : AppConstants.borderWidthThin,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            borderSide: const BorderSide(
                color: AppColors.primary,
                width: AppConstants.borderWidthMedium),
          ),
        ),
      ),
    );
  }
}
