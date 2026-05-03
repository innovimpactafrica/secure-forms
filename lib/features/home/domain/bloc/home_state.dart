import 'package:quick_forms/features/home/data/models/client_statistics_model.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeStatisticsLoaded extends HomeState {
  final ClientStatisticsModel statistics;
  const HomeStatisticsLoaded({required this.statistics});
}

class HomeError extends HomeState {
  final String message;
  const HomeError({required this.message});
}
