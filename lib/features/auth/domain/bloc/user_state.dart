import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:quick_forms/features/auth/data/models/user_profile_model.dart';

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

class UserProfilePictureLoaded extends UserState {
  final Uint8List bytes;
  UserProfilePictureLoaded(this.bytes);
  @override
  List<Object?> get props => [bytes];
}

class UserProfilePictureUpdated extends UserState {
  final Uint8List bytes;
  final int updatedAt;
  UserProfilePictureUpdated(this.bytes)
      : updatedAt = DateTime.now().millisecondsSinceEpoch;
  @override
  List<Object?> get props => [bytes, updatedAt];
}

class UserProfilePictureNone extends UserState {}
