import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/client/data/services/notifications_service.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsService _service;

  NotificationsBloc({NotificationsService? service})
      : _service = service ?? NotificationsService(),
        super(const NotificationsInitial()) {
    on<LoadNotificationsEvent>(_onLoad);
    on<MarkAllNotificationsReadEvent>(_onMarkAllRead);
    on<ResetNotificationsEvent>((_, emit) => emit(const NotificationsInitial()));
  }

  Future<void> _onLoad(
    LoadNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is NotificationsLoaded && !event.forceRefresh) return;
    if (state is! NotificationsLoaded) emit(const NotificationsLoading());
    try {
      final token = UserSession.instance.accessToken;
      if (token.isEmpty) { emit(const NotificationsError('Token absent')); return; }
      final notifs = await _service.getNotifications(accessToken: token, unreadOnly: event.unreadOnly);
      emit(NotificationsLoaded(notifs));
    } catch (e) {
      if (state is! NotificationsLoaded) {
        emit(NotificationsError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onMarkAllRead(
    MarkAllNotificationsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;
    final current = (state as NotificationsLoaded).notifications;
    // Mise à jour instantanée locale → badge disparaît immédiatement
    final updated = current.map((n) => n.copyWith(isRead: true)).toList();
    emit(NotificationsLoaded(updated));
    // Appel API en arrière-plan
    try {
      final token = UserSession.instance.accessToken;
      await _service.markAllRead(token);
    } catch (e) {
      print('[NotificationsBloc] markAllRead error: $e');
    }
  }
}
