import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';

class NouvelleDemandeStep7Screen extends StatefulWidget {
  const NouvelleDemandeStep7Screen({super.key});

  @override
  State<NouvelleDemandeStep7Screen> createState() =>
      _NouvelleDemandeStep7ScreenState();
}

class _NouvelleDemandeStep7ScreenState
    extends State<NouvelleDemandeStep7Screen> {
  String? selectedBeneficiaire;

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
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusMedium),
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
              top: 105,
              left: 90,
              child: Text(
                'Banque Nationale',
                style: TextStyle(
                  fontFamily: 'Sofia Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 1.0,
                  letterSpacing: 0,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
            // Barre de progression
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
            // Titre "Détails à remplir"
            Positioned(
              top: 185,
              left: 24,
              child: Text(
                'Détails à remplir',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 24 / 16,
                  letterSpacing: 0,
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.7),
                ),
              ),
            ),
            // Container principal du formulaire
            Positioned(
              top: 240,
              left: 24,
              right: 24,
              child: Container(
                height: 343.1348876953125,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE8EEE7),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x08000000),
                      blurRadius: 3,
                      offset: const Offset(3, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label Bénéficiaire
                    Text(
                      'Bénéficiaire',
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
                    // Champ dropdown Bénéficiaire
                    GestureDetector(
                      onTap: () {
                        // Ouvrir overlay "Sélectionner un bénéficiaire"
                      },
                      child: Container(
                        width: 350,
                        height: 49.76744079589844,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFDEE8EE),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              // Icône personne
                              SvgPicture.asset(
                                'assets/icons/bi_person.svg',
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 12),
                              // Texte sélectionner bénéficiaire
                              Expanded(
                                child: Text(
                                  'Sélectionner bénéficiaire',
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
                              // Icône flèche vers le bas
                              GestureDetector(
                                onTap: () {
                                  _showBeneficiaireModal(context);
                                },
                                child: SvgPicture.asset(
                                  'assets/icons/mdi-light_chevron-down.svg',
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Label Montant (FCFA)
                    Text(
                      'Montant (FCFA)',
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
                    // Champ Montant
                    GestureDetector(
                      onTap: () {
                        // Action pour le champ montant
                      },
                      child: Container(
                        width: 350,
                        height: 49.76744079589844,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFDEE8EE),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              // Icône montant
                              SvgPicture.asset(
                                'assets/icons/bi_cash-stack.svg',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 12),
                              // Texte placeholder montant
                              Text(
                                'Ex: 150 000',
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
                    ),
                    const SizedBox(height: 24),
                    // Label Référence
                    Text(
                      'Référence',
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
                    // Champ Référence
                    GestureDetector(
                      onTap: () {
                        // Action pour le champ référence
                      },
                      child: Container(
                        width: 350,
                        height: 49.76744079589844,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFDEE8EE),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              // Texte placeholder référence
                              Text(
                                'Ex: Facture n°123',
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
                    ),
                  ],
                ),
              ),
            ),
            // Bouton Continuer
            Positioned(
              top: 780,
              left: 24,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/nouvelle-demande-step-8');
                },
                child: Container(
                  width: 382,
                  height: 56,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23A3A6),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      'Continuer',
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
            ),
          ],
        ),
      ),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: localSelectedBeneficiaire == 'cheikh'
                                    ? const Color(0xFF23A3A6)
                                    : const Color(0xFFDEE8EE),
                                width: localSelectedBeneficiaire == 'cheikh'
                                    ? 2
                                    : 1,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      color:
                                          localSelectedBeneficiaire == 'cheikh'
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: localSelectedBeneficiaire == 'maimouna'
                                    ? const Color(0xFF23A3A6)
                                    : const Color(0xFFDEE8EE),
                                width: localSelectedBeneficiaire == 'maimouna'
                                    ? 2
                                    : 1,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Maimouna Sow',
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
                                      color: localSelectedBeneficiaire ==
                                              'maimouna'
                                          ? const Color(0xFF23A3A6)
                                          : const Color(0xFF212121),
                                      width: 2.25,
                                    ),
                                    color:
                                        localSelectedBeneficiaire == 'maimouna'
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
                          padding:
                              const EdgeInsets.symmetric(horizontal: 11.94),
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
                          padding:
                              const EdgeInsets.symmetric(horizontal: 11.94),
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

class NouvelleDemandeStep10Screen extends StatelessWidget {
  const NouvelleDemandeStep10Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Nouvelle Demande Step 10 - À implémenter')),
    );
  }
}

class NouvelleDemandeStep11Screen extends StatelessWidget {
  const NouvelleDemandeStep11Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Nouvelle Demande Step 11 - À implémenter')),
    );
  }
}

class NouvelleDemandeStep12Screen extends StatelessWidget {
  const NouvelleDemandeStep12Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Nouvelle Demande Step 12 - À implémenter')),
    );
  }
}
