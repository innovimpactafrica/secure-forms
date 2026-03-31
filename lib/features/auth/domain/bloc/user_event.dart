abstract class UserEvent {}

class LoadUserProfile extends UserEvent {
  final String accessToken;
  LoadUserProfile(this.accessToken);
}

class ClearUserProfile extends UserEvent {}

class UpdateProfilePictureEvent extends UserEvent {
  final String accessToken;
  final dynamic file; // File
  UpdateProfilePictureEvent({required this.accessToken, required this.file});
}

class LoadProfilePictureEvent extends UserEvent {
  final String accessToken;
  LoadProfilePictureEvent(this.accessToken);
}

class ResetUserEvent extends UserEvent {}
