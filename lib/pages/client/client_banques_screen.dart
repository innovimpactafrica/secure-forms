import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/app_routes.dart';

class ClientBanquesScreen extends StatefulWidget {
  const ClientBanquesScreen({super.key});

  @override
  State<ClientBanquesScreen> createState() => _ClientBanquesScreenState();
}

class _ClientBanquesScreenState extends State<ClientBanquesScreen> {
  int selectedFilter = 0; // 0: Notaire, 1: Banque

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 430,
        height: 932,
        color: const Color(0xFF0B3C5C),
        child: Stack(
          children: [
            // Bouton retour
            Positioned(
              top: 70,
              left: 24,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0x14FFFFFF),
                    borderRadius: BorderRadius.circular(12),
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
            // Titre "Nouvelle demande"
            Positioned(
              top: 78,
              left: 90,
              child: Text(
                'Nouvelle demande',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            // Sous-titre
            Positioned(
              top: 102,
              left: 90,
              child: Text(
                'Choisissez une banque ou un notaire',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
            // Barre de progression
            Positioned(
              top: 140,
              left: 24,
              child: Container(
                width: 320,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDEE8EE),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            // Indicateur 0/5
            Positioned(
              top: 135.6,
              left: 354,
              child: Text(
                '0/5',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.0,
                  letterSpacing: 0,
                  color: const Color(0xFF6F8A99),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Titre descriptif principal
            Positioned(
              top: 153,
              left: 24,
              child: Container(
                width: 382,
                height: 48,
                child: Text(
                  'Choisissez une banque ou un notaire pour entamer une demande.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    height: 24 / 16,
                    letterSpacing: 0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Section barre de recherche
            Positioned(
              top: 220,
              left: 24,
              right: 24,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0x1AF8FBF9),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: const Color(0x1AE8EEE7), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 28,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Rechercher une banque, notaire....',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 20 / 14,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Filtres Notaire et Banque
            Positioned(
              top: 290,
              left: 24,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Notaire',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Banque',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Cartes d'organisations
            Positioned(
              top: 340,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  // Première ligne - 2 cartes
                  Row(
                    children: [
                      // Card 1
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.clientFormulaires);
                          },
                          child: Container(
                            width: 183,
                            height: 162,
                            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      'assets/images/banque nationale.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                    SvgPicture.asset(
                                      'assets/icons/Vector (17).svg',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Banque Nationale',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    height: 24 / 16,
                                    letterSpacing: 0,
                                    color: const Color(0xFF212121),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Principal partenaire bancaire pour les comptes personnel...',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Card 2
                      Expanded(
                        child: Container(
                          width: 183,
                          height: 162,
                          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/images/notaire.png',
                                    width: 40,
                                    height: 40,
                                  ),
                                  SvgPicture.asset(
                                    'assets/icons/Vector (17).svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Étude notariale',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Sofia Sans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  height: 24 / 16,
                                  letterSpacing: 0,
                                  color: const Color(0xFF212121),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Services notariés certifiés en droit immobilier et en droit...',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Sofia Sans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  height: 1.0,
                                  letterSpacing: 0,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Deuxième ligne - 1 carte
                  Row(
                    children: [
                      // Card 3
                      Expanded(
                        child: Container(
                          width: 183,
                          height: 162,
                          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/images/credit.png',
                                    width: 40,
                                    height: 40,
                                  ),
                                  SvgPicture.asset(
                                    'assets/icons/Vector (17).svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Crédit Moderne',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Sofia Sans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  height: 24 / 16,
                                  letterSpacing: 0,
                                  color: const Color(0xFF212121),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Spécialisé dans le crédit à la consommation et les prêts.',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Sofia Sans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  height: 1.0,
                                  letterSpacing: 0,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
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