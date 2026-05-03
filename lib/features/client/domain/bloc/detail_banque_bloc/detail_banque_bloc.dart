import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_forms/core/utils/user_session.dart';
import 'package:quick_forms/features/client/data/services/detail_banque_service.dart';
import 'package:quick_forms/features/client/data/models/compte_model.dart';
import 'detail_banque_event.dart';
import 'detail_banque_state.dart';

class DetailBanqueBloc extends Bloc<DetailBanqueEvent, DetailBanqueState> {
  final DetailBanqueService _service;
  List<CompteModel> _allComptes = [];
  String _currentOrganisationId = '';

  DetailBanqueBloc({DetailBanqueService? service})
      : _service = service ?? DetailBanqueService(),
        super(const DetailBanqueInitial()) {
    on<LoadComptesEvent>(_onLoad);
    on<SearchComptesEvent>(_onSearch);
    on<AjouterCompteEvent>(_onAjouter);
  }

  Future<void> _onLoad(
      LoadComptesEvent event, Emitter<DetailBanqueState> emit) async {
    _currentOrganisationId = event.banqueId;
    emit(const DetailBanqueLoading());
    try {
      final comptes = await _service.getComptes(
        accessToken: UserSession.instance.accessToken,
        organisationId: event.banqueId,
      );
      _allComptes = comptes;
      emit(DetailBanqueLoaded(comptes));
    } catch (e) {
      emit(DetailBanqueError(e.toString()));
    }
  }

  void _onSearch(SearchComptesEvent event, Emitter<DetailBanqueState> emit) {
    final q = event.query.toLowerCase();
    if (q.isEmpty) {
      emit(DetailBanqueLoaded(_allComptes));
      return;
    }
    final filtered = _allComptes
        .where((c) =>
            c.numeroCompte.toLowerCase().contains(q) ||
            c.typeCompte.toLowerCase().contains(q) ||
            c.titulaire.toLowerCase().contains(q))
        .toList();
    emit(DetailBanqueLoaded(filtered));
  }

  Future<void> _onAjouter(
      AjouterCompteEvent event, Emitter<DetailBanqueState> emit) async {
    emit(const CompteAjoutEnCoursState());
    try {
      await _service.ajouterCompte(
        accessToken: UserSession.instance.accessToken,
        organisationId: event.organisationId,
        accountNumber: event.accountNumber,
        accountHolder: event.accountHolder,
      );
      emit(const CompteAjouteState());
      // Recharger la liste après ajout
      final comptes = await _service.getComptes(
        accessToken: UserSession.instance.accessToken,
        organisationId: _currentOrganisationId,
      );
      _allComptes = comptes;
      emit(DetailBanqueLoaded(comptes));
    } catch (e) {
      emit(CompteAjoutErreurState(e.toString()));
      emit(DetailBanqueLoaded(_allComptes));
    }
  }
}
