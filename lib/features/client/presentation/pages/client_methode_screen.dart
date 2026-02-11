import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_routes.dart';

class ClientMethodeScreen extends StatefulWidget {
  const ClientMethodeScreen({super.key});

  @override
  State<ClientMethodeScreen> createState() => _ClientMethodeScreenState();
}

class _ClientMethodeScreenState extends State<ClientMethodeScreen> {
  int selectedOption = 0; // 0: aucune sélection, 1: en ligne, 2: hors ligne

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
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
                    color: Colors.white.withValues(alpha:0.6),
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
                      width: 128,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF23A3A6),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ],
                ),
              ),
              // Indicateur 2/5
              Positioned(
                top: 135.6,
                left: 354,
                child: Text(
                  '2/5',
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
                top: 180,
                left: 24,
                child: Text(
                  'Comment souhaitez-vous remplir le formulaire ?',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    height: 24 / 15,
                    letterSpacing: 0,
                    color: Colors.white,
                  ),
                ),
              ),
              // Sous-titre descriptif
              Positioned(
                top: 207,
                left: 24,
                child: SizedBox(
                  width: 332,
                  height: 24,
                  child: Text(
                    'Choisissez la méthode qui vous convient le mieux.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 24 / 14,
                      letterSpacing: 0,
                      color: const Color(0xFFFFFFFF).withValues(alpha:0.7),
                    ),
                  ),
                ),
              ),
              // Container principal des options
              Positioned(
                top: 255,
                left: 24,
                right: 24,
                child: Container(
                  height: 568,
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE8EEE7),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x08000000),
                        blurRadius: 3,
                        offset: const Offset(3, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Card 1 - Remplir en ligne
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = 1;
                          });
                        },
                        child: Container(
                          width: 350,
                          height: 244,
                          padding: const EdgeInsets.fromLTRB(17, 20, 17, 20),
                          decoration: BoxDecoration(
                            color: selectedOption == 1 ? const Color(0x1423A3A6) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selectedOption == 1 ? const Color(0xFF23A3A6) : const Color(0xFFCBD5E1),
                              width: selectedOption == 1 ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icône crayon
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8.16),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: SvgPicture.asset(
                                        'assets/icons/bi_pencil (1).svg',
                                        width: 16,
                                        height: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Titre
                              Text(
                                'Remplir en ligne',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  height: 24 / 18,
                                  letterSpacing: 0,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Description
                              Text(
                                'Remplissez le formulaire directement dans votre navigateur grâce à notre éditeur sécurisé.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  height: 16 / 12,
                                  letterSpacing: 0,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Avantages
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/bi_check2-circle (1).svg',
                                    width: 16,
                                    height: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Expérience guidée',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        height: 16 / 12,
                                        letterSpacing: 0,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/bi_check2-circle (1).svg',
                                    width: 16,
                                    height: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Sauvegarde automatique de la progression',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        height: 16 / 12,
                                        letterSpacing: 0,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/bi_check2-circle (1).svg',
                                    width: 16,
                                    height: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Signature électronique instantanée',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        height: 16 / 12,
                                        letterSpacing: 0,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Card 2 - Télécharger hors ligne
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = 2;
                          });
                        },
                        child: Container(
                          width: 350,
                          height: 244,
                          padding: const EdgeInsets.fromLTRB(17, 20, 17, 20),
                          decoration: BoxDecoration(
                            color: selectedOption == 2 ? const Color(0x1423A3A6) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selectedOption == 2 ? const Color(0xFF23A3A6) : const Color(0xFFCBD5E1),
                              width: selectedOption == 2 ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icône téléchargement
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8.16),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: SvgPicture.asset(
                                        'assets/icons/Group (1).svg',
                                        width: 16,
                                        height: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Titre
                              Text(
                                'Téléchargez et remplissez hors ligne',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  height: 24 / 14,
                                  letterSpacing: 0,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Description
                              Text(
                                'Téléchargez le PDF officiel, remplissez-le à votre rythme et téléchargez-le en toute sécurité.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  height: 16 / 12,
                                  letterSpacing: 0,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Avantages
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/bi_check2-circle (1).svg',
                                    width: 16,
                                    height: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Format PDF officiel',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        height: 16 / 12,
                                        letterSpacing: 0,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/bi_check2-circle (1).svg',
                                    width: 16,
                                    height: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Remplir sans internet',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        height: 16 / 12,
                                        letterSpacing: 0,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/bi_check2-circle (1).svg',
                                    width: 16,
                                    height: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Vérification OTP sécurisée',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        height: 16 / 12,
                                        letterSpacing: 0,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bouton Continuer
              Positioned(
                top: 850,
                left: 24,
                right: 24,
                child: GestureDetector(
                  onTap: selectedOption > 0 ? () {
                    if (selectedOption == 1) {
                      Navigator.pushNamed(context, AppRoutes.nouvelleDemandeStep7);
                    } else {
                      Navigator.pushNamed(context, AppRoutes.nouvelleDemandeStep8);
                    }
                  } : null,
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selectedOption > 0 ? const Color(0xFF23A3A6) : const Color(0xFF0A324A),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(
                        selectedOption == 1 ? 'Continuer' : 'Télécharger et compléter plus tard',
                        style: TextStyle(
                          fontFamily: 'Sofia Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.5,
                          letterSpacing: 0,
                          color: selectedOption > 0 ? Colors.white : const Color(0xFF6F8A99),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}