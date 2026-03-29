import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/core/utils/country_code.dart';
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
  // Photo de profil locale (avant upload) ou bytes depuis l'API
  File? _localPicture;
  Uint8List? _pictureBytes;
  CountryCode _selectedCountry = kCountryCodes.first;

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
      final matchedCountry = kCountryCodes.firstWhere(
        (c) => user.phone.startsWith(c.dialCode),
        orElse: () => kCountryCodes.first,
      );
      _selectedCountry = matchedCountry;
      final phone = user.phone
          .replaceAll(matchedCountry.dialCode, '')
          .replaceAll(' ', '')
          .trim();
      _telephoneController.text = phone;
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
              final matchedCountry = kCountryCodes.firstWhere(
                (c) => user.phone.startsWith(c.dialCode),
                orElse: () => kCountryCodes.first,
              );
              _selectedCountry = matchedCountry;
              final phone = user.phone
                  .replaceAll(matchedCountry.dialCode, '')
                  .replaceAll(' ', '')
                  .trim();
              _telephoneController.text = phone;
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

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: kCountryCodes.length,
                  itemBuilder: (_, i) {
                    final country = kCountryCodes[i];
                    return ListTile(
                      leading: Text(country.flag,
                          style: const TextStyle(fontSize: 24)),
                      title: Text(country.name,
                          style: const TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontSize: AppConstants.fontSizeMedium,
                          )),
                      trailing: Text(country.dialCode,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontFamily: AppConstants.fontFamilyInter,
                          )),
                      onTap: () {
                        setState(() => _selectedCountry = country);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
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
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        children: [
          // ── Sélecteur pays (même style que l'inscription) ──
          GestureDetector(
            onTap: () => _showCountryPicker(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedCountry.flag,
                      style: const TextStyle(fontSize: AppConstants.flagSize)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                      size: AppConstants.chevronSize),
                ],
              ),
            ),
          ),
          // ── Séparateur ──
          Container(width: 1, height: 20, color: AppColors.borderGray),
          const SizedBox(width: 10),
          // ── Indicatif dynamique ──
          Text(
            _selectedCountry.dialCode,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 8),
          // ── Champ numéro ──
          Expanded(
            child: TextField(
              controller: _telephoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 15, color: AppColors.textDark),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '77 123 45 67',
                hintStyle:
                    TextStyle(fontSize: 15, color: AppColors.textSecondary),
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
