import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/app_routes.dart';

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
        width: 430,
        height: 932,
        child: Stack(
          children: [
            // Contenu principal de la page OTP
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
                    'Code de vérification',
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
                    'Saisissez le code à 4 chiffres envoyé par téléphone au 77... .. 67',
                    style: TextStyle(
                      fontFamily: 'Sofia Sans',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      height: 24 / 16,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Champs OTP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) {
                      bool isActive = _otpControllers[index].text.isEmpty && 
                          (index == 0 || _otpControllers[index - 1].text.isNotEmpty);
                      bool isFilled = _otpControllers[index].text.isNotEmpty;
                      
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0x1423A3A6) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
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
                            fontSize: 24,
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
                  const SizedBox(height: 40),
                  // Texte "Vous n'avez pas reçu de code ?"
                  Center(
                    child: Text(
                      'Vous n\'avez pas reçu de code ?',
                      style: TextStyle(
                        fontFamily: 'Sofia Sans',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Texte "Renvoyer le code"
                  Center(
                    child: Opacity(
                      opacity: 0.3,
                      child: Text(
                        'Renvoyer le code dans 00:29',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.0,
                          color: const Color(0xFF23A3A6),
                        ),
                      ),
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
            // Bouton Vérifier
            Positioned(
              bottom: 80,
              left: 24,
              right: 24,
              child: GestureDetector(
                onTap: _showSuccess,
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B3C5C),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Center(
                    child: Text(
                      'Vérifier',
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
            // Modal Success
            if (_showSuccessModal)
              Positioned(
                bottom: 50,
                left: 20,
                right: 20,
                child: Container(
                  width: 390,
                  height: 264,
                  padding: const EdgeInsets.fromLTRB(24, 50, 24, 50),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icône de validation
                      SvgPicture.asset(
                        'assets/icons/Vector (16).svg',
                        width: 64,
                        height: 64,
                      ),
                      const SizedBox(height: 32),
                      // Titre "Compte créé"
                      SizedBox(
                        width: 112,
                        height: 26,
                        child: Text(
                          'Compte créé',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            height: 1.3,
                            color: const Color(0xFF212121),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Sous-titre "Bienvenue sur votre espace"
                      SizedBox(
                        width: 342,
                        height: 24,
                        child: Text(
                          'Bienvenue sur votre espace',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
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