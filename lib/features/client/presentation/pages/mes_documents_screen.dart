import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MesDocumentsScreen extends StatefulWidget {
  const MesDocumentsScreen({super.key});

  @override
  State<MesDocumentsScreen> createState() => _MesDocumentsScreenState();
}

class _MesDocumentsScreenState extends State<MesDocumentsScreen> {
  String? selectedDocument;

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
            // Titre "Mes documents"
            Positioned(
              top: 85,
              left: 60,
              right: 24,
              child: Text(
                'Mes documents',
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
              top: 160,
              left: 24,
              right: 24,
              child: Container(
                height: 222,
                padding: EdgeInsets.fromLTRB(16, 24, 16, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Premier document
                    Container(
                      width: 350,
                      height: 79,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFDEE8EE), width: 1),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Certificat de résidence',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: Color(0xFF343741),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Ajouté le 28 déc. 2025',
                                  style: TextStyle(
                                    fontFamily: 'Geist',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/icons/Vector (20).svg',
                            width: 20,
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    // Deuxième document
                    Container(
                      width: 350,
                      height: 79,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFDEE8EE), width: 1),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'CNI',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: Color(0xFF343741),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Ajouté le 27 déc. 2025',
                                  style: TextStyle(
                                    fontFamily: 'Geist',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/icons/Vector (20).svg',
                            width: 20,
                            height: 20,
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
            _showAjouterDocumentModal(context);
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF23A3A6),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/bi_file-earmark-text.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Ajouter un document',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showAjouterDocumentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        width: 430,
        height: 500,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Handle de la modal
            Positioned(
              top: 12,
              left: (430 - 40) / 2,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0x80212121),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            // Titre "Ajouter un bénéficiaire" avec icône fermeture
            Positioned(
              top: 40,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ajouter un document',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      height: 32 / 20,
                      letterSpacing: 0,
                      color: const Color(0xFF212121),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: SvgPicture.asset(
                      'assets/icons/Vector (18).svg',
                      width: 16,
                      height: 16,
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label Type de document
                      Text(
                        'Type de document',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.0,
                          letterSpacing: 0,
                          color: const Color(0xFF343741),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Dropdown Sélectionner
                      Container(
                        width: 382,
                        height: 49.76744079589844,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7.96),
                          border: Border.all(
                            color: const Color(0xFFDEE8EE),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 11.94),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Sélectionner',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF9CA3AF),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Zone de téléchargement
                      Container(
                        width: 382,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF23A3A6),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/bi_cloud-upload.svg',
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                Color(0xFF23A3A6),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cliquez pour télécharger',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                height: 1.0,
                                letterSpacing: 0,
                                color: const Color(0xFF212121),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PDF, JPG, PNG jusqu\'à 10 Mo',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 1.0,
                                letterSpacing: 0,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Bouton Ajouter
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 10, right: 24),
                          width: 382,
                          height: 64,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF23A3A6),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              'Ajouter',
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
}