import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/app_routes.dart';

class ClientFormulairesScreen extends StatefulWidget {
  const ClientFormulairesScreen({super.key});

  @override
  State<ClientFormulairesScreen> createState() => _ClientFormulairesScreenState();
}

class _ClientFormulairesScreenState extends State<ClientFormulairesScreen> {
  int? selectedCard; // null = aucune sélection, 0-3 = carte sélectionnée

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
              top: 105,
              left: 90,
              child: Text(
                'Banque Nationale',
                style: TextStyle(
                  fontFamily: 'Sofia Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 1.0,
                  letterSpacing: 0,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
            // Barre de progression
            Positioned(
              top: 140,
              left: 24,
              child: Stack(
                children: [
                  Container(
                    width: 320,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEE8EE),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF23A3A6),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ],
              ),
            ),
            // Indicateur 1/5
            Positioned(
              top: 135.6,
              left: 354,
              child: Text(
                '1/5',
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
            // Titre principal
            Positioned(
              top: 153,
              left: 24,
              child: Text(
                'Sélectionnez un formulaire',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 24 / 16,
                  letterSpacing: 0,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
            // Cartes de formulaires
            Positioned(
              top: 197,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  // Card 1
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCard = selectedCard == 0 ? null : 0;
                      });
                    },
                    child: Container(
                      width: 382,
                      height: 78,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      decoration: BoxDecoration(
                        color: selectedCard == 0 ? const Color(0xFF23A3A6) : Colors.white,
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Demande de transfert',
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    height: 24 / 18,
                                    letterSpacing: 0,
                                    color: selectedCard == 0 ? Colors.white : const Color(0xFF212121),
                                  ),
                                ),
                                Text(
                                  'Délai traitement 24h',
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: selectedCard == 0 ? Colors.white.withOpacity(0.8) : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          selectedCard == 0
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B3C5C),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 16,
                                    color: const Color(0xFF23A3A6),
                                  ),
                                )
                              : SvgPicture.asset(
                                  'assets/icons/Vector (17).svg',
                                  width: 24,
                                  height: 24,
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Card 2
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCard = selectedCard == 1 ? null : 1;
                      });
                    },
                    child: Container(
                      width: 382,
                      height: 78,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      decoration: BoxDecoration(
                        color: selectedCard == 1 ? const Color(0xFF23A3A6) : Colors.white,
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
                          const SizedBox(width: 12),
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
                                    fontSize: 18,
                                    height: 24 / 18,
                                    letterSpacing: 0,
                                    color: selectedCard == 1 ? Colors.white : const Color(0xFF212121),
                                  ),
                                ),
                                Text(
                                  'Délai traitement 24h',
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: selectedCard == 1 ? Colors.white.withOpacity(0.8) : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          selectedCard == 1
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B3C5C),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 16,
                                    color: const Color(0xFF23A3A6),
                                  ),
                                )
                              : SvgPicture.asset(
                                  'assets/icons/Vector (17).svg',
                                  width: 24,
                                  height: 24,
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Card 3
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCard = selectedCard == 2 ? null : 2;
                      });
                    },
                    child: Container(
                      width: 382,
                      height: 78,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      decoration: BoxDecoration(
                        color: selectedCard == 2 ? const Color(0xFF23A3A6) : Colors.white,
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
                            'assets/icons/logo (2).svg',
                            width: 36,
                            height: 36,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Demande de prêt',
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    height: 24 / 18,
                                    letterSpacing: 0,
                                    color: selectedCard == 2 ? Colors.white : const Color(0xFF212121),
                                  ),
                                ),
                                Text(
                                  'Délai traitement 24h',
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: selectedCard == 2 ? Colors.white.withOpacity(0.8) : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          selectedCard == 2
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B3C5C),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 16,
                                    color: const Color(0xFF23A3A6),
                                  ),
                                )
                              : SvgPicture.asset(
                                  'assets/icons/Vector (17).svg',
                                  width: 24,
                                  height: 24,
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Card 4
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCard = selectedCard == 3 ? null : 3;
                      });
                    },
                    child: Container(
                      width: 382,
                      height: 78,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      decoration: BoxDecoration(
                        color: selectedCard == 3 ? const Color(0xFF23A3A6) : Colors.white,
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
                            'assets/icons/logo (3).svg',
                            width: 36,
                            height: 36,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Opposition de cartes',
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    height: 24 / 18,
                                    letterSpacing: 0,
                                    color: selectedCard == 3 ? Colors.white : const Color(0xFF212121),
                                  ),
                                ),
                                Text(
                                  'Délai traitement 24h',
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: selectedCard == 3 ? Colors.white.withOpacity(0.8) : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          selectedCard == 3
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B3C5C),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 16,
                                    color: const Color(0xFF23A3A6),
                                  ),
                                )
                              : SvgPicture.asset(
                                  'assets/icons/Vector (17).svg',
                                  width: 24,
                                  height: 24,
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bouton Continuer
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Container(
                width: 382,
                height: 56,
                decoration: BoxDecoration(
                  color: selectedCard != null ? const Color(0xFF23A3A6) : const Color(0xFF0A324A),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: GestureDetector(
                    onTap: selectedCard != null ? () {
                      Navigator.pushNamed(context, AppRoutes.clientMethode);
                    } : null,
                    child: Text(
                      'Continuer',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: selectedCard != null ? Colors.white : const Color(0xFF6F8A99),
                      ),
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