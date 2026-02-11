import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_routes.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 430,
        height: 932,
        color: const Color(0xFF0B3C5C),
        child: Stack(
          children: [
            // Logo SECURE LINK à gauche
            Positioned(
              top: 70,
              left: 24,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(33.33),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(33.33),
                  child: Image.asset(
                    'assets/images/img (3).png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
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
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(125),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 2,
                        left: 2,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFF23A3A6),
                            borderRadius: BorderRadius.circular(125),
                            border: Border.all(color: const Color(0xFF0B3C5C), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              'LD',
                              style: TextStyle(
                                fontFamily: 'Sofia Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                height: 1.0,
                                color: Colors.white,
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
            // Salutation "Bonjour, Lamine"
            Positioned(
              top: 78,
              left: 90,
              child: SizedBox(
                width: 209,
                height: 22,
                child: Text(
                  'Bonjour, Lamine',
                  style: TextStyle(
                    fontFamily: 'Sofia Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    height: 1.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Sous-titre "Bienvenue, sur votre tableau de bord"
            Positioned(
              top: 102,
              left: 90,
              child: Text(
                'Bienvenue, sur votre tableau de bord',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  height: 1.0,
                  color: Colors.white.withValues(alpha:0.6),
                ),
              ),
            ),
            // Section barre de recherche
            Positioned(
              top: 150,
              left: 24,
              right: 24,
              child: Container(
                height: 56,
                padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
                decoration: BoxDecoration(
                  color: const Color(0x1AF8FBF9),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: const Color(0x1AE8EEE7), width: 1),
                ),
                child: Row(
                  children: [
                    // Icône loupe
                    Icon(
                      Icons.search,
                      size: 28,
                      color: Colors.white.withValues(alpha:0.6),
                    ),
                    const SizedBox(width: 12),
                    // Texte placeholder
                    Expanded(
                      child: Text(
                        'Rechercher une banque, notaire....',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 20 / 14,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                    // Bouton flèche à droite
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF23A3A6),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Cards d'actions
            Positioned(
              top: 230,
              left: 24,
              right: 24,
              child: Row(
                children: [
                  // Card 1 - Nouvelle demande
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.clientBanques);
                      },
                      child: Container(
                        height: 120,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icône plus
                            SvgPicture.asset(
                              'assets/icons/bi_plus-circle.svg',
                              width: 28,
                              height: 28,
                            ),
                            const SizedBox(height: 16),
                            // Titre "Nouvelle demande"
                            Text(
                              'Nouvelle demande',
                              style: TextStyle(
                                fontFamily: 'Sofia Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                height: 1.0,
                                color: const Color(0xFF222222),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Sous-titre "Banque, notaire..."
                            Text(
                              'Banque, notaire...',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 1.0,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Card 2 - Mes demandes
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.clientDemandes);
                      },
                      child: Container(
                        height: 120,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icône historique
                            SvgPicture.asset(
                              'assets/icons/solar_history-bold.svg',
                              width: 28,
                              height: 28,
                            ),
                            const SizedBox(height: 16),
                            // Titre "Mes demandes"
                            Text(
                              'Mes demandes',
                              style: TextStyle(
                                fontFamily: 'Sofia Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                height: 1.0,
                                color: const Color(0xFF222222),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Sous-titre "Voir mes historiques"
                            Text(
                              'Voir mes historiques',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 1.0,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Titre "Demandes récentes"
            Positioned(
              top: 380,
              left: 24,
              child: Text(
                'Demandes récentes',
                style: TextStyle(
                  fontFamily: 'Sofia Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 24,
                  height: 24 / 24,
                  color: Colors.white,
                ),
              ),
            ),
            // Lien "Tout voir" avec flèche
            Positioned(
              top: 388,
              right: 24,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tout voir',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.0,
                      color: const Color(0xFF23A3A6),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: const Color(0xFF23A3A6),
                  ),
                ],
              ),
            ),
            // Cards des demandes récentes
            Positioned(
              top: 430,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  // Card 1 - Ouverture de compte
                  Container(
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
                                  fontFamily: 'Sofia Sans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: const Color(0xFF212121),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Banque Nationale • 18/12/2025',
                                style: TextStyle(
                                  fontFamily: 'Inter',
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
                              fontFamily: 'Inter',
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
                  const SizedBox(height: 16),
                  // Card 2 - Demande de virement
                  Container(
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
                                  fontFamily: 'Sofia Sans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: const Color(0xFF212121),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Banque Nationale • 12/12/2025',
                                style: TextStyle(
                                  fontFamily: 'Inter',
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
                              fontFamily: 'Inter',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}