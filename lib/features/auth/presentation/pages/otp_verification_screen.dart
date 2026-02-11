import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import '../../../../utils/responsive_utils.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  bool _showSuccessModal = false;

  void _showSuccess() {
    setState(() {
      _showSuccessModal = true;
    });
    
    // Masquer la modal après 2 secondes et naviguer
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.clientHome);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: ResponsiveUtils.getScreenWidth(context),
        height: ResponsiveUtils.getScreenHeight(context),
        child: Stack(
          children: [
            // Contenu principal de la page OTP
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
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveValue(context, 22),
                    ),
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
                    padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsiveValue(context, 7.54),
                    ),
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
              bottom: ResponsiveUtils.getResponsiveHeight(context, 250),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Titre
                  Text(
                    'Code de vérification',
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
                    'Saisissez le code à 4 chiffres envoyé par téléphone au 77... .. 67',
                    style: TextStyle(
                      fontFamily: 'Sofia Sans',
                      fontWeight: FontWeight.w400,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                      height: 24 / 16,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 40)),
                  // Champs OTP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) {
                      bool isActive = _otpControllers[index].text.isEmpty && 
                          (index == 0 || _otpControllers[index - 1].text.isNotEmpty);
                      
                      return Container(
                        width: ResponsiveUtils.getResponsiveWidth(context, 60),
                        height: ResponsiveUtils.getResponsiveHeight(context, 60),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0x1423A3A6) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getResponsiveValue(context, 12),
                          ),
                          border: isActive ? Border.all(color: const Color(0xFF23A3A6), width: 1) : null,
                        ),
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
                            color: const Color(0xFF0F1A14),
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              if (value.isNotEmpty && index < 3) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            });
                          },
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 40)),
                  // Texte "Vous n'avez pas reçu de code ?"
                  Center(
                    child: Text(
                      'Vous n\'avez pas reçu de code ?',
                      style: TextStyle(
                        fontFamily: 'Sofia Sans',
                        fontWeight: FontWeight.w400,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 8)),
                  // Texte "Renvoyer le code"
                  Center(
                    child: Opacity(
                      opacity: 0.3,
                      child: Text(
                        'Renvoyer le code dans 00:29',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                          height: 1.0,
                          color: const Color(0xFF23A3A6),
                        ),
                      ),
                    ),
                  ),
                  ],
                ),
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
            // Bouton Vérifier
            Positioned(
              bottom: ResponsiveUtils.getResponsiveHeight(context, 80),
              left: ResponsiveUtils.getResponsiveWidth(context, 24),
              right: ResponsiveUtils.getResponsiveWidth(context, 24),
              child: GestureDetector(
                onTap: _showSuccess,
                child: Container(
                  height: ResponsiveUtils.getResponsiveHeight(context, 64),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B3C5C),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveValue(context, 100),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Vérifier',
                      style: TextStyle(
                        fontFamily: 'Sofia Sans',
                        fontWeight: FontWeight.w500,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Modal Success
            if (_showSuccessModal)
              Positioned(
                bottom: ResponsiveUtils.getResponsiveHeight(context, 50),
                left: ResponsiveUtils.getResponsiveWidth(context, 20),
                right: ResponsiveUtils.getResponsiveWidth(context, 20),
                child: Container(
                  width: ResponsiveUtils.getResponsiveWidth(context, 390),
                  height: ResponsiveUtils.getResponsiveHeight(context, 264),
                  padding: EdgeInsets.fromLTRB(
                    ResponsiveUtils.getResponsiveWidth(context, 24),
                    ResponsiveUtils.getResponsiveHeight(context, 50),
                    ResponsiveUtils.getResponsiveWidth(context, 24),
                    ResponsiveUtils.getResponsiveHeight(context, 50),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveValue(context, 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.2),
                        blurRadius: ResponsiveUtils.getResponsiveValue(context, 10),
                        offset: Offset(
                          0,
                          ResponsiveUtils.getResponsiveValue(context, 5),
                        ),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icône de validation
                      SvgPicture.asset(
                        'assets/icons/Vector (16).svg',
                        width: ResponsiveUtils.getResponsiveWidth(context, 64),
                        height: ResponsiveUtils.getResponsiveHeight(context, 64),
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 32)),
                      // Titre "Compte créé"
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveWidth(context, 112),
                        height: ResponsiveUtils.getResponsiveHeight(context, 26),
                        child: Text(
                          'Compte créé',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                            height: 1.3,
                            color: const Color(0xFF212121),
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 16)),
                      // Sous-titre "Bienvenue sur votre espace"
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveWidth(context, 342),
                        height: ResponsiveUtils.getResponsiveHeight(context, 24),
                        child: Text(
                          'Bienvenue sur votre espace',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                            height: 24 / 18,
                            color: const Color(0xFF0F1A14),
                          ),
                        ),
                      ),
                    ],
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
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}