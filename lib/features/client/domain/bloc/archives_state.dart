import 'package:quick_forms/features/client/data/models/archive_model.dart';

abstract class ArchivesState {
  const ArchivesState();
}

class ArchivesInitial extends ArchivesState {
  const ArchivesInitial();
}

class ArchivesLoading extends ArchivesState {
  const ArchivesLoading();
}

class ArchivesLoaded extends ArchivesState {
  final List<ArchiveModel> archives;
  final int total;
  final int currentPage;
  final bool isLoadingMore;
  const ArchivesLoaded(
    this.archives, {
    this.total = 0,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  ArchivesLoaded copyWith({
    List<ArchiveModel>? archives,
    int? total,
    int? currentPage,
    bool? isLoadingMore,
  }) =>
      ArchivesLoaded(
        archives ?? this.archives,
        total: total ?? this.total,
        currentPage: currentPage ?? this.currentPage,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

class ArchivesError extends ArchivesState {
  final String message;
  const ArchivesError(this.message);
}
