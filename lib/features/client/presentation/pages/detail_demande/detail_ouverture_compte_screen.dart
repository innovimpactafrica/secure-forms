import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DetailOuvertureCompteScreen extends StatelessWidget {
  const DetailOuvertureCompteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
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
                  // Titre "Ouverture de compte"
                  Positioned(
                    top: 78,
                    left: 90,
                    child: Text(
                      'Ouverture de compte',
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
                      'Banque Nationale • 18/12/2025',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.white.withValues(alpha:0.6),
                      ),
                    ),
                  ),
                  // Badge "Brouillon"
                  Positioned(
                    top: 78,
                    right: 24,
                    child: Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F5F9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Center(
                        child: Text(
                          'Brouillon',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Container blanc en bas du header
                  Positioned(
                    top: 150,
                    left: 24,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REQ-2024-004',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              height: 1.0,
                              letterSpacing: 0.03,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Soumis le 15/12, 10h00',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  height: 1.0,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                'Estimé : 17/12',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  height: 1.0,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Barre de progression
                          Row(
                            children: [
                              // Étape 1: Enregistré
                              Column(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0B3C5C),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/bi_pencil (1).svg',
                                        width: 20,
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Enregistré',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      height: 1.0,
                                      color: const Color(0xFF6B7280),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              // Ligne de progression 1
                              Expanded(
                                child: Container(
                                  height: 6,
                                  margin: const EdgeInsets.only(bottom: 32),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD9D9D9),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              ),
                              // Étape 2: En cours
                              Column(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5E7EB),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/bi_clock-history.svg',
                                        width: 20,
                                        height: 20,
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'En cours',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      height: 1.0,
                                      color: const Color(0xFF6B7280),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              // Ligne de progression 2
                              Expanded(
                                child: Container(
                                  height: 6,
                                  margin: const EdgeInsets.only(bottom: 32),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD9D9D9),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              ),
                              // Étape 3: Finalisé
                              Column(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5E7EB),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/ep_check.svg',
                                        width: 20,
                                        height: 20,
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Finalisé',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      height: 1.0,
                                      color: const Color(0xFF6B7280),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Nouveau container
                  Positioned(
                    top: 320,
                    left: 24,
                    right: 24,
                    child: Container(
                      height: 204,
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8EEE7), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x08000000),
                            offset: const Offset(3, 3),
                            blurRadius: 3,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          SvgPicture.asset(
                            'assets/icons/hugeicons_files-02.svg',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun document fourni',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              height: 1.0,
                              color: const Color(0xFF343A40),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Merci de téléverser le formulaire rempli.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              height: 1.0,
                              color: const Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bouton en bas
                  Positioned(
                    bottom: 80,
                    left: 24,
                    right: 24,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/detail-ouverture-compte-brouillon');
                      },
                      child: Container(
                        height: 64,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF23A3A6),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/bi_pencil (1).svg',
                              width: 16,
                              height: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Compléter les informations',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }
}