import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_forms/core/utils/user_session.dart';
import 'package:quick_forms/features/client/data/repositories/demandes_repository.dart';
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
    on<GoToDemandesPageEvent>(_onGoToPage);
    on<ResetDemandesEvent>((_, emit) {
      _currentStatus = null;
      _currentSector = null;
      _currentSearch = null;
      _currentPage = 1;
      _lastSearch = null;
      emit(const DemandesInitial());
    });
  }

  String? _lastSearch;

  Future<void> _onLoadRecent(
    LoadRecentDemandesEvent event,
    Emitter<DemandesState> emit,
  ) async {
    // Cache : skip uniquement si déjà chargé, pas de force refresh ET même recherche
    if (state is RecentDemandesLoaded &&
        !event.forceRefresh &&
        event.search == _lastSearch) {
      emit(state);
      return;
    }
    _lastSearch = event.search;
    if (state is! RecentDemandesLoaded) emit(const DemandesLoading());
    try {
      final token = UserSession.instance.accessToken;
      final demandes = await _repository.getRecentRequests(
        accessToken: token,
        limit: event.limit,
        status: event.status,
        category: event.category,
        search: event.search,
      );
      emit(RecentDemandesLoaded(demandes));
    } catch (e) {
      if (state is! RecentDemandesLoaded) {
        emit(DemandesError(e.toString().replaceAll('Exception: ', '')));
      }
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
    if (current is! DemandesLoaded || !current.hasMore || current.isLoadingMore)
      return;
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

  Future<void> _onGoToPage(
    GoToDemandesPageEvent event,
    Emitter<DemandesState> emit,
  ) async {
    final current = state;
    if (current is! DemandesLoaded) return;
    emit(current.copyWith(isLoadingMore: true));
    try {
      final token = UserSession.instance.accessToken;
      final page = await _repository.getRequests(
        accessToken: token,
        status: _currentStatus,
        sector: _currentSector,
        search: _currentSearch,
        page: event.page,
        limit: _pageSize,
      );
      _currentPage = event.page;
      emit(DemandesLoaded(
        demandes: page.items,
        total: page.total,
        currentPage: event.page,
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
