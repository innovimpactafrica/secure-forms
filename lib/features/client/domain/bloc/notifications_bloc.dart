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
    on<ResetNotificationsEvent>((_, emit) => emit(const NotificationsInitial()));
  }

  Future<void> _onLoad(
    LoadNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    // Ne pas refaire l'appel si déjà chargé et pas de force refresh
    if (state is NotificationsLoaded && !event.forceRefresh) {
      print('[NotificationsBloc] déjà chargé, skip');
      return;
    }
    // Ne pas émettre Loading si déjà des données (avoid flicker)
    if (state is! NotificationsLoaded) emit(const NotificationsLoading());
    try {
      final token = UserSession.instance.accessToken;
      if (token.isEmpty) {
        emit(const NotificationsError('Token absent'));
        return;
      }
      print('[NotificationsBloc] LoadNotifications — unreadOnly=${event.unreadOnly}');
      final notifs = await _service.getNotifications(
        accessToken: token,
        unreadOnly: event.unreadOnly,
      );
      print('[NotificationsBloc] ${notifs.length} notification(s) chargée(s)');
      emit(NotificationsLoaded(notifs));
    } catch (e) {
      print('[NotificationsBloc] ERREUR: $e');
      // Garder l'état précédent si on avait des données
      if (state is! NotificationsLoaded) {
        emit(NotificationsError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }
}
