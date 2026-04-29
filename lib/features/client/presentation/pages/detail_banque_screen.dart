import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/core/widgets/auth_image.dart';
import 'package:secure_link/features/client/data/models/banque_model.dart';
import 'package:secure_link/features/client/data/models/compte_model.dart';
import 'package:secure_link/features/client/domain/bloc/detail_banque_bloc/detail_banque_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/detail_banque_bloc/detail_banque_event.dart';
import 'package:secure_link/features/client/domain/bloc/detail_banque_bloc/detail_banque_state.dart';

class DetailBanqueScreen extends StatefulWidget {
  final BanqueModel banque;
  const DetailBanqueScreen({super.key, required this.banque});

  @override
  State<DetailBanqueScreen> createState() => _DetailBanqueScreenState();
}

class _DetailBanqueScreenState extends State<DetailBanqueScreen> {
  late final DetailBanqueBloc _bloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = DetailBanqueBloc()..add(LoadComptesEvent(widget.banque.id));
  }

  @override
  void dispose() {
    _bloc.close();
    _searchController.dispose();
    super.dispose();
  }

  void _showAjouterCompteModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusLarge)),
      ),
      builder: (_) => BlocProvider.value(
        value: _bloc,
        child: _AjouterCompteModal(banque: widget.banque),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<DetailBanqueBloc, DetailBanqueState>(
        listener: (context, state) {
          if (state is CompteAjouteState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'banques.compte_ajoute'.tr(),
                  style: const TextStyle(color: AppColors.white),
                ),
                backgroundColor: AppColors.statusValideGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
              ),
            );
          } else if (state is CompteAjoutErreurState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(color: AppColors.white),
                ),
                backgroundColor: AppColors.statusRejected,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildSearchBar(),
                const SizedBox(height: AppConstants.paddingMedium),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAjouterCompteModal(context),
            backgroundColor: AppColors.backArrowColor,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: AppColors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingLarge,
        AppConstants.paddingLarge,
        AppConstants.paddingLarge,
        AppConstants.paddingXLarge,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: AppConstants.avatarSizeSmall,
              height: AppConstants.avatarSizeSmall,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: const Icon(Icons.arrow_back,
                  color: AppColors.white, size: AppConstants.iconSizeMedium),
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.banque.nom,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'banques.detail_subtitle'.tr(),
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeRegular,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          border: Border.all(color: AppColors.borderDivider),
        ),
        child: Row(
          children: [
            const SizedBox(width: AppConstants.paddingMedium),
            const Icon(Icons.search,
                size: AppConstants.iconSizeMedium,
                color: AppColors.textSecondary),
            const SizedBox(width: AppConstants.paddingSmall),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (q) => _bloc.add(SearchComptesEvent(q)),
                style: const TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'banques.search_compte'.tr(),
                  hintStyle: const TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      color: AppColors.textSecondary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<DetailBanqueBloc, DetailBanqueState>(
      builder: (context, state) {
        if (state is DetailBanqueLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryDark));
        }
        if (state is DetailBanqueError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppColors.statusRejected),
              textAlign: TextAlign.center,
            ),
          );
        }
        if (state is DetailBanqueLoaded) {
          if (state.comptes.isEmpty) {
            return Center(
              child: Text(
                'banques.no_comptes'.tr(),
                style: const TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppColors.textSecondary),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingLarge,
                AppConstants.paddingMedium,
                AppConstants.paddingLarge,
                AppConstants.paddingXLarge),
            itemCount: state.comptes.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
              child: _CompteCard(compte: state.comptes[index]),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Card compte
// ---------------------------------------------------------------------------

class _CompteCard extends StatelessWidget {
  final CompteModel compte;
  const _CompteCard({required this.compte});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.compteCardHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.08),
          width: AppConstants.borderWidthThin,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 48,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
        vertical: AppConstants.paddingMedium,
      ),
      child: Row(
        children: [
          // Icône avec fond coloré
          Container(
            width: AppConstants.cardIconSize,
            height: AppConstants.cardIconSize,
            decoration: BoxDecoration(
              color: AppColors.banqueIconBg,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/Container.svg',
                width: AppConstants.iconSizeSmall,
                height: AppConstants.iconSizeSmall,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryDark,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          // Numéro + type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'banques.label_numero'.tr(),
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  compte.numeroCompte,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          // Type + titulaire
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                compte.typeCompte,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                compte.titulaire,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Modal Ajouter un compte bancaire
// ---------------------------------------------------------------------------

class _AjouterCompteModal extends StatefulWidget {
  final BanqueModel banque;
  const _AjouterCompteModal({required this.banque});

  @override
  State<_AjouterCompteModal> createState() => _AjouterCompteModalState();
}

class _AjouterCompteModalState extends State<_AjouterCompteModal> {
  final TextEditingController _numeroCompteController = TextEditingController();
  final TextEditingController _titulaireController = TextEditingController();
  String? _selectedTypeCompte;

  List<String> get _typesCompte => [
        'banques.type_courant'.tr(),
        'banques.type_epargne'.tr(),
        'banques.type_professionnel'.tr(),
      ];

  @override
  void dispose() {
    _numeroCompteController.dispose();
    _titulaireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final safePadding = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingXLarge,
        AppConstants.paddingMedium,
        AppConstants.paddingXLarge,
        bottom + safePadding + AppConstants.paddingXLarge,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: AppConstants.modalHandleWidth,
                height: AppConstants.modalHandleHeight,
                decoration: BoxDecoration(
                  color: AppColors.modalHandle,
                  borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),

            // Titre + fermer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'banques.add_compte_title'.tr(),
                  style: const TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    fontSize: AppConstants.fontSizeXXLarge,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close,
                      size: AppConstants.iconSizeLarge,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingXLarge),

            // Champ Banque (non modifiable)
            _buildLabel('banques.field_banque'.tr()),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildBanqueField(),
            const SizedBox(height: AppConstants.paddingLarge),

            // Type de compte
            _buildLabel('banques.field_type_compte'.tr()),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildTypeCompteDropdown(),
            const SizedBox(height: AppConstants.paddingLarge),

            // Numéro de compte
            _buildLabel('banques.field_numero_compte'.tr()),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildNumeroCompteField(),
            const SizedBox(height: AppConstants.paddingLarge),

            // Nom du titulaire
            _buildLabel('banques.field_titulaire'.tr()),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildTextField(
              controller: _titulaireController,
              hint: 'banques.hint_titulaire'.tr(),
            ),
            const SizedBox(height: AppConstants.paddingXLarge),

            // Bouton Enregistrer
            GestureDetector(
              onTap: _onEnregistrer,
              child: Container(
                height: AppConstants.buttonHeight,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                ),
                child: Center(
                  child: Text(
                    'banques.save'.tr(),
                    style: const TextStyle(
                      fontFamily: AppConstants.fontFamilyInter,
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),

            // Bouton Annuler
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: AppConstants.buttonHeight,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                  border: Border.all(
                      color: AppColors.primaryDark,
                      width: AppConstants.borderWidthThin),
                ),
                child: Center(
                  child: Text(
                    'banques.cancel'.tr(),
                    style: const TextStyle(
                      fontFamily: AppConstants.fontFamilyInter,
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: AppConstants.fontFamilyInter,
        fontSize: AppConstants.fontSizeMedium,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
    );
  }

  // Champ banque non modifiable avec image + cadenas
  Widget _buildBanqueField() {
    return Container(
      height: AppConstants.inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.banqueFieldBg,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
            color: AppColors.banqueFieldBorder,
            width: AppConstants.borderWidthThin),
      ),
      child: Row(
        children: [
          ClipOval(
            child: widget.banque.logoUrl != null
                ? AuthImage(
                    url: widget.banque.logoUrl!,
                    width: AppConstants.iconSizeLarge,
                    height: AppConstants.iconSizeLarge,
                    fit: BoxFit.cover,
                    fallback: () => const Icon(
                      Icons.account_balance,
                      size: AppConstants.iconSizeLarge,
                      color: AppColors.primaryDark,
                    ),
                  )
                : const Icon(
                    Icons.account_balance,
                    size: AppConstants.iconSizeLarge,
                    color: AppColors.primaryDark,
                  ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              widget.banque.nom,
              style: const TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ),
          const Icon(Icons.lock_outline,
              size: AppConstants.iconSizeMedium,
              color: AppColors.banqueLockIcon),
        ],
      ),
    );
  }

  // Champ numéro de compte avec icône vérification verte
  Widget _buildNumeroCompteField() {
    return Container(
      height: AppConstants.inputHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _numeroCompteController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'banques.hint_numero_compte'.tr(),
                hintStyle: const TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppColors.textSecondary),
                border: InputBorder.none,
                isDense: false,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.paddingMedium),
            child: Container(
              width: AppConstants.iconSizeLarge,
              height: AppConstants.iconSizeLarge,
              decoration: const BoxDecoration(
                color: AppColors.compteVerifyBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check,
                  size: AppConstants.iconSizeSmall,
                  color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCompteDropdown() {
    return Container(
      height: AppConstants.inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTypeCompte,
          hint: Text(
            'banques.type_courant'.tr(),
            style: const TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                color: AppColors.textSecondary),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
              size: AppConstants.iconSizeMedium),
          style: const TextStyle(
              fontSize: AppConstants.fontSizeMedium, color: AppColors.textDark),
          dropdownColor: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          items: _typesCompte.map((type) {
            return DropdownMenuItem<String>(value: type, child: Text(type));
          }).toList(),
          onChanged: (val) => setState(() => _selectedTypeCompte = val),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      height: AppConstants.inputHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
            fontSize: AppConstants.fontSizeMedium, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              color: AppColors.textSecondary),
          border: InputBorder.none,
          isDense: false,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge),
        ),
      ),
    );
  }

  void _onEnregistrer() {
    final numero = _numeroCompteController.text.trim();
    final titulaire = _titulaireController.text.trim();
    if (numero.isEmpty) return;
    context.read<DetailBanqueBloc>().add(AjouterCompteEvent(
          organisationId: widget.banque.id,
          accountNumber: numero,
          accountHolder: titulaire,
        ));
    Navigator.of(context).pop();
  }
}
