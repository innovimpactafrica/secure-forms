import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/app_routes.dart';

class NouvelleDemandeStep9Screen extends StatelessWidget {
  const NouvelleDemandeStep9Screen({super.key});

  void _showSuccessModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => Container(
        width: 342,
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône de validation
            SvgPicture.asset(
              'assets/icons/Vector (19).svg',
              width: 70,
              height: 70,
            ),
            const SizedBox(height: 16),
            // Titre
            Text(
              'Demande envoyé',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Message de confirmation
            Text(
              'Votre demande a été envoyé avec succès',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                height: 32 / 16,
                letterSpacing: 0,
                color: const Color(0xFF4F4F4F),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
    
    // Redirection après 1.5 secondes
    Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.of(context).pop(); // Fermer la modal
      Navigator.of(context).pushReplacementNamed(AppRoutes.clientDemandes);
    });
  }

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
                    width: 320,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF23A3A6),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ],
              ),
            ),
            // Indicateur 5/5
            Positioned(
              top: 135.6,
              left: 354,
              child: Text(
                '5/5',
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
            // Icône de validation
            Positioned(
              top: 200,
              left: 180,
              child: SvgPicture.asset(
                'assets/icons/Vector (19).svg',
                width: 70,
                height: 70,
              ),
            ),
            // Titre "Prêt à soumettre ?"
            Positioned(
              top: 290,
              left: (430 - 177) / 2,
              child: Text(
                'Prêt à soumettre ?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  height: 1.3,
                  letterSpacing: 0,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Description
            Positioned(
              top: 330,
              left: 24,
              right: 24,
              child: Text(
                'Veuillez vérifier votre demande. Une fois soumise, vous recevrez un courriel de confirmation.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 24 / 14,
                  letterSpacing: 0,
                  color: const Color(0xFFDEE8EE),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Container de récapitulatif
            Positioned(
              top: 413,
              left: 24,
              right: 24,
              child: Container(
                height: 142.404052734375,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFF5F6FA),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Ligne Formulaire
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Formulaire',
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            height: 1.0,
                            letterSpacing: 0,
                            color: const Color(0x80030319),
                          ),
                        ),
                        Text(
                          'Ouverture de compte',
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            height: 1.0,
                            letterSpacing: 0,
                            color: const Color(0xFF333333),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                    // Ligne Montant
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Montant',
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            height: 1.0,
                            letterSpacing: 0,
                            color: const Color(0x80030319),
                          ),
                        ),
                        Text(
                          '150 000 F CFA',
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            height: 1.0,
                            letterSpacing: 0,
                            color: const Color(0xFF333333),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                    // Ligne Documents
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Documents',
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            height: 1.0,
                            letterSpacing: 0,
                            color: const Color(0x80030319),
                          ),
                        ),
                        Text(
                          '2 fichiers joints',
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            height: 1.0,
                            letterSpacing: 0,
                            color: const Color(0xFF333333),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Bouton Soumettre
            Positioned(
              top: 780,
              left: 24,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  _showSuccessModal(context);
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
                      'Soumettre',
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