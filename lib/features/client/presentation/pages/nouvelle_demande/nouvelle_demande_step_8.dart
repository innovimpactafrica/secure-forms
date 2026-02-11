import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NouvelleDemandeStep8Screen extends StatelessWidget {
  const NouvelleDemandeStep8Screen({super.key});

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
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 21.4,
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
                    width: 256,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF23A3A6),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ],
              ),
            ),
            // Indicateur 4/5
            Positioned(
              top: 135.6,
              left: 354,
              child: Text(
                '4/5',
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
            // Container d'information
            Positioned(
              top: 175,
              left: 24,
              right: 24,
              child: Container(
                height: 64,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFD17C00),
                    width: 1,
                  ),
                  color: const Color(0x14FFFAF1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Formats acceptés : PDF, JPG, PNG — Taille max : 5 Mo par document',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          height: 20 / 13,
                          letterSpacing: 0,
                          color: const Color(0xFFF29900),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Titre "Téléverser des documents"
            Positioned(
              top: 265,
              left: 24,
              child: Text(
                'Téléverser des documents',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 24 / 16,
                  letterSpacing: 0,
                  color: const Color(0xFFFFFFFF).withValues(alpha:0.7),
                ),
              ),
            ),
            // Container principal des documents
            Positioned(
              top: 310,
              left: 24,
              right: 24,
              child: Container(
                height: 271.33331298828125,
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                    // Container avec bordure en pointillés
                    Container(
                      width: 350,
                      height: 131.3333282470703,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF23A3A6),
                          width: 1,
                        ),
                        color: const Color(0x0A23A3A6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ligne avec icône et texte
                          Row(
                            children: [
                              // Icône id-card-alt
                              SvgPicture.asset(
                                'assets/icons/id-card-alt.svg',
                                width: 24,
                                height: 21.33333396911621,
                              ),
                              const SizedBox(width: 12),
                              // Texte
                              Text(
                                'Pièce d\'identité (obligatoire)',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  height: 1.0,
                                  letterSpacing: 0,
                                  color: const Color(0xFF343A40),
                                ),
                              ),
                              const Spacer(),
                              // Icône Vector
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF23A3A6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Container blanc
                          Container(
                            width: 318,
                            height: 50,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      // Image img (4).png
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(3.56),
                                          border: Border.all(
                                            color: const Color(0x0D000000),
                                            width: 0.17,
                                          ),
                                          color: const Color(0x33000000),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(3.56),
                                          child: Image.asset(
                                            'assets/images/img (4).png',
                                            width: 32,
                                            height: 32,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Texte cni.png
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'cni.png',
                                              style: TextStyle(
                                                fontFamily: 'Work Sans',
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                height: 1.0,
                                                letterSpacing: 0,
                                                color: const Color(0xFF343A40),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '20KO',
                                              style: TextStyle(
                                                fontFamily: 'Work Sans',
                                                fontWeight: FontWeight.w300,
                                                fontSize: 12,
                                                height: 1.0,
                                                letterSpacing: 0,
                                                color: const Color(0xFF95A5A6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Icône poubelle
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/icons/iconamoon_trash.svg',
                                      width: 16,
                                      height: 16,
                                      color: const Color(0xFFF44336),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Nouveau container avec bordure en pointillés
                    Container(
                      width: 350,
                      height: 68,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFCBD5E1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                // Icône list-solid
                                SvgPicture.asset(
                                  'assets/icons/list-solid.svg',
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 8),
                                // Texte
                                Expanded(
                                  child: Text(
                                    'Preuve de transaction (facultatif)',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      height: 1.0,
                                      letterSpacing: 0,
                                      color: const Color(0xFF343A40),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Icône btn-primary à droite
                          SvgPicture.asset(
                            'assets/icons/btn-primary.svg',
                            width: 24,
                            height: 24,
                          ),
                        ],
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            ),
            // Bouton Continuer
            Positioned(
              top: 780,
              left: 24,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/nouvelle-demande-step-9');
                },
                child: Container(
                  width: 382,
                  height: 56,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23A3A6),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      'Continuer',
                      style: TextStyle(
                        fontFamily: 'Sofia Sans',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.5,
                        letterSpacing: 0,
                        color: Colors.white,
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
    );
  }
}