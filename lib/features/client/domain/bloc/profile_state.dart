

import 'package:secure_link/features/client/data/models/profile_model.dart';

/// États du ProfileBloc
abstract class ProfileState {
  const ProfileState();
}

/// État initial au démarrage
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Chargement en cours (future API call)
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profil en cours de complétion — état principal
class ProfileInProgress extends ProfileState {
  final ProfileModel profile;

  const ProfileInProgress({required this.profile});

  /// Raccourcis utiles dans les widgets
  double get progress => profile.progressPercent;
  bool get isPersonalInfoComplete => profile.firstName.isNotEmpty;
  int get validatedDocumentsCount =>
      profile.documents
          .where((d) => d.status == DocumentStatus.validated)
          .length;
}

/// Étape 1 validée — on navigue vers Étape 2
class ProfileStep1Validated extends ProfileState {
  final ProfileModel profile;

  const ProfileStep1Validated({required this.profile});
}

/// Un document vient d'être ajouté — on déclenche Face ID si nécessaire
class ProfileDocumentAdded extends ProfileState {
  final ProfileModel profile;
  final DocumentModel addedDocument;
  final bool requiresFaceId;

  const ProfileDocumentAdded({
    required this.profile,
    required this.addedDocument,
    required this.requiresFaceId,
  });
}

/// Face ID validé pour un document
class ProfileFaceVerificationSuccess extends ProfileState {
  final ProfileModel profile;
  final String documentType;

  const ProfileFaceVerificationSuccess({
    required this.profile,
    required this.documentType,
  });
}

/// Face ID échoué
class ProfileFaceVerificationFailed extends ProfileState {
  final ProfileModel profile;
  final String documentType;
  final String reason;

  const ProfileFaceVerificationFailed({
    required this.profile,
    required this.documentType,
    required this.reason,
  });
}

/// Profil complété à 100%
class ProfileCompleted extends ProfileState {
  final ProfileModel profile;

  const ProfileCompleted({required this.profile});
}

/// Erreur
class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});
}