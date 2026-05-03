import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';
import 'package:quick_forms/features/client/data/models/banque_model.dart';
import 'package:quick_forms/features/client/domain/bloc/banques_bloc/banques_bloc.dart';
import 'package:quick_forms/features/client/domain/bloc/banques_bloc/banques_event.dart';
import 'package:quick_forms/features/client/domain/bloc/banques_bloc/banques_state.dart';
import 'package:quick_forms/core/widgets/auth_image.dart';
import 'package:quick_forms/features/client/presentation/pages/detail_banque_screen.dart';

class MesBanquesScreen extends StatefulWidget {
  const MesBanquesScreen({super.key});

  @override
  State<MesBanquesScreen> createState() => _MesBanquesScreenState();
}

class _MesBanquesScreenState extends State<MesBanquesScreen> {
  late final BanquesBloc _bloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = BanquesBloc()..add(const LoadBanquesEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    _searchController.dispose();
    super.dispose();
  }

  void _showAjouterBanqueModal(BuildContext context) {
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
        child: const _AjouterBanqueModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<BanquesBloc, BanquesState>(
        listener: (context, state) {
          if (state is BanqueAjouteeState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'banques.banque_ajoutee'.tr(),
                  style: const TextStyle(color: AppColors.white),
                ),
                backgroundColor: AppColors.statusValideGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusMedium)),
              ),
            );
          } else if (state is BanqueAjoutErreurState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(color: AppColors.white),
                ),
                backgroundColor: AppColors.statusRejected,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusMedium)),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
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
            onPressed: () => _showAjouterBanqueModal(context),
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
                'banques.title'.tr(),
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'banques.subtitle'.tr(),
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
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
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
                onChanged: (q) => _bloc.add(SearchBanquesEvent(q)),
                style: const TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'banques.search_placeholder'.tr(),
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
    return BlocBuilder<BanquesBloc, BanquesState>(
      builder: (context, state) {
        if (state is BanquesLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryDark));
        }
        if (state is BanquesError) {
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
        if (state is BanquesLoaded) {
          if (state.banques.isEmpty) {
            return Center(
              child: Text(
                'banques.no_banques'.tr(),
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
            itemCount: state.banques.length,
            itemBuilder: (context, index) => Padding(
              padding:
                  const EdgeInsets.only(bottom: AppConstants.paddingMedium),
              child: _BanqueCard(banque: state.banques[index]),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Card banque
// ---------------------------------------------------------------------------

class _BanqueCard extends StatelessWidget {
  final BanqueModel banque;
  const _BanqueCard({required this.banque});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetailBanqueScreen(banque: banque),
        ),
      ),
      child: Container(
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
            ClipOval(
              child: banque.logoUrl != null
                  ? AuthImage(
                      url: banque.logoUrl!,
                      width: AppConstants.avatarSizeLarge,
                      height: AppConstants.avatarSizeLarge,
                      fit: BoxFit.cover,
                      fallback: _buildFallbackIcon,
                    )
                  : _buildFallbackIcon(),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banque.nom,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    banque.description,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeRegular,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: AppConstants.avatarSizeLarge,
      height: AppConstants.avatarSizeLarge,
      decoration: const BoxDecoration(
        color: AppColors.grayLight,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.account_balance,
          color: AppColors.textSecondary, size: AppConstants.iconSizeMedium),
    );
  }
}

// ---------------------------------------------------------------------------
// Modal Ajouter une banque
// ---------------------------------------------------------------------------

class _AjouterBanqueModal extends StatefulWidget {
  const _AjouterBanqueModal();

  @override
  State<_AjouterBanqueModal> createState() => _AjouterBanqueModalState();
}

class _AjouterBanqueModalState extends State<_AjouterBanqueModal> {
  final TextEditingController _searchBanqueController = TextEditingController();
  final TextEditingController _numeroCompteController = TextEditingController();
  final TextEditingController _titulaireController = TextEditingController();

  String? _selectedTypeCompte;
  String? _selectedBanqueNom;
  String? _selectedBanqueId;
  bool _showSuggestions = false;
  List<BanqueModel> _banquesFiltrees = [];

  @override
  void initState() {
    super.initState();
    final state = context.read<BanquesBloc>().state;
    if (state is BanquesLoaded) {
      _banquesFiltrees = List.from(state.banques);
      debugPrint(
          '[AjouterBanqueModal] initState: ${_banquesFiltrees.length} banques disponibles');
    } else {
      debugPrint(
          '[AjouterBanqueModal] initState: BLoC pas en BanquesLoaded (${state.runtimeType})');
    }
  }

  void _filterBanques(String query) {
    final state = context.read<BanquesBloc>().state;
    final all = state is BanquesLoaded ? state.banques : <BanqueModel>[];
    setState(() {
      _banquesFiltrees = query.isEmpty
          ? all
          : all
              .where((b) => b.nom.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchBanqueController.dispose();
    _numeroCompteController.dispose();
    _titulaireController.dispose();
    super.dispose();
  }

  List<String> get _typesCompte => [
        'banques.type_courant'.tr(),
        'banques.type_epargne'.tr(),
        'banques.type_professionnel'.tr(),
      ];

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
                  'banques.add_title'.tr(),
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

            // Champ Banque
            _buildLabel('banques.field_banque'.tr()),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildSearchBanqueField(),
            // Suggestions — visibles quand le champ est focusé et aucune banque sélectionnée
            if (_showSuggestions && _selectedBanqueNom == null)
              _buildSuggestions(),
            const SizedBox(height: AppConstants.paddingLarge),

            // Type de compte
            _buildLabel('banques.field_type_compte'.tr()),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildTypeCompteDropdown(),
            const SizedBox(height: AppConstants.paddingLarge),

            // Numéro de compte
            _buildLabel('banques.field_numero_compte'.tr()),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildTextField(
              controller: _numeroCompteController,
              hint: 'banques.hint_numero_compte'.tr(),
              keyboardType: TextInputType.number,
            ),
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

  Widget _buildSearchBanqueField() {
    return Container(
      height: AppConstants.inputHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.borderGray),
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
              controller: _searchBanqueController,
              onTap: () {
                setState(() => _showSuggestions = true);
              },
              onChanged: (q) {
                setState(() {
                  _selectedBanqueNom = null;
                  _selectedBanqueId = null;
                  _showSuggestions = true;
                });
                debugPrint('[AjouterBanqueModal] Recherche banque: "$q"');
                _filterBanques(q);
              },
              style: const TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'banques.hint_search_banque'.tr(),
                hintStyle: const TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppColors.textSecondary),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    if (_banquesFiltrees.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: _banquesFiltrees.map((banque) {
          return InkWell(
            onTap: () {
              setState(() {
                _selectedBanqueNom = banque.nom;
                _selectedBanqueId = banque.id;
                _searchBanqueController.text = banque.nom;
                _showSuggestions = false;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                  vertical: AppConstants.paddingMedium),
              child: Row(
                children: [
                  const Icon(Icons.account_balance,
                      size: AppConstants.iconSizeSmall,
                      color: AppColors.textSecondary),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Text(
                    banque.nom,
                    style: const TextStyle(
                        fontSize: AppConstants.fontSizeMedium,
                        color: AppColors.textDark),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypeCompteDropdown() {
    return Container(
      height: AppConstants.inputHeight,
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
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
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedTypeCompte = val),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
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
        keyboardType: keyboardType,
        style: const TextStyle(
            fontSize: AppConstants.fontSizeMedium, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              color: AppColors.textSecondary),
          border: InputBorder.none,
          isDense: false,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
        ),
      ),
    );
  }

  void _onEnregistrer() {
    final numero = _numeroCompteController.text.trim();
    final titulaire = _titulaireController.text.trim();
    final banqueNom = _selectedBanqueNom ?? _searchBanqueController.text.trim();
    var organisationId = _selectedBanqueId ?? '';

    // Si pas sélectionné depuis la liste, chercher par nom dans le BLoC
    if (organisationId.isEmpty && banqueNom.isNotEmpty) {
      final state = context.read<BanquesBloc>().state;
      if (state is BanquesLoaded) {
        final found = state.banques
            .where((b) => b.nom.toLowerCase() == banqueNom.toLowerCase())
            .firstOrNull;
        organisationId = found?.id ?? '';
        debugPrint(
            '[AjouterBanqueModal] Recherche par nom "$banqueNom" -> id=$organisationId');
      }
    }

    debugPrint(
        '[AjouterBanqueModal] banqueNom=$banqueNom | organisationId=$organisationId | numero=$numero | titulaire=$titulaire');

    if (banqueNom.isEmpty) {
      debugPrint('[AjouterBanqueModal] BLOQUE: banqueNom vide');
      return;
    }
    if (numero.isEmpty) {
      debugPrint('[AjouterBanqueModal] BLOQUE: numero vide');
      return;
    }
    if (organisationId.isEmpty) {
      debugPrint(
          '[AjouterBanqueModal] BLOQUE: organisationId vide — banque introuvable dans la liste');
      return;
    }

    debugPrint('[AjouterBanqueModal] Dispatch AjouterBanqueEvent');
    context.read<BanquesBloc>().add(AjouterBanqueEvent(
          organisationId: organisationId,
          accountNumber: numero,
          accountHolder: titulaire,
        ));
    Navigator.of(context).pop();
  }
}
