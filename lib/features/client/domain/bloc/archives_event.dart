abstract class ArchivesEvent {
  const ArchivesEvent();
}

class LoadArchivesEvent extends ArchivesEvent {
  final String type;   // 'all' | 'requests' | 'documents'
  final String? status;
  const LoadArchivesEvent({this.type = 'all', this.status});
}
