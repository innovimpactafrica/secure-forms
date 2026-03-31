import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/features/auth/data/services/auth_service.dart';
import 'package:secure_link/features/auth/presentation/pages/email_sent_screen.dart';

class ResumeRegistrationOtpScreen extends StatefulWidget {
  final String email;
  const ResumeRegistrationOtpScreen({super.key, required this.email});

  @override
  State<ResumeRegistrationOtpScreen> createState() =>
      _ResumeRegistrationOtpScreenState();
}

class _ResumeRegistrationOtpScreenState
    extends State<ResumeRegistrationOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final _service = AuthService();

  int _secondsRemaining = 49;
  Timer? _timer;
  bool _canResend = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _canResend = false;
      _secondsRemaining = 49;
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
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  String _maskedEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final visible = name.length > 4 ? name.substring(0, 4) : name;
    return '$visible...@${parts[1]}';
  }

  Future<void> _onVerify() async {
    if (_otpCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('otp.enter_4_digits'.tr()),
          backgroundColor: AppColors.statusRejected,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _service.resumeSetupVerifyOtp(
        email: widget.email,
        otp: _otpCode,
      );
      if (!mounted) return;
      // Succès → lien envoyé par email → afficher l'écran de confirmation
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const EmailSentScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.statusRejected,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onResend() async {
    if (!_canResend) return;
    try {
      await _service.resumeSetupRequestOtp(email: widget.email);
      _startTimer();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('otp.code_resent'.tr()),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.statusRejected,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                padding: EdgeInsets.fromLTRB(
                  AppConstants.paddingLarge,
                  AppConstants.paddingLarge,
                  AppConstants.paddingLarge,
                  MediaQuery.of(context).viewInsets.bottom +
                      MediaQuery.of(context).padding.bottom +
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
                    const SizedBox(height: 24),

                    // Timer
                    if (!_canResend)
                      Center(
                        child: Text(
                          '${'otp.resend_in'.tr()}${_secondsRemaining.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontSize: AppConstants.fontSizeMedium,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),

                    // Renvoi
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
                            onTap: _canResend ? _onResend : null,
                            child: Text(
                              'otp.resend'.tr(),
                              style: TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                fontWeight: FontWeight.w500,
                                color: _canResend
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Bouton Vérifier
                    SizedBox(
                      width: double.infinity,
                      height: AppConstants.logoutButtonHeight,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onVerify,
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
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.white),
                              )
                            : Text(
                                'otp.verify_button'.tr(),
                                style: const TextStyle(
                                  fontFamily: AppConstants.fontFamilySofiaSans,
                                  color: AppColors.white,
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
  }
}

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
