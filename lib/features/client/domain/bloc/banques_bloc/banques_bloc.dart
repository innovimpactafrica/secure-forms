import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/features/client/data/services/banques_service.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'banques_event.dart';
import 'banques_state.dart';

class BanquesBloc extends Bloc<BanquesEvent, BanquesState> {
  final BanquesService _service;
  final _allBanques = <dynamic>[];

  BanquesBloc({BanquesService? service})
      : _service = service ?? BanquesService(),
        super(const BanquesInitial()) {
    on<LoadBanquesEvent>(_onLoad);
    on<SearchBanquesEvent>(_onSearch);
    on<AjouterBanqueEvent>(_onAjouter);
  }

  Future<void> _onLoad(
      LoadBanquesEvent event, Emitter<BanquesState> emit) async {
    emit(const BanquesLoading());
    try {
      final banques = await _service.getOrganisations(
        accessToken: UserSession.instance.accessToken,
      );
      _allBanques
        ..clear()
        ..addAll(banques);
      emit(BanquesLoaded(banques));
    } catch (e) {
      emit(BanquesError(e.toString()));
    }
  }

  void _onSearch(SearchBanquesEvent event, Emitter<BanquesState> emit) {
    final q = event.query.toLowerCase();
    if (q.isEmpty) {
      emit(BanquesLoaded(List.from(_allBanques)));
      return;
    }
    final filtered = _allBanques
        .where((b) =>
            b.nom.toLowerCase().contains(q) ||
            b.description.toLowerCase().contains(q))
        .toList();
    emit(BanquesLoaded(List.from(filtered)));
  }

  Future<void> _onAjouter(AjouterBanqueEvent event, Emitter<BanquesState> emit) async {
    debugPrint('[BanquesBloc] AjouterBanqueEvent reçu | organisationId=${event.organisationId} | accountNumber=${event.accountNumber} | accountHolder=${event.accountHolder}');
    emit(const BanqueAjoutEnCoursState());
    try {
      await _service.ajouterBanque(
        accessToken: UserSession.instance.accessToken,
        organisationId: event.organisationId,
        accountNumber: event.accountNumber,
        accountHolder: event.accountHolder,
      );
      emit(const BanqueAjouteeState());
      // Recharger la liste
      final banques = await _service.getOrganisations(
        accessToken: UserSession.instance.accessToken,
      );
      _allBanques
        ..clear()
        ..addAll(banques);
      emit(BanquesLoaded(banques));
    } catch (e) {
      emit(BanqueAjoutErreurState(e.toString()));
      emit(BanquesLoaded(List.from(_allBanques)));
    }
  }
}
