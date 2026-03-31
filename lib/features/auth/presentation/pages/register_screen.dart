import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/features/auth/data/models/auth_request.dart';
import 'package:secure_link/features/auth/domain/bloc/auth_bloc.dart';
import 'package:secure_link/features/auth/domain/bloc/auth_event.dart';
import 'package:secure_link/features/auth/domain/bloc/auth_state.dart';
import 'package:secure_link/features/auth/presentation/pages/otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();

  String _selectedGender = 'register.male';
  String _selectedMaritalStatus = '';
  String _fullPhone = ''; // numéro complet avec indicatif

  final List<String> _maritalStatusOptions = [
    'profile.single',
    'profile.married',
    'profile.divorced',
    'profile.widowed',
  ];

  static const Map<String, String> _genderMap = {
    'register.male': 'HOMME',
    'register.female': 'FEMME',
  };

  static const Map<String, String> _maritalMap = {
    'profile.single': 'CELIBATAIRE',
    'profile.married': 'MARIE',
    'profile.divorced': 'DIVORCE',
    'profile.widowed': 'VEUF',
  };


  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _onRegister(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          RegisterRequested(
            RegisterRequest(
              lastName: _lastNameController.text.trim(),
              firstName: _firstNameController.text.trim(),
              email: _emailController.text.trim(),
              phone: _fullPhone,
              address: 'Dakar',
              dateOfBirth: _birthDateController.text.trim(),
              gender: _genderMap[_selectedGender] ?? 'HOMME',
              maritalStatus: _maritalMap[_selectedMaritalStatus] ?? 'CELIBATAIRE',
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
          
            final authBloc = context.read<AuthBloc>();
            final email = state.email;
            final sessionToken = state.sessionToken;

            // 1. Afficher le modal de succès
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isDismissible: false,
              enableDrag: false,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => _RegisterSuccessBottomSheet(
                phone: _phoneController.text.trim(),
                dialCode: '',
              ),
            );

            // 2. Après 2 secondes → fermer modal + naviguer vers OTP
            Future.delayed(const Duration(seconds: 2), () {
              if (!context.mounted) return;
              Navigator.of(context).pop(); // ferme le modal
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: authBloc, 
                    child: OtpVerificationScreen(
                      email: email,
                      sessionToken: sessionToken,
                    ),
                  ),
                ),
              );
            });
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
                              border: Border.all(color: AppColors.borderLight),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: AppColors.textDark,
                              size: AppConstants.iconSizeMedium,
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/images/secureforms_logo.png',
                          height: 82,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),

                  // ── Formulaire ──
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.paddingLarge,
                        8,
                        AppConstants.paddingLarge,
                        AppConstants.paddingXLarge,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'register.title'.tr(),
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilySofiaSans,
                                fontSize: AppConstants.fontSizeTitle,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'register.subtitle'.tr(),
                              style: const TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontSize: AppConstants.fontSizeMedium,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingXLarge),

                            _FormField(
                              label: 'register.first_name'.tr(),
                              controller: _firstNameController,
                              hint: 'register.first_name_hint'.tr(),
                              prefixIcon: Icons.person_outline,
                              validator: (v) => v!.isEmpty ? 'login.required_field'.tr() : null,
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),

                            _FormField(
                              label: 'register.last_name'.tr(),
                              controller: _lastNameController,
                              hint: 'register.last_name_hint'.tr(),
                              prefixIcon: Icons.person_outline,
                              validator: (v) => v!.isEmpty ? 'login.required_field'.tr() : null,
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),

                            _IntlPhoneField(
                              controller: _phoneController,
                              onChanged: (phone) => _fullPhone = phone.completeNumber,
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),

                            _FormField(
                              label: 'login.email_label'.tr(),
                              controller: _emailController,
                              hint: 'login.email_hint'.tr(),
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v!.isEmpty) return 'login.required_field'.tr();
                                if (!v.contains('@')) return 'login.invalid_email'.tr();
                                return null;
                              },
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),

                            _DateField(
                              label: 'register.birth_date'.tr(),
                              controller: _birthDateController,
                              hint: 'register.birth_date_hint'.tr(),
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),

                            _GenderSelector(
                              selected: _selectedGender,
                              onChanged: (val) => setState(() => _selectedGender = val),
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),

                            _DropdownField(
                              label: 'register.marital_status'.tr(),
                              hint: 'register.select'.tr(),
                              value: _selectedMaritalStatus.isEmpty ? null : _selectedMaritalStatus,
                              items: _maritalStatusOptions,
                              onChanged: (val) => setState(() => _selectedMaritalStatus = val ?? ''),
                            ),
                            const SizedBox(height: 32),

                            SizedBox(
                              width: double.infinity,
                              height: AppConstants.logoutButtonHeight,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : () => _onRegister(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryDark,
                                  disabledBackgroundColor:
                                      AppColors.primaryDark.withValues(alpha: 0.6),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.white,
                                        ),
                                      )
                                    : Text(
                                        'register.register_button'.tr(),
                                        style: const TextStyle(
                                          fontFamily: AppConstants.fontFamilySofiaSans,
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: AppConstants.fontSizeLarge,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingXLarge),

                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'register.already_account'.tr(),
                                        style: const TextStyle(
                                          fontFamily: AppConstants.fontFamilyInter,
                                          fontSize: AppConstants.fontSizeMedium,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'register.login_link'.tr(),
                                        style: const TextStyle(
                                          fontFamily: AppConstants.fontFamilyInter,
                                          fontSize: AppConstants.fontSizeMedium,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

// ═════════════════════════════════════════════════════════════════
// WIDGETS PRIVÉS
// ═════════════════════════════════════════════════════════════════

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: AppConstants.fontFamilyInter,
        fontSize: AppConstants.fontSizeMedium,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontFamily: AppConstants.fontFamilyInter,
            fontSize: AppConstants.fontSizeMedium,
            color: AppColors.textDark,
          ),
          decoration: _inputDecoration(hint: hint, prefixIcon: prefixIcon),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: AppConstants.fontFamilyInter,
        color: AppColors.hintText,
        fontSize: AppConstants.fontSizeMedium,
      ),
      prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary, size: AppConstants.iconSizeMedium),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        borderSide: const BorderSide(color: AppColors.primary, width: AppConstants.borderWidthMedium),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        borderSide: const BorderSide(color: AppColors.statusRejected),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        borderSide: const BorderSide(color: AppColors.statusRejected),
      ),
    );
  }
}

class _IntlPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(dynamic phone) onChanged;

  const _IntlPhoneField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: 'register.phone'.tr()),
        const SizedBox(height: 6),
        IntlPhoneField(
          controller: controller,
          initialCountryCode: 'SN',
          onChanged: onChanged,
          style: const TextStyle(
            fontFamily: AppConstants.fontFamilyInter,
            fontSize: AppConstants.fontSizeMedium,
            color: AppColors.textDark,
          ),
          dropdownTextStyle: const TextStyle(
            fontFamily: AppConstants.fontFamilyInter,
            fontSize: AppConstants.fontSizeMedium,
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            hintText: '77 123 45 67',
            hintStyle: const TextStyle(
              fontFamily: AppConstants.fontFamilyInter,
              color: AppColors.hintText,
              fontSize: AppConstants.fontSizeMedium,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.primary, width: AppConstants.borderWidthMedium),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _DateField({required this.label, required this.hint, required this.controller});

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryDark,
            onPrimary: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      controller.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _pickDate(context),
          validator: (v) => v!.isEmpty ? 'login.required_field'.tr() : null,
          style: const TextStyle(
            fontFamily: AppConstants.fontFamilyInter,
            fontSize: AppConstants.fontSizeMedium,
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: AppConstants.fontFamilyInter,
              color: AppColors.hintText,
              fontSize: AppConstants.fontSizeMedium,
            ),
            suffixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: AppConstants.iconSizeMedium),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.primary, width: AppConstants.borderWidthMedium),
            ),
          ),
        ),
      ],
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _GenderSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: 'register.gender'.tr()),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _GenderOption(
                label: 'register.male'.tr(),
                isSelected: selected == 'register.male',
                onTap: () => onChanged('register.male'),
              ),
              _GenderOption(
                label: 'register.female'.tr(),
                isSelected: selected == 'register.female',
                onTap: () => onChanged('register.female'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            boxShadow: isSelected
                ? [const BoxShadow(color: AppColors.shadowLight, blurRadius: 4, offset: Offset(0, 2))]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppConstants.fontFamilySofiaSans,
              fontSize: AppConstants.fontSizeMedium,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.textDark : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint,
              style: const TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  color: AppColors.hintText,
                  fontSize: AppConstants.fontSizeMedium)),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.primary, width: AppConstants.borderWidthMedium),
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item.tr(),
                        style: const TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontSize: AppConstants.fontSizeMedium,
                            color: AppColors.textDark)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _RegisterSuccessBottomSheet extends StatelessWidget {
  final String phone;
  final String dialCode;

  const _RegisterSuccessBottomSheet({
    required this.phone,
    required this.dialCode,
  });

  String _maskedPhone(String phone) {
    final cleaned = phone.replaceAll(' ', '').trim();
    if (cleaned.length >= 4) {
      final start = cleaned.substring(0, 2);
      final end = cleaned.substring(cleaned.length - 2);
      return '$start ... $end';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppConstants.paddingLarge,
        right: AppConstants.paddingLarge,
        bottom: MediaQuery.of(context).padding.bottom + AppConstants.paddingLarge,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppConstants.successIconSize,
              height: AppConstants.successIconSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: AppConstants.borderWidthThick,
                ),
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.primary,
                size: AppConstants.iconSizeXLarge,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'register.account_created'.tr(),
              style: const TextStyle(
                fontFamily: AppConstants.fontFamilySofiaSans,
                fontSize: AppConstants.fontSizeXLarge,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${'register.code_sent_to'.tr()} $dialCode ${_maskedPhone(phone)}',
              style: const TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontSize: AppConstants.fontSizeMedium,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}