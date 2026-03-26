abstract class NotificationsEvent {
  const NotificationsEvent();
}

class LoadNotificationsEvent extends NotificationsEvent {
  final bool unreadOnly;
  final bool forceRefresh;
  const LoadNotificationsEvent({this.unreadOnly = false, this.forceRefresh = false});
}
