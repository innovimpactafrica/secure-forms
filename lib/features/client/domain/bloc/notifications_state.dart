import 'package:quick_forms/features/client/data/models/notification_model.dart';

abstract class NotificationsState {
  const NotificationsState();
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  const NotificationsLoaded(this.notifications);
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);
}
