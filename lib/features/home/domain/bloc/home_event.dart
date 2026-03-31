abstract class HomeEvent {
  const HomeEvent();
}

class LoadClientStatisticsEvent extends HomeEvent {
  final bool forceRefresh;
  const LoadClientStatisticsEvent({this.forceRefresh = false});
}

class ResetHomeEvent extends HomeEvent {
  const ResetHomeEvent();
}
