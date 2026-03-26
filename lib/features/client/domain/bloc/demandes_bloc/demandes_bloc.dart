import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/client/data/repositories/demandes_repository.dart';
import 'demandes_event.dart';
import 'demandes_state.dart';

class DemandesBloc extends Bloc<DemandesEvent, DemandesState> {
  final DemandesRepository _repository;

  // Mémorise les filtres courants pour la pagination
  String? _currentStatus;
  String? _currentSector;
  String? _currentSearch;
  int _currentPage = 1;
  static const int _pageSize = 10;

  DemandesBloc({DemandesRepository? repository})
      : _repository = repository ?? DemandesRepository(),
        super(const DemandesInitial()) {
    on<LoadRecentDemandesEvent>(_onLoadRecent);
    on<LoadDemandesEvent>(_onLoadDemandes);
    on<LoadMoreDemandesEvent>(_onLoadMore);
    on<DeleteDraftEvent>(_onDeleteDraft);
  }

  Future<void> _onLoadRecent(
    LoadRecentDemandesEvent event,
    Emitter<DemandesState> emit,
  ) async {
    emit(const DemandesLoading());
    try {
      final token = UserSession.instance.accessToken;
      final demandes = await _repository.getRecentRequests(
        accessToken: token,
        limit: event.limit,
        status: event.status,
        category: event.category,
        search: event.search,
      );
      // ignore: avoid_print
      print('[RecentDemandes] count=${demandes.length}');
      for (var i = 0; i < demandes.length; i++) {
        final d = demandes[i];
        // ignore: avoid_print
        print('[RecentDemandes][$i] id=${d.id} | formType="${d.formType}" | requestNumber="${d.requestNumber}" | organisationName="${d.organisationName}" | createdAt="${d.createdAt}" | status="${d.status}"');
      }
      emit(RecentDemandesLoaded(demandes));
    } catch (e) {
      // ignore: avoid_print
      print('[RecentDemandes] ERROR: $e');
      emit(DemandesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadDemandes(
    LoadDemandesEvent event,
    Emitter<DemandesState> emit,
  ) async {
    emit(const DemandesLoading());
    _currentStatus = event.status;
    _currentSector = event.sector;
    _currentSearch = event.search;
    _currentPage = 1;
    try {
      final token = UserSession.instance.accessToken;
      final page = await _repository.getRequests(
        accessToken: token,
        status: event.status,
        sector: event.sector,
        search: event.search,
        page: 1,
        limit: _pageSize,
      );
      emit(DemandesLoaded(
        demandes: page.items,
        total: page.total,
        currentPage: 1,
        hasMore: page.hasMore,
      ));
    } catch (e) {
      emit(DemandesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreDemandesEvent event,
    Emitter<DemandesState> emit,
  ) async {
    final current = state;
    if (current is! DemandesLoaded || !current.hasMore || current.isLoadingMore) return;
    emit(current.copyWith(isLoadingMore: true));
    try {
      final token = UserSession.instance.accessToken;
      final nextPage = _currentPage + 1;
      final page = await _repository.getRequests(
        accessToken: token,
        status: _currentStatus,
        sector: _currentSector,
        search: _currentSearch,
        page: nextPage,
        limit: _pageSize,
      );
      _currentPage = nextPage;
      emit(DemandesLoaded(
        demandes: [...current.demandes, ...page.items],
        total: page.total,
        currentPage: nextPage,
        hasMore: page.hasMore,
      ));
    } catch (e) {
      emit(DemandesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteDraft(
    DeleteDraftEvent event,
    Emitter<DemandesState> emit,
  ) async {
    try {
      final token = UserSession.instance.accessToken;
      await _repository.deleteDraft(accessToken: token, id: event.id);
      emit(const DraftDeleted());
      // Recharger la liste après suppression
      add(LoadDemandesEvent(
        status: _currentStatus,
        sector: _currentSector,
        search: _currentSearch,
      ));
    } catch (e) {
      emit(DemandesError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
