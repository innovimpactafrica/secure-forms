import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';
import 'package:quick_forms/features/auth/domain/bloc/auth_bloc.dart';
import 'package:quick_forms/features/auth/domain/bloc/auth_event.dart';
import 'package:quick_forms/features/auth/domain/bloc/auth_state.dart';
import 'package:quick_forms/features/auth/presentation/pages/email_sent_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String sessionToken;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.sessionToken,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _secondsRemaining = 29;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _canResend = false;
      _secondsRemaining = 29;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _maskedEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final visible = name.length > 4 ? name.substring(0, 4) : name;
    return '$visible...@${parts[1]}';
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onVerify(BuildContext context) {
    if (_otpCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('otp.enter_4_digits'.tr()),
          backgroundColor: AppColors.statusRejected,
        ),
      );
      return;
    }
    context.read<AuthBloc>().add(
          OtpVerifyRequested(
            email: widget.email,
            otp: _otpCode,
            sessionToken: widget.sessionToken,
          ),
        );
  }

  void _onResend(BuildContext context) {
    if (!_canResend) return;
    context.read<AuthBloc>().add(ResendOtpRequested(email: widget.email));
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpVerifySuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const EmailSentScreen()),
            (route) => false,
          );
        } else if (state is OtpResendSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('otp.code_resent'.tr()),
              backgroundColor: AppColors.primary,
            ),
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.statusRejected,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.white,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ──
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
                            border: Border.all(
                                color: AppColors.backCircleColor, width: 1.26),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: AppColors.backArrowColor, size: 20.6),
                        ),
                      ),
                      Image.asset('assets/images/qfwithtext.png',
                          height: 82, fit: BoxFit.contain),
                    ],
                  ),
                ),

                // ── Contenu scrollable ──
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.paddingLarge,
                      AppConstants.paddingLarge,
                      AppConstants.paddingLarge,
                      AppConstants.paddingXLarge,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'otp.verification_code'.tr(),
                          style: const TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontSize: AppConstants.fontSizeTitle,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'otp.enter_code_sent'.tr(),
                                style: const TextStyle(
                                  fontFamily: AppConstants.fontFamilyInter,
                                  fontSize: AppConstants.fontSizeMedium,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextSpan(
                                text: _maskedEmail(widget.email),
                                style: const TextStyle(
                                  fontFamily: AppConstants.fontFamilyInter,
                                  fontSize: AppConstants.fontSizeMedium,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ── Cases OTP ──
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
                        const SizedBox(height: 32),

                        // ── Renvoi ──
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'otp.didnt_receive'.tr(),
                                style: const TextStyle(
                                  fontFamily: AppConstants.fontFamilyInter,
                                  fontSize: AppConstants.fontSizeMedium,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: _canResend
                                    ? () => _onResend(context)
                                    : null,
                                child: Text(
                                  _canResend
                                      ? 'otp.resend'.tr()
                                      : '${'otp.resend_in'.tr()}${_secondsRemaining.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamilyInter,
                                    fontSize: AppConstants.fontSizeMedium,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.otpResendTimer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ── Bouton Vérifier ──
                        SizedBox(
                          width: double.infinity,
                          height: AppConstants.logoutButtonHeight,
                          child: ElevatedButton(
                            onPressed:
                                isLoading ? null : () => _onVerify(context),
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
                                        strokeWidth: 2, color: AppColors.white),
                                  )
                                : Text(
                                    'otp.verify_button'.tr(),
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
                        SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// CASE OTP
// ═════════════════════════════════════════════════════════════════
class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = widget.focusNode.hasFocus;

    return Container(
      width: AppConstants.otpBoxSize,
      height: AppConstants.otpBoxSize,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        onChanged: widget.onChanged,
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
          fillColor:
              isFocused ? AppColors.otpActiveFill : AppColors.otpEmptyFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: AppColors.otpActiveBorder, width: 1),
          ),
        ),
      ),
    );
  }
}
