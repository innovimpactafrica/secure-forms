import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/utils/responsive_utils.dart';

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
        width: ResponsiveUtils.getScreenWidth(context),
        height: ResponsiveUtils.getScreenHeight(context),
        child: Stack(
          children: [
            // Bouton retour
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 50),
              left: ResponsiveUtils.getResponsiveWidth(context, 24),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: ResponsiveUtils.getResponsiveWidth(context, 44),
                  height: ResponsiveUtils.getResponsiveHeight(context, 44),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, 22)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.03),
                        blurRadius: ResponsiveUtils.getResponsiveValue(context, 32),
                        offset: Offset(
                          ResponsiveUtils.getResponsiveValue(context, -3),
                          ResponsiveUtils.getResponsiveValue(context, -3),
                        ),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.03),
                        blurRadius: ResponsiveUtils.getResponsiveValue(context, 32),
                        offset: Offset(
                          ResponsiveUtils.getResponsiveValue(context, 3),
                          ResponsiveUtils.getResponsiveValue(context, 3),
                        ),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveUtils.getResponsiveValue(context, 7.54)),
                    child: SvgPicture.asset(
                      'assets/icons/arrow-left.svg',
                      width: ResponsiveUtils.getResponsiveWidth(context, 30.17),
                      height: ResponsiveUtils.getResponsiveHeight(context, 30.17),
                    ),
                  ),
                ),
              ),
            ),
            // Logo
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 56),
              right: ResponsiveUtils.getResponsiveWidth(context, 24),
              child: Image.asset(
                'assets/images/securelink.png',
                width: ResponsiveUtils.getResponsiveWidth(context, 131),
                height: ResponsiveUtils.getResponsiveHeight(context, 32),
                fit: BoxFit.contain,
              ),
            ),
            // Contenu principal
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 150),
              left: ResponsiveUtils.getResponsiveWidth(context, 24),
              right: ResponsiveUtils.getResponsiveWidth(context, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    'Numéro de téléphone',
                    style: TextStyle(
                      fontFamily: 'Sofia Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
                      height: 32 / 24,
                      color: const Color(0xFF0F1A14),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 16)),
                  // Texte explicatif
                  Text(
                    'Veuillez saisir votre numéro de téléphone.\nNous vous enverrons un code pour nous assurer que c\'est bien vous.',
                    style: TextStyle(
                      fontFamily: 'Sofia Sans',
                      fontWeight: FontWeight.w400,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                      height: 24 / 16,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 24)),
                  // Champ téléphone
                  Container(
                    width: double.infinity,
                    height: ResponsiveUtils.getResponsiveHeight(context, 54),
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getResponsiveWidth(context, 20),
                      vertical: ResponsiveUtils.getResponsiveHeight(context, 15),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, 100)),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      children: [
                        // Drapeau
                        Container(
                          width: ResponsiveUtils.getResponsiveWidth(context, 24),
                          height: ResponsiveUtils.getResponsiveHeight(context, 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, 12)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, 12)),
                            child: Image.asset(
                              'assets/images/flag_sn-1x1.png',
                              width: ResponsiveUtils.getResponsiveWidth(context, 24),
                              height: ResponsiveUtils.getResponsiveHeight(context, 24),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 8)),
                        // Chevron down
                        SvgPicture.asset(
                          'assets/icons/mdi-light_chevron-down.svg',
                          width: ResponsiveUtils.getResponsiveWidth(context, 20),
                          height: ResponsiveUtils.getResponsiveHeight(context, 20),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 8)),
                        // Séparateur
                        Container(
                          width: ResponsiveUtils.getResponsiveWidth(context, 1),
                          height: ResponsiveUtils.getResponsiveHeight(context, 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, 100)),
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 8)),
                        // Code pays
                        Text(
                          '+221',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                            color: const Color(0xFF333333),
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 12)),
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
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
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
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
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
              bottom: ResponsiveUtils.getResponsiveHeight(context, 170),
              left: ResponsiveUtils.getResponsiveWidth(context, 24),
              right: ResponsiveUtils.getResponsiveWidth(context, 24),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Sofia Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
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
              bottom: ResponsiveUtils.getResponsiveHeight(context, 80),
              left: ResponsiveUtils.getResponsiveWidth(context, 24),
              right: ResponsiveUtils.getResponsiveWidth(context, 24),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.otpVerification);
                },
                child: Container(
                  height: ResponsiveUtils.getResponsiveHeight(context, 64),
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