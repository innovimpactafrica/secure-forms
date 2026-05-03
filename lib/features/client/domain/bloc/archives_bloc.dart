import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_forms/core/utils/user_session.dart';
import 'package:quick_forms/features/client/data/services/archives_service.dart';
import 'archives_event.dart';
import 'archives_state.dart';

class ArchivesBloc extends Bloc<ArchivesEvent, ArchivesState> {
  final ArchivesService _service;
  static const int _pageSize = 10;

  String _currentType = 'all';
  String? _currentStatus;
  // ignore: unused_field
  int _currentPage = 1;

  ArchivesBloc({ArchivesService? service})
      : _service = service ?? ArchivesService(),
        super(const ArchivesInitial()) {
    on<LoadArchivesEvent>(_onLoad);
    on<GoToArchivesPageEvent>(_onGoToPage);
    on<LoadMoreArchivesEvent>(_onLoadMore);
  }

  Future<void> _onLoad(
    LoadArchivesEvent event,
    Emitter<ArchivesState> emit,
  ) async {
    emit(const ArchivesLoading());
    _currentType = event.type;
    _currentStatus = event.status;
    _currentPage = 1;
    try {
      final token = UserSession.instance.accessToken;
      final page = await _service.getArchives(
        accessToken: token,
        type: event.type,
        status: event.status,
        page: 1,
        limit: _pageSize,
      );
      emit(ArchivesLoaded(
        page.items,
        total: page.total,
        currentPage: 1,
      ));
    } catch (e) {
      emit(ArchivesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGoToPage(
    GoToArchivesPageEvent event,
    Emitter<ArchivesState> emit,
  ) async {
    final current = state;
    if (current is! ArchivesLoaded) return;
    emit(current.copyWith(isLoadingMore: true));
    try {
      final token = UserSession.instance.accessToken;
      final page = await _service.getArchives(
        accessToken: token,
        type: _currentType,
        status: _currentStatus,
        page: event.page,
        limit: _pageSize,
      );
      _currentPage = event.page;
      emit(ArchivesLoaded(
        page.items,
        total: page.total,
        currentPage: event.page,
      ));
    } catch (e) {
      emit(ArchivesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreArchivesEvent event,
    Emitter<ArchivesState> emit,
  ) async {
    final current = state;
    if (current is! ArchivesLoaded) return;
    final nextPage = current.currentPage + 1;
    final totalPages = (current.total / _pageSize).ceil();
    if (nextPage > totalPages) return;
    emit(current.copyWith(isLoadingMore: true));
    try {
      final token = UserSession.instance.accessToken;
      final page = await _service.getArchives(
        accessToken: token,
        type: _currentType,
        status: _currentStatus,
        page: nextPage,
        limit: _pageSize,
      );
      _currentPage = nextPage;
      emit(ArchivesLoaded(
        [...current.archives, ...page.items],
        total: page.total,
        currentPage: nextPage,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}
