import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/home/data/repositories/client_statistics_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ClientStatisticsRepository _repository;

  HomeBloc({ClientStatisticsRepository? repository})
      : _repository = repository ?? ClientStatisticsRepository(),
        super(const HomeInitial()) {
    on<LoadClientStatisticsEvent>(_onLoadStatistics);
  }

  Future<void> _onLoadStatistics(
    LoadClientStatisticsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final stats = await _repository.getStatistics(
        UserSession.instance.accessToken,
      );
      // ignore: avoid_print
      print('[HomeBloc] Stats: total=${stats.total} pending=${stats.pending} inProgress=${stats.inProgress} validated=${stats.validated} rejected=${stats.rejected}');
      emit(HomeStatisticsLoaded(statistics: stats));
    } catch (e) {
      // ignore: avoid_print
      print('[HomeBloc] ERREUR: $e');
      emit(HomeError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
