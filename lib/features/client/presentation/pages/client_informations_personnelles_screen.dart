import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/auth/domain/bloc/user_bloc.dart';
import 'package:secure_link/features/auth/domain/bloc/user_event.dart';
import 'package:secure_link/features/auth/domain/bloc/user_state.dart';

class ClientInformationsPersonnellesScreen extends StatefulWidget {
  const ClientInformationsPersonnellesScreen({super.key});

  @override
  State<ClientInformationsPersonnellesScreen> createState() =>
      _ClientInformationsPersonnellesScreenState();
}

class _ClientInformationsPersonnellesScreenState
    extends State<ClientInformationsPersonnellesScreen> {
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateNaissanceController =
      TextEditingController();

  late String _selectedGender;
  String? _selectedSituation;
  File? _localPicture;
  Uint8List? _pictureBytes;
  String _fullPhone = '';

  @override
  void initState() {
    _selectedGender = 'profile.male'.tr();
    super.initState();
    final bloc = context.read<UserBloc>();
    // Pré-remplir : priorité cachedUser, sinon UserLoaded
    final user = bloc.cachedUser ??
        (bloc.state is UserLoaded ? (bloc.state as UserLoaded).user : null);
    // ignore: avoid_print
    print(
        '[InfosPerso] initState — cachedUser=${bloc.cachedUser?.firstName} state=${bloc.state.runtimeType}');
    // ignore: avoid_print
    print(
        '[InfosPerso] user trouvé: firstName=${user?.firstName} lastName=${user?.lastName} email=${user?.email} phone=${user?.phone}');
    if (user != null) {
      _prenomController.text = user.firstName;
      _nomController.text = user.lastName;
      _emailController.text = user.email;
      _fullPhone = user.phone;
      // Extraire seulement le numéro local sans l'indicatif pour IntlPhoneField
      final localNumber = _extractLocalNumber(user.phone);
      _telephoneController.text = localNumber;
      // Date de naissance
      if (user.dateOfBirth.isNotEmpty) {
        final dt = DateTime.tryParse(user.dateOfBirth);
        if (dt != null) {
          _dateNaissanceController.text =
              '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
        }
      }
      // Situation matrimoniale
      if (user.maritalStatus.isNotEmpty) {
        _selectedSituation = _maritalStatusToLabel(user.maritalStatus);
      }
      // Genre
      if (user.gender.isNotEmpty) {
        _selectedGender = _genderToLabel(user.gender);
      }
    } else {
      // ignore: avoid_print
      print('[InfosPerso] Aucun user en cache → rechargement profil');
      bloc.add(LoadUserProfile(UserSession.instance.accessToken));
    }
    // Photo de profil
    _pictureBytes = bloc.profilePictureBytes;
    // ignore: avoid_print
    print(
        '[InfosPerso] profilePictureBytes en cache: ${_pictureBytes != null ? "${_pictureBytes!.length} bytes" : "null"}');
    if (_pictureBytes == null) {
      bloc.add(LoadProfilePictureEvent(UserSession.instance.accessToken));
    }
  }

  List<String> get _situationsMatrimoniales => [
        'profile.single'.tr(),
        'profile.married'.tr(),
        'profile.divorced'.tr(),
        'profile.widowed'.tr(),
      ];

  /// Convertit la valeur API (ex: "CELIBATAIRE") en label traduit
  String? _maritalStatusToLabel(String apiValue) {
    switch (apiValue.toUpperCase()) {
      case 'CELIBATAIRE': return 'profile.single'.tr();
      case 'MARIE':       return 'profile.married'.tr();
      case 'DIVORCE':     return 'profile.divorced'.tr();
      case 'VEUF':        return 'profile.widowed'.tr();
      default:            return null;
    }
  }

  String _genderToLabel(String apiValue) {
    switch (apiValue.toUpperCase()) {
      case 'FEMME': return 'profile.female'.tr();
      default:      return 'profile.male'.tr();
    }
  }

  /// Retire l'indicatif du numéro complet pour n'avoir que le numéro local
  /// Ex: "+221779947443" -> "779947443"
  String _extractLocalNumber(String fullPhone) {
    if (fullPhone.isEmpty) return '';
    // Liste des indicatifs courants triés par longueur décroissante
    const dialCodes = [
      '+1', '+7', '+20', '+27', '+30', '+31', '+32', '+33', '+34', '+36',
      '+39', '+40', '+41', '+43', '+44', '+45', '+46', '+47', '+48', '+49',
      '+51', '+52', '+53', '+54', '+55', '+56', '+57', '+58', '+60', '+61',
      '+62', '+63', '+64', '+65', '+66', '+81', '+82', '+84', '+86', '+90',
      '+91', '+92', '+93', '+94', '+95', '+98', '+212', '+213', '+216',
      '+218', '+220', '+221', '+222', '+223', '+224', '+225', '+226', '+227',
      '+228', '+229', '+230', '+231', '+232', '+233', '+234', '+235', '+236',
      '+237', '+238', '+239', '+240', '+241', '+242', '+243', '+244', '+245',
      '+246', '+247', '+248', '+249', '+250', '+251', '+252', '+253', '+254',
      '+255', '+256', '+257', '+258', '+260', '+261', '+262', '+263', '+264',
      '+265', '+266', '+267', '+268', '+269',
    ];
    // Trier par longueur décroissante pour matcher le plus long en premier
    final sorted = [...dialCodes]..sort((a, b) => b.length.compareTo(a.length));
    for (final code in sorted) {
      if (fullPhone.startsWith(code)) {
        return fullPhone.substring(code.length);
      }
    }
    return fullPhone;
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _dateNaissanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserProfilePictureLoaded) {
          setState(() => _pictureBytes = state.bytes);
        } else if (state is UserProfilePictureUpdated) {
          setState(() {
            _pictureBytes = state.bytes;
            _localPicture = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'profile.photo_updated'.tr(),
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  color: AppColors.white,
                ),
              ),
              backgroundColor: AppColors.statusValideGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else if (state is UserLoaded) {
          // ignore: avoid_print
          print(
              '[InfosPerso] UserLoaded reçu → firstName=${state.user.firstName} lastName=${state.user.lastName}');
          final user = state.user;
          setState(() {
            if (_prenomController.text.isEmpty)
              _prenomController.text = user.firstName;
            if (_nomController.text.isEmpty)
              _nomController.text = user.lastName;
            if (_emailController.text.isEmpty)
              _emailController.text = user.email;
            if (_telephoneController.text.isEmpty) {
              _fullPhone = user.phone;
              _telephoneController.text = _extractLocalNumber(user.phone);
            }
            if (_dateNaissanceController.text.isEmpty && user.dateOfBirth.isNotEmpty) {
              final dt = DateTime.tryParse(user.dateOfBirth);
              if (dt != null) {
                _dateNaissanceController.text =
                    '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
              }
            }
            if (_selectedSituation == null && user.maritalStatus.isNotEmpty) {
              _selectedSituation = _maritalStatusToLabel(user.maritalStatus);
            }
            if (user.gender.isNotEmpty) {
              _selectedGender = _genderToLabel(user.gender);
            }
          });
        } else if (state is UserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  color: AppColors.white,
                ),
              ),
              backgroundColor: AppColors.statusRejected,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      _buildAvatarSection(context),
                      _buildForm(),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Avatar Section
  // -------------------------------------------------------------------------

  Widget _buildAvatarSection(BuildContext context) {
    final bloc = context.read<UserBloc>();
    final initials = bloc.cachedUser?.initials ??
        (bloc.state is UserLoaded
            ? (bloc.state as UserLoaded).user.initials
            : '??');

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Stack(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderLight, width: 2),
              ),
              child: ClipOval(
                child: _localPicture != null
                    ? Image.file(_localPicture!, fit: BoxFit.cover)
                    : _pictureBytes != null
                        ? Image.memory(_pictureBytes!, fit: BoxFit.cover)
                        : Center(
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontFamily: AppConstants.fontFamilySofiaSans,
                                fontWeight: FontWeight.w700,
                                fontSize: 30,
                                color: AppColors.white,
                              ),
                            ),
                          ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _pickProfilePicture(context),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickProfilePicture(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading:
                  Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: Text('profile.gallery'.tr(),
                  style: TextStyle(
                      fontFamily: AppConstants.fontFamilyInter,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading:
                  Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              title: Text('profile.take_photo'.tr(),
                  style: TextStyle(
                      fontFamily: AppConstants.fontFamilyInter,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked =
        await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    final file = File(picked.path);
    setState(() => _localPicture = file);
    // ignore: use_build_context_synchronously
    context.read<UserBloc>().add(
          UpdateProfilePictureEvent(
            accessToken: UserSession.instance.accessToken,
            file: file,
          ),
        );
  }

  // -------------------------------------------------------------------------
  // Header
  // -------------------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back,
                  color: AppColors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'profil.my_account'.tr(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'profil.personal_info'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Form
  // -------------------------------------------------------------------------

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prénom
          _buildLabel('profile.first_name'.tr()),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _prenomController,
            hint: 'profile.first_name_hint'.tr(),
            prefixIcon: 'assets/icons/bi_person.svg',
          ),
          const SizedBox(height: 20),

          // Nom
          _buildLabel('profile.last_name'.tr()),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _nomController,
            hint: 'profile.last_name_hint'.tr(),
            prefixIcon: 'assets/icons/bi_person.svg',
          ),
          const SizedBox(height: 20),

          // Téléphone
          _buildLabel('profile.phone'.tr()),
          const SizedBox(height: 8),
          _buildPhoneField(),
          const SizedBox(height: 20),

          // Email
          _buildLabel('profile.email'.tr()),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _emailController,
            hint: 'profile.email_hint'.tr(),
            prefixIcon: 'assets/icons/bi_envelope.svg',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),

          // Date de naissance
          _buildLabel('profile.birth_date'.tr()),
          const SizedBox(height: 8),
          _buildDateField(),
          const SizedBox(height: 20),

          // Genre
          _buildLabel('profile.gender'.tr()),
          const SizedBox(height: 8),
          _buildGenderToggle(),
          const SizedBox(height: 20),

          // Situation matrimoniale
          _buildLabel('profile.marital_status'.tr()),
          const SizedBox(height: 8),
          _buildDropdown(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Label
  // -------------------------------------------------------------------------

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // TextField générique
  // -------------------------------------------------------------------------

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          if (prefixIcon != null) ...[
            SvgPicture.asset(
              prefixIcon,
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Champ Téléphone avec drapeau
  // -------------------------------------------------------------------------

  Widget _buildPhoneField() {
    return IntlPhoneField(
      controller: _telephoneController,
      initialCountryCode: 'SN',
      onChanged: (phone) => _fullPhone = phone.completeNumber,
      style: const TextStyle(fontSize: 15, color: AppColors.textDark),
      dropdownTextStyle: const TextStyle(fontSize: 15, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: '77 123 45 67',
        hintStyle: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: AppColors.borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: AppColors.borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Champ Date de naissance avec icône calendrier
  // -------------------------------------------------------------------------

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        // TODO: Connecter à l'API pour sauvegarder la date de naissance
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime(1990),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          locale: const Locale('fr', 'FR'),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primaryDark,
                  onPrimary: AppColors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _dateNaissanceController.text =
                '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
          });
        }
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.borderGray),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _dateNaissanceController.text.isEmpty
                    ? 'profile.birth_date_hint'.tr()
                    : _dateNaissanceController.text,
                style: TextStyle(
                  fontSize: 15,
                  color: _dateNaissanceController.text.isEmpty
                      ? AppColors.textSecondary
                      : AppColors.textDark,
                ),
              ),
            ),
            const Icon(Icons.calendar_month_outlined,
                color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Toggle Genre Homme / Femme
  // -------------------------------------------------------------------------

  Widget _buildGenderToggle() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          _genderOption('profile.male'.tr()),
          _genderOption('profile.female'.tr()),
        ],
      ),
    );
  }

  Widget _genderOption(String label) {
    final isSelected = _selectedGender == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Dropdown Situation matrimoniale
  // -------------------------------------------------------------------------

  Widget _buildDropdown() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSituation,
          hint: Text(
            'profile.marital_status'.tr(),
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textSecondary, size: 20),
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textDark,
          ),
          dropdownColor: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          items: _situationsMatrimoniales.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() => _selectedSituation = newValue);
          },
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Bouton "Mettre à jour"
  // -------------------------------------------------------------------------

  Widget _buildBottomButton(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: GestureDetector(
          // TODO: Appeler ProfileRepository.updateProfile() avec les données du formulaire
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Text(
                'documents.update_button'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
