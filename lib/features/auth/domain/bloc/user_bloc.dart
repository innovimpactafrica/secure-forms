import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/features/auth/data/services/user_profile_service.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserProfileService _service;
  // Cache local de la photo de profil
  Uint8List? _profilePictureBytes;
  Uint8List? get profilePictureBytes => _profilePictureBytes;

  UserBloc({UserProfileService? service})
      : _service = service ?? UserProfileService(),
        super(UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<ClearUserProfile>(_onClearUserProfile);
    on<UpdateProfilePictureEvent>(_onUpdateProfilePicture);
    on<LoadProfilePictureEvent>(_onLoadProfilePicture);
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
    _profilePictureBytes = null;
    emit(UserInitial());
  }

  Future<void> _onUpdateProfilePicture(
    UpdateProfilePictureEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      await _service.updateProfilePicture(
        accessToken: event.accessToken,
        picture: event.file as File,
      );
      final bytes = await _service.getProfilePicture(event.accessToken);
      _profilePictureBytes = Uint8List.fromList(bytes);
      emit(UserProfilePictureUpdated(_profilePictureBytes!));
    } catch (e) {
      print('=== UPDATE PROFILE PICTURE ERROR: $e ===');
      emit(UserError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadProfilePicture(
    LoadProfilePictureEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      final bytes = await _service.getProfilePicture(event.accessToken);
      _profilePictureBytes = Uint8List.fromList(bytes);
      emit(UserProfilePictureLoaded(_profilePictureBytes!));
    } catch (_) {
      _profilePictureBytes = null;
      emit(UserProfilePictureNone());
    }
  }
}
