import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';


class ClientDemandesScreen extends StatefulWidget {
  const ClientDemandesScreen({super.key});

  @override
  State<ClientDemandesScreen> createState() => _ClientDemandesScreenState();
}

class _ClientDemandesScreenState extends State<ClientDemandesScreen> {
  int selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 430,
        height: 932,
        color: AppColors.background,
        child: Stack(
          children: [
            // Bouton retour
            Positioned(
              top: 70,
              left: 24,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.clientHome);
                },
                child: Container(
                  width: AppConstants.avatarSize,
                  height: AppConstants.avatarSize,
                  decoration: BoxDecoration(
                    color: AppColors.whiteOverlay,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/ep_back.svg',
                      width: 21.428571701049805,
                      height: 21.428571701049805,
                    ),
                  ),
                ),
              ),
            ),
            // Titre "Mes demandes"
            Positioned(
              top: 78,
              left: 90,
              child: Text(
                'Mes demandes',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: AppConstants.fontSizeXXLarge,
                  color: AppColors.white,
                ),
              ),
            ),
            // Sous-titre
            Positioned(
              top: 102,
              left: 90,
              child: Text(
                'Suivez et gérez vos applications.',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: AppConstants.fontSizeRegular,
                  color: AppColors.whiteOpacity(0.6),
                ),
              ),
            ),
            // Avatar "LD" à droite
            Positioned(
              top: 70,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.clientProfil);
                },
                child: Container(
                  width: AppConstants.avatarSize,
                  height: AppConstants.avatarSize,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusCircle),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 2,
                        left: 2,
                        child: Container(
                          width: AppConstants.avatarSizeLarge,
                          height: AppConstants.avatarSizeLarge,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppConstants.radiusCircle),
                            border: Border.all(color: AppColors.primaryDark, width: AppConstants.borderWidthThick),
                          ),
                          child: Center(
                            child: Text(
                              'LD',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: AppConstants.fontSizeXXLarge,
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
              ),
            ),
            // Section barre de recherche
            Positioned(
              top: 150,
              left: 24,
              right: 24,
              child: Container(
                height: AppConstants.searchBarHeight,
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingMedium,
                ),
                decoration: BoxDecoration(
                  color: AppColors.searchBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                  border: Border.all(color: AppColors.borderOverlay, width: AppConstants.borderWidthThin),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: AppConstants.iconSizeXLarge,
                      color: AppColors.whiteOpacity(0.6),
                    ),
                    SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: Text(
                        'Rechercher une demande',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: AppConstants.fontSizeMedium,
                          height: 20 / 14,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Filtres horizontaux
            Positioned(
              top: 220,
              left: 0,
              right: 0,
              child: SizedBox(
                height: AppConstants.filterHeight,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => selectedFilter = 0),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingLarge,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selectedFilter == 0 ? AppColors.primary : AppColors.whiteOverlayLight,
                          borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                        ),
                        child: Text(
                          'Tous',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: AppConstants.fontSizeMedium,
                            color: selectedFilter == 0 ? AppColors.white : AppColors.whiteOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setState(() => selectedFilter = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedFilter == 1 ? const Color(0xFF23A3A6) : const Color(0x1AFFFFFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Brouillon',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: selectedFilter == 1 ? Colors.white : Colors.white.withValues(alpha:0.7),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setState(() => selectedFilter = 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedFilter == 2 ? const Color(0xFF23A3A6) : const Color(0x1AFFFFFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'En cours',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: selectedFilter == 2 ? Colors.white : Colors.white.withValues(alpha:0.7),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setState(() => selectedFilter = 3),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedFilter == 3 ? const Color(0xFF23A3A6) : const Color(0x1AFFFFFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Validés',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: selectedFilter == 3 ? Colors.white : Colors.white.withValues(alpha:0.7),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setState(() => selectedFilter = 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedFilter == 4 ? const Color(0xFF23A3A6) : const Color(0x1AFFFFFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Rejeté',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: selectedFilter == 4 ? Colors.white : Colors.white.withValues(alpha:0.7),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Cards des demandes scrollables
            Positioned(
              top: 280,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                child: Column(
                  children: [
                    // Card 1 - Ouverture de compte
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.detailOuvertureCompte);
                      },
                      child: Container(
                        height: 79,
                        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x14FFFFFF)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x0F000000),
                              blurRadius: 48,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/logo.svg',
                              width: 36,
                              height: 36,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Ouverture de compte',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: const Color(0xFF212121),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Banque Nationale • 18/12/2025',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: const Color(0xFF6B7280),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F5F9),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Brouillon',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  height: 1.0,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Card 2 - Demande de virement
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.detailVirement);
                      },
                      child: Container(
                        height: 79,
                        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x14FFFFFF)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x0F000000),
                              blurRadius: 48,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/logo (1).svg',
                              width: 36,
                              height: 36,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Demande de virement',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: const Color(0xFF212121),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Banque Nationale • 12/12/2025',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: const Color(0xFF6B7280),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0x1AF39C12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'En attente',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  height: 1.0,
                                  color: const Color(0xFFF39C12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Card 3 - Acte de vente
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.detailActeVente);
                      },
                      child: Container(
                        height: 79,
                        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x14FFFFFF)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x0F000000),
                              blurRadius: 48,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/logo.svg',
                              width: 36,
                              height: 36,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Acte de vente',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: const Color(0xFF212121),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Notaire X • 05/12/2025',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: const Color(0xFF6B7280),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0x0F3B83F6),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'En cours',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  height: 1.0,
                                  color: const Color(0xFF3B83F6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Card 4 - Demande de prêt
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.detailPret);
                      },
                      child: Container(
                        height: 79,
                        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x14FFFFFF)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x0F000000),
                              blurRadius: 48,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/logo.svg',
                              width: 36,
                              height: 36,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Demande de prêt',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: const Color(0xFF212121),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Crédit Moderne • 12/11/2025',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: const Color(0xFF6B7280),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0x1A23A3A6),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Validé',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  height: 1.0,
                                  color: const Color(0xFF23A3A6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Card 5 - Carte de l'opposition
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.detailDemande);
                      },
                      child: Container(
                        height: 79,
                        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x14FFFFFF)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x0F000000),
                              blurRadius: 48,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/logo.svg',
                              width: 36,
                              height: 36,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Carte de l\'opposition',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: const Color(0xFF212121),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Banque Nationale • 04/11/2025',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: const Color(0xFF6B7280),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0x0FEF4444),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Rejeté',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  height: 1.0,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bouton flottant "+"
            Positioned(
              bottom: 45,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.clientBanques);
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF23A3A6),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}