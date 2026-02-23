

import 'package:secure_link/features/client/data/models/profile_model.dart';

/// Events du ProfileBloc
/// TODO: ajouter les events API (SaveProfileToServer, UploadDocumentToServer)
/// lors de l'intégration des endpoints
abstract class ProfileEvent {
  const ProfileEvent();
}

/// Sauvegarde des informations personnelles (Étape 1)
class SavePersonalInfoEvent extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String birthDate;
  final String gender;
  final String maritalStatus;

  const SavePersonalInfoEvent({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.birthDate,
    required this.gender,
    required this.maritalStatus,
  });
}

/// Ajout d'un document avec vérification (Étape 2)
class AddDocumentEvent extends ProfileEvent {
  final DocumentModel document;

  const AddDocumentEvent({required this.document});
}

/// Face ID validé pour un document
class FaceVerificationSuccessEvent extends ProfileEvent {
  final String documentType;

  const FaceVerificationSuccessEvent({required this.documentType});
}

/// Face ID échoué pour un document
class FaceVerificationFailedEvent extends ProfileEvent {
  final String documentType;
  final String reason;

  const FaceVerificationFailedEvent({
    required this.documentType,
    required this.reason,
  });
}

/// Mise à jour du statut d'un document
class UpdateDocumentStatusEvent extends ProfileEvent {
  final String documentType;
  final DocumentStatus status;

  const UpdateDocumentStatusEvent({
    required this.documentType,
    required this.status,
  });
}

/// Reset du profil (déconnexion)
class ResetProfileEvent extends ProfileEvent {
  const ResetProfileEvent();
}

/// Profil complété manuellement par l'utilisateur
class CompleteProfileEvent extends ProfileEvent {
  const CompleteProfileEvent();
}