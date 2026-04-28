
import 'dart:io';
import 'package:secure_link/features/client/data/models/profile_model.dart';

/// Events du ProfileBloc
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

/// Ajout d'un document local (legacy)
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

/// Profil complété manuellement
class CompleteProfileEvent extends ProfileEvent {
  const CompleteProfileEvent();
}

// ─────────────────────────────────────────────────────────────────
// EVENTS API — Profile Documents
// ─────────────────────────────────────────────────────────────────

/// Charger les types de documents disponibles + complétion
class LoadDocumentTypesEvent extends ProfileEvent {
  final bool forceRefresh;
  const LoadDocumentTypesEvent({this.forceRefresh = false});
}

/// Upload d'un document via l'API
class UploadProfileDocumentEvent extends ProfileEvent {
  final File file;
  final File? backFile;
  final String documentTypeId;
  final String? issueDate;
  final String? expirationDate;
  final bool skipPreDelete; // true quand la suppression est déjà faite en amont

  const UploadProfileDocumentEvent({
    required this.file,
    this.backFile,
    required this.documentTypeId,
    this.issueDate,
    this.expirationDate,
    this.skipPreDelete = false,
  });
}

/// Supprimer un document via l'API
class DeleteProfileDocumentEvent extends ProfileEvent {
  final String documentId;
  const DeleteProfileDocumentEvent({required this.documentId});
}

/// Remplacer le fichier d'un document individuel via PATCH
class ReplaceProfileDocumentFileEvent extends ProfileEvent {
  final String documentId;
  final File file;
  final String? issueDate;
  final String? expirationDate;
  const ReplaceProfileDocumentFileEvent({
    required this.documentId,
    required this.file,
    this.issueDate,
    this.expirationDate,
  });
}

/// Modifier les dates d'un document existant (PATCH)
class PatchProfileDocumentEvent extends ProfileEvent {
  final String documentId;
  final String? issueDate;
  final String? expirationDate;
  const PatchProfileDocumentEvent({
    required this.documentId,
    this.issueDate,
    this.expirationDate,
  });
}

/// Charger les bytes d'un fichier document
class FetchDocumentImageEvent extends ProfileEvent {
  final String documentId;
  const FetchDocumentImageEvent({required this.documentId});
}
