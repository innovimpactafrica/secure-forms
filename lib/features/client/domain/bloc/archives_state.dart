import 'package:secure_link/features/client/data/models/archive_model.dart';

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
  const ArchivesLoaded(this.archives);
}

class ArchivesError extends ArchivesState {
  final String message;
  const ArchivesError(this.message);
}
