import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quick_forms/core/utils/user_session.dart';
import 'package:quick_forms/core/utils/session_storage.dart';
import 'package:quick_forms/features/auth/domain/bloc/user_bloc.dart';
import 'package:quick_forms/features/auth/domain/bloc/user_event.dart';
import 'package:quick_forms/features/auth/domain/bloc/user_state.dart';
import 'package:quick_forms/features/client/domain/bloc/notifications_bloc.dart';
import 'package:quick_forms/features/client/domain/bloc/notifications_event.dart';
import 'package:quick_forms/features/client/domain/bloc/profile_event.dart';
import 'package:quick_forms/core/widgets/user_avatar.dart';
import 'package:quick_forms/features/client/domain/bloc/profile_bloc.dart';
import 'package:quick_forms/features/client/presentation/pages/mes_archives_screen.dart';
import 'package:quick_forms/features/client/presentation/pages/mes_banques_screen.dart';
import 'package:quick_forms/features/client/presentation/pages/notifications_screen.dart';
import 'client_informations_personnelles_screen.dart';
import 'mes_documents_screen.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_constants.dart';

class ClientProfilScreen extends StatefulWidget {
  final bool fromHome;
  final VoidCallback? onGoHome;
  const ClientProfilScreen({super.key, this.fromHome = false, this.onGoHome});

  @override
  State<ClientProfilScreen> createState() => _ClientProfilScreenState();
}

class _ClientProfilScreenState extends State<ClientProfilScreen> {
  String get selectedLanguage {
    return context.locale.languageCode == 'fr'
        ? 'profil.french'.tr()
        : 'profil.english'.tr();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<UserBloc>();
      final token = bloc.state is UserLoaded
          ? (bloc.state as UserLoaded).user.id.isNotEmpty
              ? UserSession.instance.accessToken
              : ''
          : UserSession.instance.accessToken;
      if (bloc.cachedUser == null) {
        bloc.add(LoadUserProfile(token));
      }
      if (bloc.profilePictureBytes == null) {
        bloc.add(LoadProfilePictureEvent(token));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _ProfileHeader(
                fromHome: widget.fromHome, onGoHome: widget.onGoHome),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    BlocBuilder<UserBloc, UserState>(
                      builder: (context, userState) {
                        final bloc = context.read<UserBloc>();
                        final user = userState is UserLoaded
                            ? userState.user
                            : bloc.cachedUser;
                        return Column(
                          children: [
                            const UserAvatar(size: 100, fontSize: 36),
                            const SizedBox(height: 16),
                            _UserInfoSection(
                              name: user?.displayName ?? '',
                              phone: user?.phone ?? '',
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    _MenuSection(
                      selectedLanguage: selectedLanguage,
                      onLanguageTap: () => _showLangueModal(context),
                      onDemandesTap: () {},
                      onDocumentsTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<ProfileBloc>(),
                            child: const MesDocumentsScreen(),
                          ),
                        ),
                      ),
                      onInfosTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ClientInformationsPersonnellesScreen(),
                        ),
                      ),
                      onArchivesTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MesArchivesScreen(),
                        ),
                      ),
                      onNotifsTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      ),
                      onBanquesTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MesBanquesScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _LogoutButton(
              onTap: () => _showDeconnexionModal(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLangueModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final media = MediaQuery.of(context);
        final bottomSafe = media.viewPadding.bottom;
        final keyboard = media.viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppConstants.paddingXLarge,
            AppConstants.paddingXLarge,
            AppConstants.paddingXLarge,
            bottomSafe + keyboard + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    'profil.change_language'.tr(),
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
              _buildLanguageOption(
                  context, 'profil.french'.tr(), 'assets/images/image 2.png'),
              const SizedBox(height: AppConstants.paddingMedium),
              _buildLanguageOption(
                  context, 'profil.english'.tr(), 'assets/images/image 3.png'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
      BuildContext context, String language, String flagPath) {
    final bool isSelected = (language == 'profil.french'.tr() &&
            context.locale.languageCode == 'fr') ||
        (language == 'profil.english'.tr() &&
            context.locale.languageCode == 'en');

    return GestureDetector(
      onTap: () {
        if (language == 'profil.french'.tr()) {
          context.setLocale(const Locale('fr'));
        } else {
          context.setLocale(const Locale('en'));
        }
        Navigator.of(context).pop();
        if (mounted) setState(() {});
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
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final bottom = MediaQuery.of(context).viewPadding.bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppConstants.paddingXLarge,
            AppConstants.paddingXLarge,
            AppConstants.paddingXLarge,
            bottom + AppConstants.paddingXLarge,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'profil.logout_title'.tr(),
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontWeight: FontWeight.w600,
                  fontSize: AppConstants.fontSizeTitle,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                'profil.logout_message'.tr(),
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
                          'profil.cancel'.tr(),
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
                        context
                            .read<NotificationsBloc>()
                            .add(const ResetNotificationsEvent());
                        context
                            .read<ProfileBloc>()
                            .add(const ResetProfileEvent());
                        context.read<UserBloc>().add(ClearUserProfile());
                        SessionStorage.instance.clear();
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/login', (r) => false);
                      },
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        child: Text(
                          'profil.logout'.tr(),
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
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final bool fromHome;
  final VoidCallback? onGoHome;
  const _ProfileHeader({this.fromHome = false, this.onGoHome});

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (fromHome && onGoHome != null) {
                onGoHome!();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'profil.my_account'.tr(),
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
// USER INFO
// ─────────────────────────────────────────────────────────────────
class _UserInfoSection extends StatelessWidget {
  final String name;
  final String phone;
  const _UserInfoSection({required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name.isNotEmpty ? name : '',
          style: TextStyle(
            fontFamily: AppConstants.fontFamilySofiaSans,
            fontWeight: FontWeight.w700,
            fontSize: AppConstants.fontSizeTitle,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          phone.isNotEmpty ? phone : '',
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
  final VoidCallback onBanquesTap;

  const _MenuSection({
    required this.selectedLanguage,
    required this.onLanguageTap,
    required this.onDemandesTap,
    required this.onDocumentsTap,
    required this.onInfosTap,
    required this.onArchivesTap,
    required this.onNotifsTap,
    required this.onBanquesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _MenuItem(
            iconPath: 'assets/icons/bi_person-circle.svg',
            title: 'profil.personal_info'.tr(),
            onTap: onInfosTap,
          ),
          _MenuItem(
            iconPath: 'assets/icons/mes documents.svg',
            title: 'profil.my_documents'.tr(),
            onTap: onDocumentsTap,
          ),
          _MenuItem(
            iconPath: 'assets/icons/bank.svg',
            title: 'profil.my_banks'.tr(),
            onTap: onBanquesTap,
          ),
          _MenuItem(
            iconPath: 'assets/icons/archive.svg',
            title: 'profil.archives'.tr(),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MesArchivesScreen()),
            ),
          ),
          _MenuItem(
            iconPath: 'assets/icons/mes notifications.svg',
            title: 'profil.my_notifications'.tr(),
            onTap: onNotifsTap,
          ),
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
    final isPng = iconPath.endsWith('.png');
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            isPng
                ? Image.asset(iconPath,
                    width: AppConstants.iconSizeLarge,
                    height: AppConstants.iconSizeLarge,
                    color: AppColors.primary)
                : SvgPicture.asset(
                    iconPath,
                    width: AppConstants.iconSizeLarge,
                    height: AppConstants.iconSizeLarge,
                    colorFilter: const ColorFilter.mode(
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
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/material-symbols-light_language.svg',
              width: AppConstants.iconSizeXLarge,
              height: AppConstants.iconSizeXLarge,
              colorFilter: ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: AppConstants.paddingLarge),
            Expanded(
              child: Text(
                'profil.language'.tr(),
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

// ─────────────────────────────────────────────────────────────────
// LOGOUT BUTTON
// ─────────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(context).viewPadding.bottom + 16,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: AppConstants.logoutButtonHeight,
          decoration: BoxDecoration(
            color: AppColors.statusRejected.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/bi_box-arrow-left.svg',
                width: AppConstants.iconSizeLarge,
                height: AppConstants.iconSizeLarge,
                colorFilter: ColorFilter.mode(
                  AppColors.statusRejected,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Text(
                'profil.logout'.tr(),
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontWeight: FontWeight.w500,
                  fontSize: AppConstants.fontSizeLarge,
                  color: AppColors.statusRejected,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
