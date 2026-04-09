import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/features/client/domain/bloc/demandes_bloc/demandes_bloc.dart';
import 'package:secure_link/features/client/presentation/pages/client_home_screen.dart';
import 'package:secure_link/features/client/presentation/pages/client_demandes_screen.dart';
import 'package:secure_link/features/client/presentation/pages/mes_archives_screen.dart';
import 'package:secure_link/features/client/presentation/pages/client_profil_screen.dart';

class MainShell extends StatefulWidget {
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

class _BottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  State<_BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<_BottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  static const _navHeight = 70.0;
  static const _circleSize = 42.0;
  static const _notchDepth = 30.0; // profondeur du creux
  static const _notchWidth = 70.0; // largeur du creux

  static const List<String> _images = [
    'assets/images/accueil.png',
    'assets/images/demande.png',
    'assets/images/archiver.png',
    'assets/images/profil.png',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _anim = Tween<double>(
      begin: widget.currentIndex.toDouble(),
      end: widget.currentIndex.toDouble(),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_BottomNav old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _anim = Tween<double>(
        begin: _anim.value,
        end: widget.currentIndex.toDouble(),
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    final labels = [
      'navbar.home'.tr(),
      'navbar.requests'.tr(),
      'navbar.archives'.tr(),
      'navbar.account'.tr(),
    ];
    final itemCount = _images.length;

    return SafeArea(
      top: false,
      child: SizedBox(
        // hauteur totale = navbar + espace pour le cercle qui dépasse en haut
        height: _navHeight + _circleSize / 2,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, _) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Fond blanc avec creux en haut ──
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: _navHeight,
                  child: CustomPaint(
                    painter: _NotchPainter(
                      notchPos: _anim.value,
                      itemCount: itemCount,
                      notchDepth: _notchDepth,
                      notchWidth: _notchWidth,
                    ),
                  ),
                ),

                // ── Items ──
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: _navHeight + _circleSize / 2,
                  child: Row(
                    children: List.generate(itemCount, (i) {
                      final isActive = widget.currentIndex == i;
                      final color = isActive
                          ? AppColors.primaryDark
                          : AppColors.greyShade500;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => widget.onTap(i),
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            height: _navHeight + _circleSize / 2,
                            child: isActive
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // Cercle surélevé qui sort du creux
                                      Container(
                                        width: _circleSize,
                                        height: _circleSize,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryDark,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primaryDark
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            _images[i],
                                            width: 20,
                                            height: 20,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: _circleSize / 2),
                                      Image.asset(
                                        _images[i],
                                        width: 20,
                                        height: 20,
                                        color: color,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Painter : fond blanc avec creux arrondi en haut ──
class _NotchPainter extends CustomPainter {
  final double notchPos; // 0.0 → itemCount-1
  final int itemCount;
  final double notchDepth;
  final double notchWidth;

  const _NotchPainter({
    required this.notchPos,
    required this.itemCount,
    required this.notchDepth,
    required this.notchWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Ombre portée
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final itemWidth = size.width / itemCount;
    final cx = itemWidth * notchPos + itemWidth / 2;
    final half = notchWidth / 2;
    const smooth = 20.0;

    final path = Path();
    // Départ coin haut-gauche
    path.moveTo(0, 0);
    // Ligne jusqu'au début du creux
    path.lineTo(cx - half - smooth, 0);
    // Courbe d'entrée gauche
    path.cubicTo(
      cx - half, 0,
      cx - half, notchDepth,
      cx, notchDepth,
    );
    // Courbe de sortie droite
    path.cubicTo(
      cx + half, notchDepth,
      cx + half, 0,
      cx + half + smooth, 0,
    );
    // Ligne jusqu'au coin haut-droit
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, shadow);
    canvas.drawPath(path, fill);
  }

  @override
  bool shouldRepaint(_NotchPainter old) => old.notchPos != notchPos;
}
