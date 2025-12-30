import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: 430,
        height: 932,
        child: Stack(
          children: [
            // Bouton retour
            Positioned(
              top: 50,
              left: 24,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 32,
                        offset: const Offset(-3, -3),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 32,
                        offset: const Offset(3, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(7.54),
                    child: SvgPicture.asset(
                      'assets/icons/arrow-left.svg',
                      width: 30.17,
                      height: 30.17,
                    ),
                  ),
                ),
              ),
            ),
            // Logo
            Positioned(
              top: 56,
              right: 24,
              child: Image.asset(
                'assets/images/securelink.png',
                width: 131,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
            // Contenu principal
            Positioned(
              top: 150,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    'Numéro de téléphone',
                    style: TextStyle(
                      fontFamily: 'Sofia Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      height: 32 / 24,
                      color: const Color(0xFF0F1A14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Texte explicatif
                  Text(
                    'Veuillez saisir votre numéro de téléphone.\nNous vous enverrons un code pour nous assurer que c\'est bien vous.',
                    style: TextStyle(
                      fontFamily: 'Sofia Sans',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      height: 24 / 16,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Champ téléphone
                  Container(
                    width: double.infinity,
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      children: [
                        // Drapeau
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/flag_sn-1x1.png',
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Chevron down
                        SvgPicture.asset(
                          'assets/icons/mdi-light_chevron-down.svg',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        // Séparateur
                        Container(
                          width: 1,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Code pays
                        Text(
                          '+221',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Champ de saisie
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: '77 123 45 67',
                              hintStyle: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: const Color(0xFF9C9AA5),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: const Color(0xFF333333),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Texte légal
            Positioned(
              bottom: 170,
              left: 24,
              right: 24,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Sofia Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                  children: [
                    const TextSpan(text: 'En continuant, vous confirmez avoir lu et accepté les '),
                    TextSpan(
                      text: 'conditions générales',
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' et la '),
                    TextSpan(
                      text: 'politique de confidentialité.',
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bouton Suivant
            Positioned(
              bottom: 80,
              left: 24,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.otpVerification);
                },
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B3C5C),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Center(
                    child: Text(
                      'Suivant',
                      style: TextStyle(
                        fontFamily: 'Sofia Sans',
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.white,
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

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}