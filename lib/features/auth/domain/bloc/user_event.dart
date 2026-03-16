abstract class UserEvent {}

class LoadUserProfile extends UserEvent {
  final String accessToken;
  LoadUserProfile(this.accessToken);
}

class ClearUserProfile extends UserEvent {}
