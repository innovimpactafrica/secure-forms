import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/features/client/domain/bloc/profile_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/profile_event.dart';
import 'package:secure_link/features/client/domain/bloc/profile_state.dart';
import 'step2_documents_screen.dart';

/// Étape 1 — Informations personnelles
/// Jauge : 30% → 50% après validation
/// TODO: préremplir les champs depuis l'API quand les endpoints seront disponibles
class Step1InformationsScreen extends StatefulWidget {
  const Step1InformationsScreen({super.key});

  @override
  State<Step1InformationsScreen> createState() =>
      _Step1InformationsScreenState();
}

class _Step1InformationsScreenState extends State<Step1InformationsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();

  String _selectedGender = 'Homme';
  String _selectedMaritalStatus = '';

  final List<String> _maritalStatusOptions = [
    'Célibataire',
    'Marié(e)',
    'Divorcé(e)',
    'Veuf/Veuve',
  ];

  @override
  void initState() {
    super.initState();
    // Préremplir si des données existent déjà dans le BLoC
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileInProgress) {
      final profile = state.profile;
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _phoneController.text = profile.phone;
      _emailController.text = profile.email;
      _birthDateController.text = profile.birthDate;
      _selectedGender = profile.gender.isNotEmpty ? profile.gender : 'Homme';
      _selectedMaritalStatus = profile.maritalStatus;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _onValider() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
            SavePersonalInfoEvent(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phone: _phoneController.text.trim(),
              email: _emailController.text.trim(),
              birthDate: _birthDateController.text.trim(),
              gender: _selectedGender,
              maritalStatus: _selectedMaritalStatus,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileStep1Validated) {
          // Naviguer vers l'étape 2
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ProfileBloc>(),
                child: const Step2DocumentsScreen(),
              ),
            ),
          );
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.statusRejected,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header avec jauge ──
              _CompleteProfileHeader(
                progressValue: 0.30,
                progressLabel: '30%',
                subtitle: 'Lamine Diop',
              ),
              // ── Formulaire scrollable ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre section
                        Text(
                          'Informations personnelles',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontSize: AppConstants.fontSizeXXLarge,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ces informations facilitent la vérification.',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontSize: AppConstants.fontSizeMedium,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Prénom
                        _FormField(
                          label: 'Prénom',
                          controller: _firstNameController,
                          hint: 'Lamine',
                          prefixIcon: Icons.person_outline,
                          validator: (v) =>
                              v!.isEmpty ? 'Champ obligatoire' : null,
                        ),
                        const SizedBox(height: 16),

                        // Nom
                        _FormField(
                          label: 'Nom',
                          controller: _lastNameController,
                          hint: 'Dieme',
                          prefixIcon: Icons.person_outline,
                          validator: (v) =>
                              v!.isEmpty ? 'Champ obligatoire' : null,
                        ),
                        const SizedBox(height: 16),

                        // Téléphone
                        _PhoneField(controller: _phoneController),
                        const SizedBox(height: 16),

                        // Email
                        _FormField(
                          label: 'Email',
                          controller: _emailController,
                          hint: 'Ex: aminadiallo@gmail.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v!.isEmpty) return 'Champ obligatoire';
                            if (!v.contains('@')) return 'Email invalide';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date de naissance
                        _DateField(
                          label: 'Date de naissance',
                          controller: _birthDateController,
                          hint: 'jj/mm/aaaa',
                        ),
                        const SizedBox(height: 16),

                        // Genre
                        _GenderSelector(
                          selected: _selectedGender,
                          onChanged: (val) =>
                              setState(() => _selectedGender = val),
                        ),
                        const SizedBox(height: 16),

                        // Situation matrimoniale
                        _DropdownField(
                          label: 'Situation matrimoniale',
                          hint: 'Ex: aminadiallo@gmail.com',
                          value: _selectedMaritalStatus.isEmpty
                              ? null
                              : _selectedMaritalStatus,
                          items: _maritalStatusOptions,
                          onChanged: (val) =>
                              setState(() => _selectedMaritalStatus = val ?? ''),
                        ),
                        const SizedBox(height: 32),

                        // Bouton Valider
                        BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            final isLoading = state is ProfileLoading;
                            return SizedBox(
                              width: double.infinity,
                              height: AppConstants.logoutButtonHeight,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _onValider,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryDark,
                                  disabledBackgroundColor:
                                      AppColors.primaryDark.withValues(alpha: 0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.radiusRound),
                                  ),
                                  elevation: 0,
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.white,
                                        ),
                                      )
                                    : Text(
                                        'Valider',
                                        style: TextStyle(
                                          fontFamily:
                                              AppConstants.fontFamilySofiaSans,
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: AppConstants.fontSizeLarge,
                                        ),
                                      ),
                              ),
                            );
                          },
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HEADER COMMUN aux 2 étapes
// ─────────────────────────────────────────────────────────────────
class _CompleteProfileHeader extends StatelessWidget {
  final double progressValue;
  final String progressLabel;
  final String subtitle;

  const _CompleteProfileHeader({
    required this.progressValue,
    required this.progressLabel,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complétez votre profil',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamilySofiaSans,
                      fontWeight: FontWeight.w700,
                      fontSize: AppConstants.fontSizeXXLarge,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamilyInter,
                      fontSize: AppConstants.fontSizeRegular,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barre de progression
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.progressTrack,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progressValue,
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          // % aligné à droite
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              progressLabel,
              style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontSize: AppConstants.fontSizeRegular,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CHAMP TEXTE GÉNÉRIQUE
// ─────────────────────────────────────────────────────────────────
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
        Text(
          label,
          style: TextStyle(
            fontFamily: AppConstants.fontFamilyInter,
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            fontFamily: AppConstants.fontFamilyInter,
            fontSize: AppConstants.fontSizeMedium,
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: AppConstants.fontFamilyInter,
              color: AppColors.hintText,
              fontSize: AppConstants.fontSizeMedium,
            ),
            prefixIcon: Icon(prefixIcon,
                color: AppColors.textSecondary, size: AppConstants.iconSizeMedium),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: BorderSide(color: AppColors.statusRejected),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CHAMP TÉLÉPHONE avec indicatif pays
// ─────────────────────────────────────────────────────────────────
class _PhoneField extends StatelessWidget {
  final TextEditingController controller;

  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Téléphone',
          style: TextStyle(
            fontFamily: AppConstants.fontFamilyInter,
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          validator: (v) => v!.isEmpty ? 'Champ obligatoire' : null,
          style: TextStyle(
            fontFamily: AppConstants.fontFamilyInter,
            fontSize: AppConstants.fontSizeMedium,
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            hintText: '+221 77 123 45 67',
            hintStyle: TextStyle(
              fontFamily: AppConstants.fontFamilyInter,
              color: AppColors.hintText,
              fontSize: AppConstants.fontSizeMedium,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drapeau Sénégal
                  Text('🇸🇳', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 4),
                  Container(width: 1, height: 20, color: AppColors.borderLight),
                ],
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CHAMP DATE avec sélecteur calendrier
// ─────────────────────────────────────────────────────────────────
class _DateField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _DateField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
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
        Text(
          label,
          style: TextStyle(
            fontFamily: AppConstants.fontFamilyInter,
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _pickDate(context),
          validator: (v) => v!.isEmpty ? 'Champ obligatoire' : null,
          style: TextStyle(
            fontFamily: AppConstants.fontFamilyInter,
            fontSize: AppConstants.fontSizeMedium,
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: AppConstants.fontFamilyInter,
              color: AppColors.hintText,
              fontSize: AppConstants.fontSizeMedium,
            ),
            suffixIcon: Icon(Icons.calendar_today_outlined,
                color: AppColors.textSecondary, size: AppConstants.iconSizeMedium),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SÉLECTEUR GENRE
// ─────────────────────────────────────────────────────────────────
class _GenderSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _GenderSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genre',
          style: TextStyle(
            fontFamily: AppConstants.fontFamilyInter,
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
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
                label: 'Homme',
                isSelected: selected == 'Homme',
                onTap: () => onChanged('Homme'),
              ),
              _GenderOption(
                label: 'Femme',
                isSelected: selected == 'Femme',
                onTap: () => onChanged('Femme'),
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

  const _GenderOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

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
                ? [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppConstants.fontFamilySofiaSans,
              fontSize: AppConstants.fontSizeMedium,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.textDark : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// DROPDOWN GÉNÉRIQUE
// ─────────────────────────────────────────────────────────────────
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
        Text(
          label,
          style: TextStyle(
            fontFamily: AppConstants.fontFamilyInter,
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              fontFamily: AppConstants.fontFamilyInter,
              color: AppColors.hintText,
              fontSize: AppConstants.fontSizeMedium,
            ),
          ),
          icon: Icon(Icons.keyboard_arrow_down,
              color: AppColors.textSecondary),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamilyInter,
                      fontSize: AppConstants.fontSizeMedium,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}