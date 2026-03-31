import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:secure_link/core/services/fcm_service.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/auth/data/models/user_profile_model.dart';
import 'package:secure_link/features/auth/data/services/user_profile_service.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserProfileService _service;
  Uint8List? _profilePictureBytes;
  Uint8List? get profilePictureBytes => _profilePictureBytes;
  UserProfileModel? _cachedUser;
  UserProfileModel? get cachedUser => _cachedUser;

  UserBloc({UserProfileService? service})
      : _service = service ?? UserProfileService(),
        super(UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<ClearUserProfile>(_onClearUserProfile);
    on<UpdateProfilePictureEvent>(_onUpdateProfilePicture);
    on<ResetUserEvent>((_, emit) {
      _profilePictureBytes = null;
      _cachedUser = null;
      UserProfileService.invalidateCache();
      emit(UserInitial());
    });
    on<LoadProfilePictureEvent>(
      _onLoadProfilePicture,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    // Si déjà en cache, émettre immédiatement sans appel API
    if (_cachedUser != null) {
      print('=== USER PROFILE: cache HIT, émission immédiate ===');
      emit(UserLoaded(_cachedUser!));
      // Photo aussi en cache ? sinon charger en arrière-plan
      if (_profilePictureBytes == null) {
        _loadPictureInBackground(event.accessToken);
      }
      return;
    }
    emit(UserLoading());
    try {
      final user = await _service.getProfile(event.accessToken);
      print('=== USER PROFILE LOADED: firstName=${user.firstName} lastName=${user.lastName} ===');
      _cachedUser = user;
      UserSession.instance.userId = user.id;
      _persistUserId(user.id);
      FcmService.onUserLoggedIn(user.id);
      emit(UserLoaded(user));
      // Charger la photo en arrière-plan après avoir émis UserLoaded
      if (_profilePictureBytes == null) {
        _loadPictureInBackground(event.accessToken, userId: user.id);
      }
    } catch (e) {
      print('=== USER PROFILE ERROR: $e ===');
      if (_cachedUser != null) {
        print('=== USER PROFILE: utilisation du cache après erreur ===');
        emit(UserLoaded(_cachedUser!));
      } else {
        emit(UserError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  void _loadPictureInBackground(String accessToken, {String? userId}) {
    // Déclencher l'événement de chargement photo — traité par son propre handler
    add(LoadProfilePictureEvent(accessToken));
  }

  void _persistUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_user_id', userId);
    } catch (_) {}
  }

  void _onClearUserProfile(ClearUserProfile event, Emitter<UserState> emit) {
    _profilePictureBytes = null;
    _cachedUser = null;
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
      print('=== PATCH /users/me/profile (photo) SUCCESS ===');
      // Invalider le cache avant de recharger
      _profilePictureBytes = null;
      UserProfileService.invalidateCache();
      final userId = _cachedUser?.id ?? UserSession.instance.userId;
      final bytes = await _service.getProfilePicture(event.accessToken, userId: userId);
      _profilePictureBytes = Uint8List.fromList(bytes);
      print('=== PROFILE PICTURE REFRESHED: ${_profilePictureBytes!.length} bytes ===');
      emit(UserProfilePictureUpdated(_profilePictureBytes!));
      if (_cachedUser != null) emit(UserLoaded(_cachedUser!));
    } catch (e) {
      print('=== UPDATE PROFILE PICTURE ERROR: $e ===');
      emit(UserError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadProfilePicture(
    LoadProfilePictureEvent event,
    Emitter<UserState> emit,
  ) async {
    // Si déjà en cache mémoire, émettre immédiatement
    if (_profilePictureBytes != null) {
      print('=== PROFILE PICTURE: cache mémoire UserBloc HIT ===');
      emit(UserProfilePictureLoaded(_profilePictureBytes!));
      return;
    }
    try {
      final userId = _cachedUser?.id ?? UserSession.instance.userId;
      final bytes = await _service.getProfilePicture(event.accessToken, userId: userId);
      _profilePictureBytes = Uint8List.fromList(bytes);
      print('=== PROFILE PICTURE LOADED: ${_profilePictureBytes!.length} bytes ===');
      emit(UserProfilePictureLoaded(_profilePictureBytes!));
    } catch (_) {
      _profilePictureBytes = null;
      emit(UserProfilePictureNone());
    }
  }
}
