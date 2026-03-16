import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/features/auth/data/services/user_profile_service.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserProfileService _service;

  UserBloc({UserProfileService? service})
      : _service = service ?? UserProfileService(),
        super(UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<ClearUserProfile>(_onClearUserProfile);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await _service.getProfile(event.accessToken);
      emit(UserLoaded(user));
    } catch (e) {
      print('=== USER PROFILE ERROR: $e ===');
      emit(UserError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onClearUserProfile(ClearUserProfile event, Emitter<UserState> emit) {
    emit(UserInitial());
  }
}
