import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_routes.dart';

class DetailOuvertureCompteContinuerScreen extends StatefulWidget {
  const DetailOuvertureCompteContinuerScreen({Key? key}) : super(key: key);

  @override
  State<DetailOuvertureCompteContinuerScreen> createState() => _DetailOuvertureCompteContinuerScreenState();
}

class _DetailOuvertureCompteContinuerScreenState extends State<DetailOuvertureCompteContinuerScreen> {
  final List<TextEditingController> _otpControllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          setState(() {
            _currentIndex = i;
          });
        }
      });
    }
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
                        color: Colors.white.withValues(alpha: 0.6),
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
                  // Titre "Vérification de sécurité"
                  Positioned(
                    top: 165,
                    left: 24,
                    child: Text(
                      'Vérification de sécurité',
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
                  // Description
                  Positioned(
                    top: 190,
                    left: 24,
                    right: 24,
                    child: Text(
                      'Nous avons envoyé un code à 4 chiffres se terminant par **88 à votre appareil mobile pour sceller ce document.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        height: 24 / 14,
                        letterSpacing: 0,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  // Container principal
                  Positioned(
                    top: 258,
                    left: 24,
                    right: 24,
                    child: Container(
                      height: 211,
                      padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
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
                          // Champs OTP
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(4, (index) {
                              bool isActive = _currentIndex == index;
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
                                  style: const TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 24,
                                    color: Color(0xFF0F1A14),
                                  ),
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    border: InputBorder.none,
                                  ),
                                  cursorColor: Colors.black,
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 3) {
                                      _focusNodes[index + 1].requestFocus();
                                    } else if (value.isEmpty && index > 0) {
                                      _focusNodes[index - 1].requestFocus();
                                    }
                                  },
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 38),
                          // Texte "Vous n'avez pas reçu de code ?"
                          Text(
                            'Vous n\'avez pas reçu de code ?',
                            style: TextStyle(
                              fontFamily: 'Sofia Sans',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Texte "Renvoyer le code"
                          Opacity(
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
                        ],
                      ),
                    ),
                  ),
                  // Bouton "Vérifier le document"
                  Positioned(
                    bottom: 40,
                    left: 24,
                    right: 24,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.nouvelleDemandeStep8);
                      },
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF23A3A6),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: Text(
                            'Vérifier le document',
                            style: TextStyle(
                              fontFamily: 'Sofia Sans',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.5,
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
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}