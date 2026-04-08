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
// BOTTOM NAV avec creux (notch) sous l'icône active
// ─────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    context.locale;
    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'navbar.home'.tr()),
      _NavItem(icon: Icons.assignment, label: 'navbar.requests'.tr()),
      _NavItem(icon: Icons.inventory_2, label: 'navbar.archives'.tr()),
      _NavItem(svgActive: 'assets/icons/bi_person-circle.svg', label: 'navbar.account'.tr(), useSvg: true),
    ];

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 72,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Fond blanc avec ombre
            Positioned.fill(
              child: CustomPaint(
                painter: _NotchNavPainter(activeIndex: currentIndex, itemCount: items.length),
              ),
            ),
            // Items
            Row(
              children: List.generate(items.length, (i) {
                final item = items[i];
                final isActive = currentIndex == i;
                final color = isActive ? AppColors.primaryDark : AppColors.greyShade500;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: 72,
                      child: isActive
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  transform: Matrix4.translationValues(0, -14, 0),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryDark,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryDark.withValues(alpha: 0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: item.useSvg
                                        ? Center(
                                            child: SvgPicture.asset(
                                              item.svgActive!,
                                              width: 22,
                                              height: 22,
                                              colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                                            ),
                                          )
                                        : Icon(item.icon, size: 24, color: AppColors.white),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 4),
                                item.useSvg
                                    ? SvgPicture.asset(
                                        item.svgActive!,
                                        width: 22,
                                        height: 22,
                                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                                      )
                                    : Icon(item.icon, size: 24, color: color),
                                const SizedBox(height: 6),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamilyInter,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: color,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// Painter qui dessine le fond blanc avec le creux sous l'icône active
class _NotchNavPainter extends CustomPainter {
  final int activeIndex;
  final int itemCount;

  const _NotchNavPainter({required this.activeIndex, required this.itemCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final itemWidth = size.width / itemCount;
    final cx = itemWidth * activeIndex + itemWidth / 2;
    const notchRadius = 28.0;
    const notchDepth = 18.0;

    final path = Path();
    path.moveTo(0, 0);

    // Côté gauche du creux
    path.lineTo(cx - notchRadius - 12, 0);
    // Courbe gauche du creux
    path.cubicTo(
      cx - notchRadius, 0,
      cx - notchRadius, notchDepth,
      cx, notchDepth,
    );
    // Courbe droite du creux
    path.cubicTo(
      cx + notchRadius, notchDepth,
      cx + notchRadius, 0,
      cx + notchRadius + 12, 0,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Ombre
    canvas.drawPath(path, shadowPaint);
    // Fond
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_NotchNavPainter old) => old.activeIndex != activeIndex;
}

class _NavItem {
  final IconData? icon;
  final String? svgActive;
  final String label;
  final bool useSvg;

  const _NavItem({
    this.icon,
    this.svgActive,
    required this.label,
    this.useSvg = false,
  });
}
