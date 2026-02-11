import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'client_informations_personnelles_screen.dart';
import 'mes_beneficiaires_screen.dart';
import 'mes_documents_screen.dart';
import '../../../../utils/responsive_utils.dart';

class ClientProfilScreen extends StatefulWidget {
  const ClientProfilScreen({super.key});

  @override
  State<ClientProfilScreen> createState() => _ClientProfilScreenState();
}

class _ClientProfilScreenState extends State<ClientProfilScreen> {
  String selectedLanguage = 'Français';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: ResponsiveUtils.getScreenWidth(context),
        height: ResponsiveUtils.getScreenHeight(context),
        color: const Color(0xFF0B3C5C),
        child: Stack(
          children: [
            // Bouton retour
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 70),
              left: ResponsiveUtils.getResponsiveWidth(context, 24),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: ResponsiveUtils.getResponsiveWidth(context, 50),
                  height: ResponsiveUtils.getResponsiveHeight(context, 50),
                  decoration: BoxDecoration(
                    color: const Color(0x14FFFFFF),
                    borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, 12)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: ResponsiveUtils.getResponsiveValue(context, 21.4),
                    ),
                  ),
                ),
              ),
            ),
            // Titre "Mon compte"
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 85),
              left: 0,
              right: 0,
              child: Text(
                'Mon compte',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                  height: 1.0,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Avatar "LD"
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 140),
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: ResponsiveUtils.getResponsiveWidth(context, 100),
                  height: ResponsiveUtils.getResponsiveHeight(context, 100),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveValue(context, 125),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: ResponsiveUtils.getResponsiveHeight(context, 4),
                        left: ResponsiveUtils.getResponsiveWidth(context, 4),
                        child: Container(
                          width: ResponsiveUtils.getResponsiveWidth(context, 92),
                          height: ResponsiveUtils.getResponsiveHeight(context, 92),
                          decoration: BoxDecoration(
                            color: const Color(0xFF23A3A6),
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.getResponsiveValue(context, 125),
                            ),
                            border: Border.all(color: const Color(0xFF0B3C5C), width: 4),
                          ),
                          child: Center(
                            child: Text(
                              'LD',
                              style: TextStyle(
                                fontFamily: 'Sofia Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 36),
                                height: 1.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Nom utilisateur "Lamine DIEME"
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 260),
              left: 0,
              right: 0,
              child: Text(
                'Lamine DIEME',
                style: TextStyle(
                  fontFamily: 'Sofia Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
                  height: 1.0,
                  letterSpacing: 0,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Numéro de téléphone
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 285),
              left: 0,
              right: 0,
              child: Text(
                '77 123 45 67',
                style: TextStyle(
                  fontFamily: 'Sofia Sans',
                  fontWeight: FontWeight.w400,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  height: 30 / 16,
                  letterSpacing: 0,
                  color: Colors.white.withValues(alpha:0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Cartes container
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 330),
              left: ResponsiveUtils.getResponsiveWidth(context, 24),
              right: ResponsiveUtils.getResponsiveWidth(context, 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: ResponsiveUtils.getResponsiveHeight(context, 82),
                      padding: EdgeInsets.fromLTRB(
                        ResponsiveUtils.getResponsiveWidth(context, 12),
                        ResponsiveUtils.getResponsiveHeight(context, 16),
                        ResponsiveUtils.getResponsiveWidth(context, 12),
                        ResponsiveUtils.getResponsiveHeight(context, 16),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveValue(context, 8),
                        ),
                        border: Border.all(color: Color(0xFFE8EEE7), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x08000000),
                            offset: Offset(
                              ResponsiveUtils.getResponsiveValue(context, 3),
                              ResponsiveUtils.getResponsiveValue(context, 3),
                            ),
                            blurRadius: ResponsiveUtils.getResponsiveValue(context, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Total demandes',
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w500,
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 4)),
                                Text(
                                  '12',
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                                    height: 1.2,
                                    letterSpacing: 0,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/icons/logo.svg',
                            width: ResponsiveUtils.getResponsiveWidth(context, 32),
                            height: ResponsiveUtils.getResponsiveHeight(context, 32),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 16)),
                  Expanded(
                    child: Container(
                      height: ResponsiveUtils.getResponsiveHeight(context, 82),
                      padding: EdgeInsets.fromLTRB(
                        ResponsiveUtils.getResponsiveWidth(context, 12),
                        ResponsiveUtils.getResponsiveHeight(context, 16),
                        ResponsiveUtils.getResponsiveWidth(context, 12),
                        ResponsiveUtils.getResponsiveHeight(context, 16),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveValue(context, 8),
                        ),
                        border: Border.all(color: Color(0xFFE8EEE7), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x08000000),
                            offset: Offset(
                              ResponsiveUtils.getResponsiveValue(context, 3),
                              ResponsiveUtils.getResponsiveValue(context, 3),
                            ),
                            blurRadius: ResponsiveUtils.getResponsiveValue(context, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'En cours',
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w500,
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 4)),
                                Text(
                                  '10',
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                                    height: 1.2,
                                    letterSpacing: 0,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/icons/bi_clock-history.svg',
                            width: ResponsiveUtils.getResponsiveWidth(context, 24),
                            height: ResponsiveUtils.getResponsiveHeight(context, 24),
                            colorFilter: ColorFilter.mode(
                              Color(0xFF3B83F6),
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Deuxième rangée de cartes
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 428),
              left: ResponsiveUtils.getResponsiveWidth(context, 24),
              right: ResponsiveUtils.getResponsiveWidth(context, 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: ResponsiveUtils.getResponsiveHeight(context, 82),
                      padding: EdgeInsets.fromLTRB(
                        ResponsiveUtils.getResponsiveWidth(context, 12),
                        ResponsiveUtils.getResponsiveHeight(context, 16),
                        ResponsiveUtils.getResponsiveWidth(context, 12),
                        ResponsiveUtils.getResponsiveHeight(context, 16),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveValue(context, 8),
                        ),
                        border: Border.all(color: Color(0xFFE8EEE7), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x08000000),
                            offset: Offset(
                              ResponsiveUtils.getResponsiveValue(context, 3),
                              ResponsiveUtils.getResponsiveValue(context, 3),
                            ),
                            blurRadius: ResponsiveUtils.getResponsiveValue(context, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Brouillons',
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w500,
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 4)),
                                Text(
                                  '01',
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                                    height: 1.2,
                                    letterSpacing: 0,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/icons/carbon_rule-draft.svg',
                            width: ResponsiveUtils.getResponsiveWidth(context, 24),
                            height: ResponsiveUtils.getResponsiveHeight(context, 24),
                            colorFilter: ColorFilter.mode(
                              Colors.black.withValues(alpha:0.8),
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: ResponsiveUtils.getResponsiveHeight(context, 82),
                      padding: EdgeInsets.fromLTRB(
                        ResponsiveUtils.getResponsiveWidth(context, 12),
                        ResponsiveUtils.getResponsiveHeight(context, 16),
                        ResponsiveUtils.getResponsiveWidth(context, 12),
                        ResponsiveUtils.getResponsiveHeight(context, 16),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveValue(context, 8),
                        ),
                        border: Border.all(color: Color(0xFFE8EEE7), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x08000000),
                            offset: Offset(
                              ResponsiveUtils.getResponsiveValue(context, 3),
                              ResponsiveUtils.getResponsiveValue(context, 3),
                            ),
                            blurRadius: ResponsiveUtils.getResponsiveValue(context, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Complétés',
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w500,
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 4)),
                                Text(
                                  '10',
                                  style: TextStyle(
                                    fontFamily: 'Sofia Sans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                                    height: 1.2,
                                    letterSpacing: 0,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/icons/bi_check2-circle (1).svg',
                            width: ResponsiveUtils.getResponsiveWidth(context, 24),
                            height: ResponsiveUtils.getResponsiveHeight(context, 24),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Nouveau container en bas
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 523),
              left: ResponsiveUtils.getResponsiveWidth(context, 24),
              right: ResponsiveUtils.getResponsiveWidth(context, 24),
              child: Container(
                height: ResponsiveUtils.getResponsiveHeight(context, 250),
                padding: EdgeInsets.all(ResponsiveUtils.getResponsiveValue(context, 24)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveValue(context, 8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 8)),
                    // Informations personnelles
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClientInformationsPersonnellesScreen(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/bi_person-circle.svg',
                            width: ResponsiveUtils.getResponsiveWidth(context, 24),
                            height: ResponsiveUtils.getResponsiveHeight(context, 24),
                            colorFilter: ColorFilter.mode(
                              Color(0xFF23A3A6),
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 16)),
                          Expanded(
                            child: Text(
                              'Informations personnelles',
                              style: TextStyle(
                                fontFamily: 'Sofia Sans',
                                fontWeight: FontWeight.w500,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Color(0xFF9CA3AF),
                            size: ResponsiveUtils.getResponsiveValue(context, 20),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 32)),
                    // Mes bénéficiaires
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MesBeneficiairesScreen(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/bi_people (3).svg',
                            width: ResponsiveUtils.getResponsiveWidth(context, 24),
                            height: ResponsiveUtils.getResponsiveHeight(context, 24),
                            colorFilter: ColorFilter.mode(
                              Color(0xFF23A3A6),
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 16)),
                          Expanded(
                            child: Text(
                              'Mes bénéficiaires',
                              style: TextStyle(
                                fontFamily: 'Sofia Sans',
                                fontWeight: FontWeight.w500,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Color(0xFF9CA3AF),
                            size: ResponsiveUtils.getResponsiveValue(context, 20),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 32)),
                    // Mes documents
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MesDocumentsScreen(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/bi_file-earmark-text.svg',
                            width: ResponsiveUtils.getResponsiveWidth(context, 24),
                            height: ResponsiveUtils.getResponsiveHeight(context, 24),
                            colorFilter: ColorFilter.mode(
                              Color(0xFF23A3A6),
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 16)),
                          Expanded(
                            child: Text(
                              'Mes documents',
                              style: TextStyle(
                                fontFamily: 'Sofia Sans',
                                fontWeight: FontWeight.w500,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Color(0xFF9CA3AF),
                            size: ResponsiveUtils.getResponsiveValue(context, 20),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 32)),
                    // Langue
                    GestureDetector(
                      onTap: () {
                        _showLangueModal(context);
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/material-symbols-light_language.svg',
                            width: ResponsiveUtils.getResponsiveWidth(context, 24),
                            height: ResponsiveUtils.getResponsiveHeight(context, 24),
                            colorFilter: ColorFilter.mode(
                              Color(0xFF23A3A6),
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 16)),
                          Expanded(
                            child: Text(
                              'Langue',
                              style: TextStyle(
                                fontFamily: 'Sofia Sans',
                                fontWeight: FontWeight.w500,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                          Text(
                            selectedLanguage,
                            style: TextStyle(
                              fontFamily: 'Sofia Sans',
                              fontWeight: FontWeight.w400,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 8)),
                          Icon(
                            Icons.chevron_right,
                            color: Color(0xFF9CA3AF),
                            size: ResponsiveUtils.getResponsiveValue(context, 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bouton de déconnexion
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 783),
              left: ResponsiveUtils.getResponsiveWidth(context, 20),
              right: ResponsiveUtils.getResponsiveWidth(context, 20),
              child: GestureDetector(
                onTap: () {
                  _showDeconnexionModal(context);
                },
                child: Container(
                  height: ResponsiveUtils.getResponsiveHeight(context, 60),
                  padding: EdgeInsets.all(ResponsiveUtils.getResponsiveValue(context, 20)),
                  decoration: BoxDecoration(
                    color: Color(0xFF0A324A),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveValue(context, 100),
                    ),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/bi_box-arrow-left.svg',
                        width: ResponsiveUtils.getResponsiveWidth(context, 24),
                        height: ResponsiveUtils.getResponsiveHeight(context, 24),
                        colorFilter: ColorFilter.mode(
                          Color(0xFF23A3A6),
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.getResponsiveWidth(context, 12)),
                      Text(
                        'Se déconnecter',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                          height: 1.0,
                          letterSpacing: 0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLangueModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: ResponsiveUtils.getResponsiveHeight(context, 280),
        margin: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getResponsiveWidth(context, 8)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, 24)),
        ),
        child: Stack(
          children: [
            // Handle de la modal
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 12),
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: ResponsiveUtils.getResponsiveWidth(context, 40),
                  height: ResponsiveUtils.getResponsiveHeight(context, 4),
                  decoration: BoxDecoration(
                    color: const Color(0x80212121),
                    borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, 999)),
                  ),
                ),
              ),
            ),
            // Titre "Changer la langue" avec icône fermeture
            Positioned(
              top: ResponsiveUtils.getResponsiveHeight(context, 40),
              left: ResponsiveUtils.getResponsiveWidth(context, 24),
              right: ResponsiveUtils.getResponsiveWidth(context, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Changer la langue',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                      height: 32 / 20,
                      letterSpacing: 0,
                      color: const Color(0xFF212121),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.close,
                      size: ResponsiveUtils.getResponsiveValue(context, 24),
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            // Container principal du contenu
            Positioned(
              top: 105,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFFE5E5E5),
                      width: 1,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Option Français
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedLanguage = 'Français';
                            });
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 56,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: selectedLanguage == 'Français' ? Color(0xFFF0FDFA) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selectedLanguage == 'Français' ? Color(0xFF23A3A6) : Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/image 2.png',
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Français',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ),
                                if (selectedLanguage == 'Français')
                                  Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF23A3A6),
                                    size: 20,
                                  )
                                else
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFFD1D5DB),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        // Option Anglais
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedLanguage = 'Anglais';
                            });
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 56,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: selectedLanguage == 'Anglais' ? Color(0xFFF0FDFA) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selectedLanguage == 'Anglais' ? Color(0xFF23A3A6) : Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/image 3.png',
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Anglais',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ),
                                if (selectedLanguage == 'Anglais')
                                  Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF23A3A6),
                                    size: 20,
                                  )
                                else
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFFD1D5DB),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  void _showDeconnexionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: ResponsiveUtils.getResponsiveHeight(context, 240),
        margin: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getResponsiveWidth(context, 8)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, 24)),
        ),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.getResponsiveValue(context, 24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Déconnexion',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
                  height: 32 / 24,
                  letterSpacing: 0,
                  color: Color(0xFF212121),
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 12)),
              Text(
                'Êtes-vous sûr de vouloir vous déconnectez ?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                  height: 32 / 18,
                  letterSpacing: 0,
                  color: Color(0xFF4F4F4F),
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 20)),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: ResponsiveUtils.getResponsiveHeight(context, 44),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, 8)),
                        ),
                        child: Center(
                          child: Text(
                            'Annuler',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: ResponsiveUtils.getResponsiveWidth(context, 2),
                    height: ResponsiveUtils.getResponsiveHeight(context, 20),
                    color: Color(0xFFD9D9D9),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login',
                          (route) => false,
                        );
                      },
                      child: Container(
                        height: ResponsiveUtils.getResponsiveHeight(context, 44),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, 8)),
                        ),
                        child: Center(
                          child: Text(
                            'Se déconnecter',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                              color: Color(0xFF23A3A6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}