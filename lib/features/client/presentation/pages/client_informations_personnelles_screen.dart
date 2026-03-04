import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';

class ClientInformationsPersonnellesScreen extends StatefulWidget {
  const ClientInformationsPersonnellesScreen({super.key});

  @override
  State<ClientInformationsPersonnellesScreen> createState() =>
      _ClientInformationsPersonnellesScreenState();
}

class _ClientInformationsPersonnellesScreenState
    extends State<ClientInformationsPersonnellesScreen> {
  // TODO: Initialiser ces controllers avec les données de l'API (ProfileRepository)
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateNaissanceController =
      TextEditingController();

  String _selectedGender = 'profile.male'.tr();
  String? _selectedSituation;

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
    return Scaffold(
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
                    _buildForm(),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomButton(context),
        ],
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
          const SizedBox(width: 14),
          // Drapeau Sénégal
          ClipOval(
            child: Image.asset(
              'assets/images/flag_sn-1x1.png',
              width: 24,
              height: 24,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textSecondary, size: 16),
          const SizedBox(width: 8),
          // Séparateur
          Container(width: 1, height: 20, color: AppColors.borderDivider),
          const SizedBox(width: 10),
          const Text(
            '+221',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _telephoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 15, color: AppColors.textDark),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '77 123 45 67',
                hintStyle: TextStyle(
                    fontSize: 15, color: AppColors.textSecondary),
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
        color: const Color(0xFFF0F4F8),
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
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
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