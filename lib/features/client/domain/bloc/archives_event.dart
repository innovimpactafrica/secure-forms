abstract class ArchivesEvent {
  const ArchivesEvent();
}

class LoadArchivesEvent extends ArchivesEvent {
  final String type;
  final String? status;
  const LoadArchivesEvent({this.type = 'all', this.status});
}

class GoToArchivesPageEvent extends ArchivesEvent {
  final int page;
  const GoToArchivesPageEvent(this.page);
}
