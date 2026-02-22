import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_constants.dart';

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
        width: AppConstants.screenWidth,
        height: AppConstants.screenHeight,
        color: AppColors.background,
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
            // Titre "Mes bénéficiaires"
            Positioned(
              top: 85,
              left: 73,
              right: AppConstants.paddingXLarge,
              child: Text(
                'Mes bénéficiaires',
                style: TextStyle(
                  fontFamily: AppConstants.fontFamilyInter,
                  fontWeight: FontWeight.w700,
                  fontSize: AppConstants.fontSizeXXLarge,
                  height: 1.0,
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Container blanc principal
            Positioned(
              top: 160,
              left: AppConstants.paddingXLarge,
              right: AppConstants.paddingXLarge,
              child: Container(
                height: 222,
                padding: EdgeInsets.fromLTRB(AppConstants.paddingLarge, AppConstants.paddingXLarge, AppConstants.paddingLarge, AppConstants.paddingXLarge),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Column(
                  children: [
                    // Premier bénéficiaire
                    Container(
                      width: 350,
                      height: AppConstants.cardHeight,
                      padding: EdgeInsets.all(AppConstants.fontSizeXXLarge),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        border: Border.all(color: AppColors.progressBar, width: AppConstants.borderWidthThin),
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
                                    fontFamily: AppConstants.fontFamilyInter,
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppConstants.fontSizeLarge,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: AppColors.cardSubtext,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'SN123 4567 8900',
                                  style: TextStyle(
                                    fontFamily: 'Geist',
                                    fontWeight: FontWeight.w500,
                                    fontSize: AppConstants.fontSizeMedium,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/icons/Vector (20).svg',
                            width: AppConstants.iconSizeMedium,
                            height: AppConstants.iconSizeMedium,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppConstants.paddingLarge),
                    // Deuxième bénéficiaire
                    Container(
                      width: 350,
                      height: AppConstants.cardHeight,
                      padding: EdgeInsets.all(AppConstants.fontSizeXXLarge),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        border: Border.all(color: AppColors.progressBar, width: AppConstants.borderWidthThin),
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
                                    fontFamily: AppConstants.fontFamilyInter,
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppConstants.fontSizeLarge,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: AppColors.cardSubtext,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'SN123 76543 0012',
                                  style: TextStyle(
                                    fontFamily: 'Geist',
                                    fontWeight: FontWeight.w500,
                                    fontSize: AppConstants.fontSizeMedium,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/icons/Vector (20).svg',
                            width: AppConstants.iconSizeMedium,
                            height: AppConstants.iconSizeMedium,
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
        height: AppConstants.buttonHeightLarge,
        margin: EdgeInsets.only(bottom: 0),
        child: GestureDetector(
          onTap: () {
            _showBeneficiaireModal(context);
          },
          child: Container(
            padding: EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/person-add.svg',
                  width: AppConstants.iconSizeMedium,
                  height: AppConstants.iconSizeMedium,
                  colorFilter: ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: AppConstants.paddingMedium),
                Text(
                  'Ajouter un nouveau bénéficiaire',
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    fontWeight: FontWeight.w600,
                    fontSize: AppConstants.fontSizeLarge,
                    color: AppColors.white,
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
          width: AppConstants.screenWidth,
          height: 420,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.fontSizeTitle),
          ),
          child: Stack(
            children: [
              // Rectangle 26 - Handle de la modal
              Positioned(
                top: AppConstants.paddingMedium,
                left: (AppConstants.screenWidth - AppConstants.modalHandleWidth) / 2,
                child: Container(
                  width: AppConstants.modalHandleWidth,
                  height: AppConstants.modalHandleHeight,
                  decoration: BoxDecoration(
                    color: AppColors.modalHandle,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              // Titre "Sélectionner un bénéficiaire" avec icône fermeture
              Positioned(
                top: 40,
                left: AppConstants.paddingXLarge,
                right: AppConstants.paddingXLarge,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sélectionner un bénéficiaire',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontWeight: FontWeight.w600,
                        fontSize: AppConstants.fontSizeXXLarge,
                        height: 32 / 20,
                        letterSpacing: 0,
                        color: AppColors.textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: SvgPicture.asset(
                        'assets/icons/Vector (18).svg',
                        width: AppConstants.iconSizeSmall,
                        height: AppConstants.iconSizeSmall,
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
                        color: AppColors.borderE5,
                        width: AppConstants.borderWidthThin,
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppConstants.paddingXLarge),
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
                            margin: EdgeInsets.only(left: 10, right: AppConstants.paddingXLarge),
                            width: 382,
                            height: 75,
                            padding: EdgeInsets.symmetric(horizontal: AppConstants.fontSizeXXLarge, vertical: AppConstants.paddingLarge),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              border: Border.all(
                                color: localSelectedBeneficiaire == 'cheikh' 
                                    ? AppColors.primary 
                                    : AppColors.progressBar,
                                width: localSelectedBeneficiaire == 'cheikh' ? AppConstants.borderWidthThick : AppConstants.borderWidthThin,
                              ),
                              color: localSelectedBeneficiaire == 'cheikh' 
                                  ? AppColors.primaryOverlay 
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
                                          fontSize: AppConstants.fontSizeLarge,
                                          height: 1.0,
                                          letterSpacing: 0,
                                          color: AppColors.cardSubtext,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'SN123 4567 8900',
                                        style: TextStyle(
                                          fontFamily: 'Geist',
                                          fontWeight: FontWeight.w500,
                                          fontSize: AppConstants.fontSizeMedium,
                                          height: 1.0,
                                          letterSpacing: 0,
                                          color: AppColors.textSecondary,
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
                                          ? AppColors.primary 
                                          : AppColors.textDark,
                                      width: 2.25,
                                    ),
                                    color: localSelectedBeneficiaire == 'cheikh' 
                                        ? AppColors.primary 
                                        : Colors.transparent,
                                  ),
                                  child: localSelectedBeneficiaire == 'cheikh'
                                      ? Icon(
                                          Icons.check,
                                          color: AppColors.white,
                                          size: AppConstants.paddingMedium,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: AppConstants.fontSizeXXLarge),
                        // Deuxième container bénéficiaire
                        GestureDetector(
                          onTap: () {
                            setModalState(() {
                              localSelectedBeneficiaire = 'maimouna';
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 10, right: AppConstants.paddingXLarge),
                            width: 382,
                            height: 75,
                            padding: EdgeInsets.symmetric(horizontal: AppConstants.fontSizeXXLarge, vertical: AppConstants.paddingLarge),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              border: Border.all(
                                color: localSelectedBeneficiaire == 'maimouna' 
                                    ? AppColors.primary 
                                    : AppColors.progressBar,
                                width: localSelectedBeneficiaire == 'maimouna' ? AppConstants.borderWidthThick : AppConstants.borderWidthThin,
                              ),
                              color: localSelectedBeneficiaire == 'maimouna' 
                                  ? AppColors.primaryOverlay 
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
                                          fontSize: AppConstants.fontSizeLarge,
                                          height: 1.0,
                                          letterSpacing: 0,
                                          color: AppColors.cardSubtext,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'SN123 76543 0012',
                                        style: TextStyle(
                                          fontFamily: 'Geist',
                                          fontWeight: FontWeight.w500,
                                          fontSize: AppConstants.fontSizeMedium,
                                          height: 1.0,
                                          letterSpacing: 0,
                                          color: AppColors.textSecondary,
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
                                          ? AppColors.primary 
                                          : AppColors.textDark,
                                      width: 2.25,
                                    ),
                                    color: localSelectedBeneficiaire == 'maimouna' 
                                        ? AppColors.primary 
                                        : Colors.transparent,
                                  ),
                                  child: localSelectedBeneficiaire == 'maimouna'
                                      ? Icon(
                                          Icons.check,
                                          color: AppColors.white,
                                          size: AppConstants.paddingMedium,
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
                            margin: EdgeInsets.only(left: 10, right: AppConstants.paddingXLarge),
                            width: 382,
                            height: AppConstants.buttonHeight,
                            padding: EdgeInsets.all(AppConstants.paddingMedium),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icône person-add
                                SvgPicture.asset(
                                  'assets/icons/person-add.svg',
                                  width: AppConstants.iconSizeMedium,
                                  height: AppConstants.iconSizeMedium,
                                ),
                                SizedBox(width: AppConstants.paddingMedium),
                                // Texte du bouton
                                Text(
                                  'Ajouter un nouveau bénéficiaire',
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamilySofiaSans,
                                    fontWeight: FontWeight.w500,
                                    fontSize: AppConstants.fontSizeLarge,
                                    height: 1.5,
                                    letterSpacing: 0,
                                    color: AppColors.white,
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
        width: AppConstants.screenWidth,
        height: 420,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.fontSizeTitle),
        ),
        child: Stack(
          children: [
            // Rectangle 26 - Handle de la modal
            Positioned(
              top: AppConstants.paddingMedium,
              left: (AppConstants.screenWidth - AppConstants.modalHandleWidth) / 2,
              child: Container(
                width: AppConstants.modalHandleWidth,
                height: AppConstants.modalHandleHeight,
                decoration: BoxDecoration(
                  color: AppColors.modalHandle,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            // Titre "Ajouter un bénéficiaire" avec icône fermeture
            Positioned(
              top: 40,
              left: AppConstants.paddingXLarge,
              right: AppConstants.paddingXLarge,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ajouter un bénéficiaire',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamilyInter,
                      fontWeight: FontWeight.w600,
                      fontSize: AppConstants.fontSizeXXLarge,
                      height: 32 / 20,
                      letterSpacing: 0,
                      color: AppColors.textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: SvgPicture.asset(
                      'assets/icons/Vector (18).svg',
                      width: AppConstants.iconSizeSmall,
                      height: AppConstants.iconSizeSmall,
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
                      color: AppColors.borderE5,
                      width: AppConstants.borderWidthThin,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppConstants.paddingXLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label Nom du bénéficiaire
                      Text(
                        'Nom du bénéficiaire',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w500,
                          fontSize: AppConstants.fontSizeMedium,
                          height: 1.0,
                          letterSpacing: 0,
                          color: AppColors.cardSubtext,
                        ),
                      ),
                      SizedBox(height: AppConstants.paddingSmall),
                      // Champ Nom du bénéficiaire
                      Container(
                        width: 382,
                        height: 49.76744079589844,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7.96),
                          border: Border.all(
                            color: AppColors.progressBar,
                            width: AppConstants.borderWidthThin,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 11.94),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/bi_person.svg',
                                width: AppConstants.iconSizeSmall,
                                height: AppConstants.iconSizeSmall,
                              ),
                              const SizedBox(width: 9.95),
                              Text(
                                'Ex: Cheikh Gueye',
                                style: TextStyle(
                                  fontFamily: AppConstants.fontFamilyInter,
                                  fontWeight: FontWeight.w400,
                                  fontSize: AppConstants.fontSizeRegular,
                                  height: 1.0,
                                  letterSpacing: 0,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppConstants.paddingXLarge),
                      // Label IBAN
                      Text(
                        'IBAN',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w500,
                          fontSize: AppConstants.fontSizeMedium,
                          height: 1.0,
                          letterSpacing: 0,
                          color: AppColors.cardSubtext,
                        ),
                      ),
                      SizedBox(height: AppConstants.paddingSmall),
                      // Champ IBAN
                      Container(
                        width: 382,
                        height: 49.76744079589844,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7.96),
                          border: Border.all(
                            color: AppColors.progressBar,
                            width: AppConstants.borderWidthThin,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 11.94),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/credit-card-2-front.svg',
                                width: AppConstants.iconSizeSmall,
                                height: AppConstants.iconSizeSmall,
                              ),
                              const SizedBox(width: 9.95),
                              Text(
                                'Ex: SN123 4567 8900',
                                style: TextStyle(
                                  fontFamily: AppConstants.fontFamilyInter,
                                  fontWeight: FontWeight.w400,
                                  fontSize: AppConstants.fontSizeRegular,
                                  height: 1.0,
                                  letterSpacing: 0,
                                  color: AppColors.textSecondary,
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
                          margin: EdgeInsets.only(left: 10, right: AppConstants.paddingXLarge),
                          width: 382,
                          height: AppConstants.buttonHeight,
                          padding: EdgeInsets.all(AppConstants.paddingMedium),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                          ),
                          child: Center(
                            child: Text(
                              'Ajouter',
                              style: TextStyle(
                                fontFamily: AppConstants.fontFamilySofiaSans,
                                fontWeight: FontWeight.w500,
                                fontSize: AppConstants.fontSizeLarge,
                                height: 1.5,
                                letterSpacing: 0,
                                color: AppColors.white,
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
