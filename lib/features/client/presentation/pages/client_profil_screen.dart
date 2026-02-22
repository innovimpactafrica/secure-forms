import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'client_informations_personnelles_screen.dart';
import 'mes_documents_screen.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_constants.dart';

class ClientProfilScreen extends StatefulWidget {
  const ClientProfilScreen({super.key});

  @override
  State<ClientProfilScreen> createState() => _ClientProfilScreenState();
}

class _ClientProfilScreenState extends State<ClientProfilScreen> {
  String selectedLanguage = 'Français';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _ProfileHeader(),
            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Avatar
                    _AvatarSection(),
                    const SizedBox(height: 16),
                    // Name + phone
                    _UserInfoSection(),
                    const SizedBox(height: 32),
                    // Menu items
                    _MenuSection(
                      selectedLanguage: selectedLanguage,
                      onLanguageTap: () => _showLangueModal(context),
                      onDemandesTap: () {},
                      onDocumentsTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MesDocumentsScreen(),
                        ),
                      ),
                      onInfosTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClientInformationsPersonnellesScreen(),
                        ),
                      ),
                      onArchivesTap: () {},
                      onNotifsTap: () {},
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // ── Logout button pinned at bottom ──
            _LogoutButton(
              onTap: () => _showDeconnexionModal(context),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // MODALS
  // ─────────────────────────────────────────────────────────────────

  void _showLangueModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: AppConstants.modalHandleWidth,
                height: AppConstants.modalHandleHeight,
                decoration: BoxDecoration(
                  color: AppColors.modalHandle,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Changer la langue',
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    fontWeight: FontWeight.w600,
                    fontSize: AppConstants.fontSizeXXLarge,
                    color: AppColors.textDark,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close,
                      size: AppConstants.iconSizeLarge,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.borderE5, height: 1),
            const SizedBox(height: 16),
            _buildLanguageOption(context, 'Français', 'assets/images/image 2.png'),
            const SizedBox(height: AppConstants.paddingMedium),
            _buildLanguageOption(context, 'Anglais', 'assets/images/image 3.png'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
      BuildContext context, String language, String flagPath) {
    final isSelected = selectedLanguage == language;
    return GestureDetector(
      onTap: () {
        setState(() => selectedLanguage = language);
        Navigator.of(context).pop();
      },
      child: Container(
        height: AppConstants.languageOptionHeight,
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.languageSelected : AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.languageBorder,
            width: AppConstants.borderWidthThin,
          ),
        ),
        child: Row(
          children: [
            Image.asset(flagPath,
                width: AppConstants.iconSizeLarge,
                height: AppConstants.iconSizeLarge),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Text(
                language,
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontWeight: FontWeight.w500,
                  fontSize: AppConstants.fontSizeLarge,
                  color: AppColors.profileText,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle,
                  color: AppColors.primary, size: AppConstants.iconSizeMedium)
            else
              Container(
                width: AppConstants.iconSizeMedium,
                height: AppConstants.iconSizeMedium,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.languageBorderUnselected,
                      width: AppConstants.borderWidthThick),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeconnexionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Déconnexion',
              style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontWeight: FontWeight.w600,
                fontSize: AppConstants.fontSizeTitle,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Êtes-vous sûr de vouloir vous déconnecter ?',
              style: TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontWeight: FontWeight.w400,
                fontSize: AppConstants.fontSizeXLarge,
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: AppConstants.fontSizeXXLarge),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontWeight: FontWeight.w500,
                          fontSize: AppConstants.fontSizeLarge,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: AppConstants.fontSizeXXLarge,
                  color: AppColors.divider,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/login', (r) => false);
                    },
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      child: Text(
                        'Se déconnecter',
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontWeight: FontWeight.w500,
                          fontSize: AppConstants.fontSizeLarge,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
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
          const SizedBox(width: 16),
          Text(
            'Mon Compte',
            style: TextStyle(
              fontFamily: AppConstants.fontFamilySofiaSans,
              fontWeight: FontWeight.w700,
              fontSize: AppConstants.fontSizeXXLarge,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// AVATAR
// ─────────────────────────────────────────────────────────────────
class _AvatarSection extends StatelessWidget {
  const _AvatarSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'LD',
          style: TextStyle(
            fontFamily: AppConstants.fontFamilySofiaSans,
            fontWeight: FontWeight.w700,
            fontSize: 36,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// USER INFO: name + phone
// ─────────────────────────────────────────────────────────────────
class _UserInfoSection extends StatelessWidget {
  const _UserInfoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Lamine DIEME',
          style: TextStyle(
            fontFamily: AppConstants.fontFamilySofiaSans,
            fontWeight: FontWeight.w700,
            fontSize: AppConstants.fontSizeTitle,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '77 123 45 67',
          style: TextStyle(
            fontFamily: AppConstants.fontFamilySofiaSans,
            fontWeight: FontWeight.w400,
            fontSize: AppConstants.fontSizeLarge,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// MENU SECTION
// ─────────────────────────────────────────────────────────────────
class _MenuSection extends StatelessWidget {
  final String selectedLanguage;
  final VoidCallback onLanguageTap;
  final VoidCallback onDemandesTap;
  final VoidCallback onDocumentsTap;
  final VoidCallback onInfosTap;
  final VoidCallback onArchivesTap;
  final VoidCallback onNotifsTap;

  const _MenuSection({
    required this.selectedLanguage,
    required this.onLanguageTap,
    required this.onDemandesTap,
    required this.onDocumentsTap,
    required this.onInfosTap,
    required this.onArchivesTap,
    required this.onNotifsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _MenuItem(
            iconPath: 'assets/icons/bi_person-circle.svg',
            title: 'Informations personnelles',
            onTap: onInfosTap,
          ),
          _Divider(),
          _MenuItem(
            iconPath: 'assets/icons/bi_file-earmark-text.svg',
            title: 'Mes documents',
            onTap: onDocumentsTap,
          ),
          _Divider(),
          _MenuItem(
            iconPath: 'assets/icons/bi_file-earmark-text.svg',
            title: 'Archives',
            onTap: onArchivesTap,
          ),
          _Divider(),
          _MenuItem(
            iconPath: 'assets/icons/bi_person-circle.svg',
            title: 'Mes notifications',
            onTap: onNotifsTap,
          ),
          _Divider(),
          // Language item with current value shown
          _LanguageMenuItem(
            selectedLanguage: selectedLanguage,
            onTap: onLanguageTap,
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String iconPath;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.iconPath,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: AppConstants.iconSizeLarge,
              height: AppConstants.iconSizeLarge,
              colorFilter: ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: AppConstants.paddingLarge),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontWeight: FontWeight.w500,
                  fontSize: AppConstants.fontSizeLarge,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.iconGray,
              size: AppConstants.iconSizeMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageMenuItem extends StatelessWidget {
  final String selectedLanguage;
  final VoidCallback onTap;

  const _LanguageMenuItem({
    required this.selectedLanguage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/material-symbols-light_language.svg',
              width: AppConstants.iconSizeLarge,
              height: AppConstants.iconSizeLarge,
              colorFilter: ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: AppConstants.paddingLarge),
            Expanded(
              child: Text(
                'Langue',
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilySofiaSans,
                  fontWeight: FontWeight.w500,
                  fontSize: AppConstants.fontSizeLarge,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Text(
              selectedLanguage,
              style: TextStyle(
                fontFamily: AppConstants.fontFamilySofiaSans,
                fontWeight: FontWeight.w400,
                fontSize: AppConstants.fontSizeMedium,
                color: AppColors.iconGray,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: AppColors.iconGray,
              size: AppConstants.iconSizeMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: AppColors.borderDivider,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// LOGOUT BUTTON
// ─────────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: AppConstants.logoutButtonHeight,
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius:
                BorderRadius.circular(AppConstants.radiusRound),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/bi_box-arrow-left.svg',
                width: AppConstants.iconSizeLarge,
                height: AppConstants.iconSizeLarge,
                colorFilter: ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Text(
                'Se déconnecter',
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontWeight: FontWeight.w500,
                  fontSize: AppConstants.fontSizeLarge,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}