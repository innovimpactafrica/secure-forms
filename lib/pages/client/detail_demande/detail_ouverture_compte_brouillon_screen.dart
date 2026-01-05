import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DetailOuvertureCompteBrouillonScreen extends StatelessWidget {
  const DetailOuvertureCompteBrouillonScreen({Key? key}) : super(key: key);

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
                        color: Colors.white.withOpacity(0.6),
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
                  // Barre de progression 3/5
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
                          width: 192,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF23A3A6),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Indicateur 3/5
                  Positioned(
                    top: 135.6,
                    left: 354,
                    child: Text(
                      '3/5',
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
                  // Titre "Téléverser le formulaire rempli"
                  Positioned(
                    top: 185,
                    left: 24,
                    child: Text(
                      'Téléverser le formulaire rempli',
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
                  // Sous-titre "Sélectionnez le fichier PDF rempli"
                  Positioned(
                    top: 210,
                    left: 24,
                    child: Text(
                      'Sélectionnez le fichier PDF rempli',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 24 / 14,
                        letterSpacing: 0,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  // Nouveau container
                  Positioned(
                    top: 260,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 150,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                            decoration: BoxDecoration(
                              color: const Color(0x0A23A3A6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF23A3A6),
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF23A3A6),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icons/bi_cloud-upload.svg',
                                    width: 12,
                                    height: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Cliquez pour télécharger',
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
                                  'PDF, JPG, PNG jusqu\'à 10 Mo',
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
                        ],
                      ),
                    ),
                  ),
                  // Nouveau container en bas
                  Positioned(
                    top: 480,
                    left: 24,
                    right: 24,
                    child: GestureDetector(
                      onTap: () {
                        // Navigation vers Client - Detail demande - Brouillon
                      },
                      child: Container(
                        height: 88,
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x14FFFFFF), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x0F000000),
                              offset: const Offset(0, 2),
                              blurRadius: 48,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      'Formulaire_ouverture_compte.pdf',
                                      style: TextStyle(
                                        fontFamily: 'Sofia Sans',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        height: 24 / 16,
                                        color: const Color(0xFF212121),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Document officiel • 1,2 Mo',
                                    style: TextStyle(
                                      fontFamily: 'Sofia Sans',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      height: 1.0,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 1.5, top: 12),
                              child: SvgPicture.asset(
                                'assets/icons/iconamoon_trash.svg',
                                width: 21,
                                height: 24,
                              ),
                            ),
                          ],
                        ),
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
                        Navigator.pushNamed(context, '/detail-ouverture-compte-continuer');
                      },
                      child: Container(
                        height: 64,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF23A3A6),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: Text(
                            'Continuer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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