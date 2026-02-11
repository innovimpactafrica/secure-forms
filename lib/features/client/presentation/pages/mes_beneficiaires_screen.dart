import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MesBeneficiairesScreen extends StatefulWidget {
  const MesBeneficiairesScreen({super.key});

  @override
  State<MesBeneficiairesScreen> createState() => _MesBeneficiairesScreenState();
}

class _MesBeneficiairesScreenState extends State<MesBeneficiairesScreen> {
  String? selectedBeneficiaire;

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
            // Titre "Mes bénéficiaires"
            Positioned(
              top: 85,
              left: 73,
              right: 24,
              child: Text(
                'Mes bénéficiaires',
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
                    // Premier bénéficiaire
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
                                  'Cheikh GUEYE',
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
                                  'SN123 4567 8900',
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
                    // Deuxième bénéficiaire
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
                                  'Maimouna SOW',
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
                                  'SN123 76543 0012',
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
            _showBeneficiaireModal(context);
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
                  'assets/icons/person-add.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Ajouter un nouveau bénéficiaire',
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

  void _showBeneficiaireModal(BuildContext context) {
    String? localSelectedBeneficiaire = selectedBeneficiaire;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          width: 430,
          height: 420,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              // Rectangle 26 - Handle de la modal
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
              // Titre "Sélectionner un bénéficiaire" avec icône fermeture
              Positioned(
                top: 40,
                left: 24,
                right: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sélectionner un bénéficiaire',
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Premier container bénéficiaire
                        GestureDetector(
                          onTap: () {
                            setModalState(() {
                              localSelectedBeneficiaire = 'cheikh';
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10, right: 24),
                            width: 382,
                            height: 75,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: localSelectedBeneficiaire == 'cheikh' 
                                    ? const Color(0xFF23A3A6) 
                                    : const Color(0xFFDEE8EE),
                                width: localSelectedBeneficiaire == 'cheikh' ? 2 : 1,
                              ),
                              color: localSelectedBeneficiaire == 'cheikh' 
                                  ? const Color(0x0D23A3A6) 
                                  : Colors.transparent,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Nom du bénéficiaire
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cheikh GUEYE',
                                        style: TextStyle(
                                          fontFamily: 'Geist',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          height: 1.0,
                                          letterSpacing: 0,
                                          color: const Color(0xFF343741),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'SN123 4567 8900',
                                        style: TextStyle(
                                          fontFamily: 'Geist',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          height: 1.0,
                                          letterSpacing: 0,
                                          color: const Color(0xFF6B7280),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // Cercle check/uncheck
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: localSelectedBeneficiaire == 'cheikh' 
                                          ? const Color(0xFF23A3A6) 
                                          : const Color(0xFF212121),
                                      width: 2.25,
                                    ),
                                    color: localSelectedBeneficiaire == 'cheikh' 
                                        ? const Color(0xFF23A3A6) 
                                        : Colors.transparent,
                                  ),
                                  child: localSelectedBeneficiaire == 'cheikh'
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 12,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Deuxième container bénéficiaire
                        GestureDetector(
                          onTap: () {
                            setModalState(() {
                              localSelectedBeneficiaire = 'maimouna';
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10, right: 24),
                            width: 382,
                            height: 75,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: localSelectedBeneficiaire == 'maimouna' 
                                    ? const Color(0xFF23A3A6) 
                                    : const Color(0xFFDEE8EE),
                                width: localSelectedBeneficiaire == 'maimouna' ? 2 : 1,
                              ),
                              color: localSelectedBeneficiaire == 'maimouna' 
                                  ? const Color(0x0D23A3A6) 
                                  : Colors.transparent,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Nom du bénéficiaire
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Maimouna SOW',
                                        style: TextStyle(
                                          fontFamily: 'Geist',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          height: 1.0,
                                          letterSpacing: 0,
                                          color: const Color(0xFF343741),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'SN123 76543 0012',
                                        style: TextStyle(
                                          fontFamily: 'Geist',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          height: 1.0,
                                          letterSpacing: 0,
                                          color: const Color(0xFF6B7280),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // Cercle check/uncheck
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: localSelectedBeneficiaire == 'maimouna' 
                                          ? const Color(0xFF23A3A6) 
                                          : const Color(0xFF212121),
                                      width: 2.25,
                                    ),
                                    color: localSelectedBeneficiaire == 'maimouna' 
                                        ? const Color(0xFF23A3A6) 
                                        : Colors.transparent,
                                  ),
                                  child: localSelectedBeneficiaire == 'maimouna'
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 12,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Bouton Ajouter un nouveau bénéficiaire
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            _showAjouterBeneficiaireModal(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10, right: 24),
                            width: 382,
                            height: 56,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF23A3A6),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icône person-add
                                SvgPicture.asset(
                                  'assets/icons/person-add.svg',
                                  width: 20,
                                  height: 20,
                                ),
                                const SizedBox(width: 12),
                                // Texte du bouton
                                Text(
                                  'Ajouter un nouveau bénéficiaire',
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
                              ],
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
      ),
    ).then((_) {
      // Mettre à jour l'état principal quand la modal se ferme
      setState(() {
        selectedBeneficiaire = localSelectedBeneficiaire;
      });
    });
  }

  void _showAjouterBeneficiaireModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        width: 430,
        height: 420,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Rectangle 26 - Handle de la modal
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
                    'Ajouter un bénéficiaire',
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
                      // Label Nom du bénéficiaire
                      Text(
                        'Nom du bénéficiaire',
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
                      // Champ Nom du bénéficiaire
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
                              SvgPicture.asset(
                                'assets/icons/bi_person.svg',
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 9.95),
                              Text(
                                'Ex: Cheikh Gueye',
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
                      ),
                      const SizedBox(height: 24),
                      // Label IBAN
                      Text(
                        'IBAN',
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
                      // Champ IBAN
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
                              SvgPicture.asset(
                                'assets/icons/credit-card-2-front.svg',
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 9.95),
                              Text(
                                'Ex: SN123 4567 8900',
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
                          height: 56,
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