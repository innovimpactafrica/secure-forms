import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';

class ClientInformationsPersonnellesScreen extends StatefulWidget {
  const ClientInformationsPersonnellesScreen({super.key});

  @override
  State<ClientInformationsPersonnellesScreen> createState() => _ClientInformationsPersonnellesScreenState();
}

class _ClientInformationsPersonnellesScreenState extends State<ClientInformationsPersonnellesScreen> {
  String selectedGender = 'Homme';

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
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.white,
                      size: 21.4,
                    ),
                  ),
                ),
              ),
            ),
            // Titre "Complétez votre profil"
            Positioned(
              top: 85,
              left: 73,
              right: 24,
              child: Text(
                'Complétez votre profil',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  height: 1.0,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Container blanc principal
            Positioned(
              top: 140,
              left: 24,
              right: 24,
              child: Container(
                height: 600,
                padding: EdgeInsets.fromLTRB(16, 24, 16, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre "Informations personnelles"
                    Text(
                      'Informations personnelles',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        height: 32 / 18,
                        letterSpacing: 0,
                        color: Color(0xFF0F1A14),
                      ),
                    ),
                    SizedBox(height: 1),
                    // Sous-titre
                    Text(
                      'Ces informations facilitent la vérification.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 1.0,
                        letterSpacing: 0,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    SizedBox(height: 32),
                    // Label Prénom
                    Text(
                      'Prénom',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 1.0,
                        letterSpacing: 0,
                        color: Color(0xFF212121),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Champ Prénom
                    Container(
                      height: 50,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFCBD5E1), width: 1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/bi_person.svg',
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              Color(0xFF9CA3AF),
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Lamine',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    // Label Nom
                    Text(
                      'Nom',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 1.0,
                        letterSpacing: 0,
                        color: Color(0xFF212121),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Champ Nom
                    Container(
                      height: 50,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFCBD5E1), width: 1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/bi_person.svg',
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              Color(0xFF9CA3AF),
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Dieme',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    // Label Téléphone
                    Text(
                      'Téléphone',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 1.0,
                        letterSpacing: 0,
                        color: Color(0xFF212121),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Champ Téléphone
                    Container(
                      height: 50,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFCBD5E1), width: 1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Drapeau Sénégal
                          Image.asset(
                            'assets/images/flag_sn-1x1.png',
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF9CA3AF),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          SizedBox(
                            width: 1,
                            height: 20,
                            child: Container(
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '+221',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF374151),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '77 123 45 67',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    // Label Email
                    Text(
                      'Email',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 1.0,
                        letterSpacing: 0,
                        color: Color(0xFF212121),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Champ Email
                    Container(
                      height: 50,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFCBD5E1), width: 1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/bi_envelope.svg',
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              Color(0xFF9CA3AF),
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: 10),
                          SizedBox(
                            width: 205,
                            height: 19,
                            child: Text(
                              'Ex: aminadiallo@gmail.com',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                height: 1.0,
                                letterSpacing: 0,
                                color: Color(0xFF9C9AA5),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    // Label Genre
                    Text(
                      'Genre',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 1.0,
                        letterSpacing: 0,
                        color: Color(0xFF212121),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Container Genre
                    Container(
                      width: 350,
                      height: 49,
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Color(0xFFF9F6F3),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedGender = 'Homme';
                              });
                            },
                            child: Container(
                              width: 161,
                              height: 37,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: selectedGender == 'Homme' ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: Text(
                                  'Homme',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: Color(0xFF222222),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedGender = 'Femme';
                                });
                              },
                              child: Container(
                                height: 37,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: selectedGender == 'Femme' ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: Text(
                                    'Femme',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      height: 1.0,
                                      letterSpacing: 0,
                                      color: Color(0xFF222222),
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
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 382,
        height: 64,
        margin: EdgeInsets.only(bottom: 0),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF23A3A6),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Text(
                'Enregistrer',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}