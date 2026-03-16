import 'package:equatable/equatable.dart';
import 'package:secure_link/features/auth/data/models/user_profile_model.dart';

abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserProfileModel user;
  UserLoaded(this.user);
  @override
  List<Object?> get props => [user];
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
  @override
  List<Object?> get props => [message];
}
