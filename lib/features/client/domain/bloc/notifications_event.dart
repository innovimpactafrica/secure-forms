abstract class NotificationsEvent {
  const NotificationsEvent();
}

class LoadNotificationsEvent extends NotificationsEvent {
  final bool unreadOnly;
  const LoadNotificationsEvent({this.unreadOnly = false});
}
