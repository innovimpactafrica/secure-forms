import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import '../../../../utils/responsive_utils.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    // context.locale force le rebuild de toute la page quand la langue change
    context.locale;
    return Scaffold(
      body: SizedBox(
        width: ResponsiveUtils.getScreenWidth(context),
        height: ResponsiveUtils.getScreenHeight(context),
        child: Stack(
          children: [
            Container(
              width: ResponsiveUtils.getScreenWidth(context),
              height: ResponsiveUtils.getScreenHeight(context),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/f681350a809b550bf671bd4da879c2555620dd3b.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width: ResponsiveUtils.getScreenWidth(context),
              height: ResponsiveUtils.getScreenHeight(context),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black],
                ),
              ),
            ),
            // Globe langue — haut gauche
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, left: 16),
                  child: _LanguageToggle(),
                ),
              ),
            ),
            Positioned(
              bottom: ResponsiveUtils.getResponsiveHeight(context, 80),
              left: ResponsiveUtils.getResponsiveWidth(context, 12),
              right: ResponsiveUtils.getResponsiveWidth(context, 12),
              child: Column(
                children: [
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveWidth(context, 406),
                    child: Text(
                      'SECURE FORMS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        fontWeight: FontWeight.w700,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 42),
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 16)),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveWidth(context, 406),
                    child: Text(
                      'welcome.tagline'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilySofiaSans,
                        fontWeight: FontWeight.w400,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                        height: 28 / 18,
                        color: AppColors.whiteOpacity(0.7),
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 32)),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                    },
                    child: Container(
                      width: ResponsiveUtils.getResponsiveWidth(context, 382),
                      height: ResponsiveUtils.getResponsiveHeight(context, 64),
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getResponsiveWidth(context, 24),
                        vertical: ResponsiveUtils.getResponsiveHeight(context, 16),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                      ),
                      child: Center(
                        child: Text(
                          'welcome.start_button'.tr(),
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontWeight: FontWeight.w500,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                            height: 1.0,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageToggle extends StatefulWidget {
  const _LanguageToggle();

  @override
  State<_LanguageToggle> createState() => _LanguageToggleState();
}

class _LanguageToggleState extends State<_LanguageToggle> {
  @override
  Widget build(BuildContext context) {
    // context.locale force le rebuild quand la langue change
    final isFr = context.locale.languageCode == 'fr';
    return GestureDetector(
      onTap: () async {
        final newLocale = isFr ? const Locale('en') : const Locale('fr');
        await context.setLocale(newLocale);
        if (mounted) setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, color: Colors.white, size: 20),
            const SizedBox(width: 7),
            Text(
              isFr ? 'FR' : 'EN',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
