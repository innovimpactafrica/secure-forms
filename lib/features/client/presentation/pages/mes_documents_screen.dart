import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_constants.dart';

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
            // Titre "Mes documents"
            Positioned(
              top: 85,
              left: 60,
              right: AppConstants.paddingXLarge,
              child: Text(
                'Mes documents',
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
                    // Premier document
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
                                  'Certificat de résidence',
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
                                  'Ajouté le 28 déc. 2025',
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
                    // Deuxième document
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
                                  'CNI',
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
                                  'Ajouté le 27 déc. 2025',
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
            _showAjouterDocumentModal(context);
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
                  'assets/icons/bi_file-earmark-text.svg',
                  width: AppConstants.iconSizeMedium,
                  height: AppConstants.iconSizeMedium,
                  colorFilter: ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: AppConstants.paddingMedium),
                Text(
                  'Ajouter un document',
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

  void _showAjouterDocumentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        width: AppConstants.screenWidth,
        height: 500,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.fontSizeTitle),
        ),
        child: Stack(
          children: [
            // Handle de la modal
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
                    'Ajouter un document',
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
                      // Label Type de document
                      Text(
                        'Type de document',
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
                      // Dropdown Sélectionner
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
                              Expanded(
                                child: Text(
                                  'Sélectionner',
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamilyInter,
                                    fontWeight: FontWeight.w400,
                                    fontSize: AppConstants.fontSizeRegular,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.iconGray,
                                size: AppConstants.iconSizeSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppConstants.paddingXLarge),
                      // Zone de téléchargement
                      Container(
                        width: 382,
                        height: AppConstants.cardActionHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                          border: Border.all(
                            color: AppColors.primary,
                            width: AppConstants.borderWidthThick,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/bi_cloud-upload.svg',
                              width: AppConstants.iconSizeLarge,
                              height: AppConstants.iconSizeLarge,
                              colorFilter: ColorFilter.mode(
                                AppColors.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(height: AppConstants.paddingSmall),
                            Text(
                              'Cliquez pour télécharger',
                              style: TextStyle(
                                fontFamily: AppConstants.fontFamilyInter,
                                fontWeight: FontWeight.w600,
                                fontSize: AppConstants.fontSizeMedium,
                                height: 1.0,
                                letterSpacing: 0,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PDF, JPG, PNG jusqu\'à 10 Mo',
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
                      const SizedBox(height: 32),
                      // Bouton Ajouter
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 10, right: AppConstants.paddingXLarge),
                          width: 382,
                          height: AppConstants.buttonHeightLarge,
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
