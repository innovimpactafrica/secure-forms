abstract class NotificationsEvent {
  const NotificationsEvent();
}

class LoadNotificationsEvent extends NotificationsEvent {
  final bool unreadOnly;
  final bool forceRefresh;
  const LoadNotificationsEvent({this.unreadOnly = false, this.forceRefresh = false});
}

class MarkAllNotificationsReadEvent extends NotificationsEvent {
  const MarkAllNotificationsReadEvent();
}

class ResetNotificationsEvent extends NotificationsEvent {
  const ResetNotificationsEvent();
}
