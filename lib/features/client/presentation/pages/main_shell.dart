import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/features/client/domain/bloc/demandes_bloc/demandes_bloc.dart';
import 'package:secure_link/features/client/presentation/pages/client_home_screen.dart';
import 'package:secure_link/features/client/presentation/pages/client_demandes_screen.dart';
import 'package:secure_link/features/client/presentation/pages/mes_archives_screen.dart';
import 'package:secure_link/features/client/presentation/pages/client_profil_screen.dart';

class MainShell extends StatefulWidget {
  /// Onglet initial (0=home, 1=demandes, 2=archives, 3=profil)
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTap(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  void _goHome() => setState(() => _currentIndex = 0);

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const ClientHomeScreen(),
          BlocProvider(
            create: (_) => DemandesBloc(),
            child: ClientDemandesScreen(fromHome: true, onGoHome: _goHome),
          ),
          MesArchivesScreen(fromHome: true, onGoHome: _goHome),
          ClientProfilScreen(fromHome: true, onGoHome: _goHome),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BOTTOM NAV — icônes SVG cohérentes avec la page profil
// ─────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    context.locale;

    final items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'navbar.home'.tr(),
      ),
      _NavItem(
        icon: Icons.assignment_outlined,
        activeIcon: Icons.assignment,
        label: 'navbar.requests'.tr(),
      ),
      _NavItem(
        icon: Icons.inventory_2_outlined,
        activeIcon: Icons.inventory_2,
        label: 'navbar.archives'.tr(),
      ),
      _NavItem(
        svgActive: 'assets/icons/bi_person-circle.svg',
        svgInactive: 'assets/icons/bi_person-circle.svg',
        label: 'navbar.account'.tr(),
        useSvg: true,
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.borderDivider, width: 1)),
        boxShadow: [
          BoxShadow(color: AppColors.shadowDark, blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = currentIndex == i;
              final color = isActive ? AppColors.primary : AppColors.greyShade500;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      item.useSvg
                          ? SvgPicture.asset(
                              item.svgActive!,
                              width: 22,
                              height: 22,
                              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                            )
                          : Icon(
                              isActive ? item.activeIcon! : item.icon!,
                              size: 24,
                              color: color,
                            ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamilyInter,
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData? icon;
  final IconData? activeIcon;
  final String? svgActive;
  final String? svgInactive;
  final String label;
  final bool useSvg;

  const _NavItem({
    this.icon,
    this.activeIcon,
    this.svgActive,
    this.svgInactive,
    required this.label,
    this.useSvg = false,
  });
}
