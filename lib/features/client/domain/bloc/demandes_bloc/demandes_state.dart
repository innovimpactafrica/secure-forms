import 'package:secure_link/features/client/data/models/demande_model.dart';

abstract class DemandesState {
  const DemandesState();
}

class DemandesInitial extends DemandesState {
  const DemandesInitial();
}

class DemandesLoading extends DemandesState {
  const DemandesLoading();
}

class RecentDemandesLoaded extends DemandesState {
  final List<DemandeModel> demandes;
  const RecentDemandesLoaded(this.demandes);
}

class DemandesLoaded extends DemandesState {
  final List<DemandeModel> demandes;
  final int total;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  const DemandesLoaded({
    required this.demandes,
    required this.total,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  DemandesLoaded copyWith({
    List<DemandeModel>? demandes,
    int? total,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) =>
      DemandesLoaded(
        demandes: demandes ?? this.demandes,
        total: total ?? this.total,
        currentPage: currentPage ?? this.currentPage,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

class DemandesError extends DemandesState {
  final String message;
  const DemandesError(this.message);
}

class DraftDeleted extends DemandesState {
  const DraftDeleted();
}
