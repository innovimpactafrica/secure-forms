import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';

class DetailOuvertureCompteContinuerScreen extends StatefulWidget {
  const DetailOuvertureCompteContinuerScreen({super.key});

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
        width: AppConstants.screenWidth,
        height: AppConstants.screenHeight,
        color: AppColors.primaryDark,
        child: Stack(
                children: [
                  // Bouton retour
                  Positioned(
                    top: 70,
                    left: AppConstants.paddingXLarge,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: AppConstants.backButtonSize,
                        height: AppConstants.backButtonSize,
                        decoration: BoxDecoration(
                          color: AppColors.whiteOverlay,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
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
                        fontSize: AppConstants.fontSizeXXLarge,
                        color: AppColors.white,
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
                        fontSize: AppConstants.fontSizeRegular,
                        color: AppColors.whiteOpacity(0.6),
                      ),
                    ),
                  ),
                  // Badge "Brouillon"
                  Positioned(
                    top: 78,
                    right: AppConstants.paddingXLarge,
                    child: Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.statusDraftLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Center(
                        child: Text(
                          'Brouillon',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontWeight: FontWeight.w500,
                            fontSize: AppConstants.fontSizeSmall,
                            color: AppColors.statusDraft,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Barre de progression 3/5
                  Positioned(
                    top: 140,
                    left: AppConstants.paddingXLarge,
                    child: Stack(
                      children: [
                        Container(
                          width: AppConstants.progressBarWidth,
                          height: AppConstants.progressBarHeight,
                          decoration: BoxDecoration(
                            color: AppColors.progressBar,
                            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                          ),
                        ),
                        Container(
                          width: 192,
                          height: AppConstants.progressBarHeight,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
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
                        fontFamily: AppConstants.fontFamilyInter,
                        fontWeight: FontWeight.w500,
                        fontSize: AppConstants.fontSizeMedium,
                        height: 1.0,
                        letterSpacing: 0,
                        color: AppColors.textLightGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Titre "Vérification de sécurité"
                  Positioned(
                    top: 165,
                    left: AppConstants.paddingXLarge,
                    child: Text(
                      'Vérification de sécurité',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontWeight: FontWeight.w600,
                        fontSize: AppConstants.fontSizeLarge,
                        height: 24 / 16,
                        letterSpacing: 0,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  // Description
                  Positioned(
                    top: 190,
                    left: AppConstants.paddingXLarge,
                    right: AppConstants.paddingXLarge,
                    child: Text(
                      'Nous avons envoyé un code à 4 chiffres se terminant par **88 à votre appareil mobile pour sceller ce document.',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        height: 24 / 14,
                        letterSpacing: 0,
                        color: AppColors.whiteOpacity(0.7),
                      ),
                    ),
                  ),
                  // Container principal
                  Positioned(
                    top: 258,
                    left: AppConstants.paddingXLarge,
                    right: AppConstants.paddingXLarge,
                    child: Container(
                      height: 211,
                      padding: EdgeInsets.fromLTRB(AppConstants.paddingLarge, 32, AppConstants.paddingLarge, 32),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        border: Border.all(color: AppColors.border, width: AppConstants.borderWidthThin),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowDark,
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
                                width: AppConstants.otpBoxSize,
                                height: AppConstants.otpBoxSize,
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.primaryLight : AppColors.gray,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                  border: isActive ? Border.all(color: AppColors.primary, width: AppConstants.borderWidthThin) : null,
                                ),
                                child: TextField(
                                  controller: _otpControllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamilySofiaSans,
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppConstants.fontSizeTitle,
                                    color: AppColors.textPrimary,
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
                              fontFamily: AppConstants.fontFamilySofiaSans,
                              fontWeight: FontWeight.w400,
                              fontSize: AppConstants.fontSizeLarge,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Texte "Renvoyer le code"
                          Opacity(
                            opacity: 0.3,
                            child: Text(
                              'Renvoyer le code dans 00:29',
                              style: TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontWeight: FontWeight.w500,
                                fontSize: AppConstants.fontSizeLarge,
                                height: 1.0,
                                color: AppColors.primary,
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
                    left: AppConstants.paddingXLarge,
                    right: AppConstants.paddingXLarge,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.nouvelleDemandeStep8);
                      },
                      child: Container(
                        height: AppConstants.buttonHeight,
                        padding: EdgeInsets.all(AppConstants.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                        ),
                        child: Center(
                          child: Text(
                            'Vérifier le document',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamilySofiaSans,
                              fontWeight: FontWeight.w500,
                              fontSize: AppConstants.fontSizeLarge,
                              height: 1.5,
                              color: AppColors.white,
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
