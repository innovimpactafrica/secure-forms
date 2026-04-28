
import 'package:secure_link/features/client/data/models/profile_model.dart';

/// États du ProfileBloc
abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profil en cours de complétion — état principal
class ProfileInProgress extends ProfileState {
  final ProfileModel profile;

  const ProfileInProgress({required this.profile});

  double get progress => profile.progressPercent;
  bool get isPersonalInfoComplete => profile.firstName.isNotEmpty;
  int get validatedDocumentsCount =>
      profile.documents
          .where((d) => d.status == DocumentStatus.validated)
          .length;
}

/// Étape 1 validée
class ProfileStep1Validated extends ProfileState {
  final ProfileModel profile;
  const ProfileStep1Validated({required this.profile});
}

/// Un document local vient d'être ajouté
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

/// Face ID validé
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

// ─────────────────────────────────────────────────────────────────
// STATES API — Profile Documents
// ─────────────────────────────────────────────────────────────────

/// Types de documents + documents uploadés chargés depuis l'API
class ProfileDocumentsLoaded extends ProfileState {
  final ProfileModel profile;
  final List<DocumentTypeModel> documentTypes;
  final List<UploadedDocumentModel> uploadedDocuments;
  final ProfileCompletionModel completion;

  const ProfileDocumentsLoaded({
    required this.profile,
    required this.documentTypes,
    required this.uploadedDocuments,
    required this.completion,
  });
}

/// Upload en cours
class ProfileDocumentUploading extends ProfileState {
  final ProfileModel profile;
  final List<DocumentTypeModel> documentTypes;
  final List<UploadedDocumentModel> uploadedDocuments;
  final ProfileCompletionModel completion;

  const ProfileDocumentUploading({
    required this.profile,
    required this.documentTypes,
    required this.uploadedDocuments,
    required this.completion,
  });
}

/// Upload réussi — document nécessitant vérification identité
class ProfileDocumentUploadedNeedsVerification extends ProfileState {
  final ProfileModel profile;
  final List<DocumentTypeModel> documentTypes;
  final List<UploadedDocumentModel> uploadedDocuments;
  final ProfileCompletionModel completion;
  final DocumentTypeModel documentType;

  const ProfileDocumentUploadedNeedsVerification({
    required this.profile,
    required this.documentTypes,
    required this.uploadedDocuments,
    required this.completion,
    required this.documentType,
  });
}

/// Upload réussi — document sans vérification identité
class ProfileDocumentUploadedSuccess extends ProfileState {
  final ProfileModel profile;
  final List<DocumentTypeModel> documentTypes;
  final List<UploadedDocumentModel> uploadedDocuments;
  final ProfileCompletionModel completion;

  const ProfileDocumentUploadedSuccess({
    required this.profile,
    required this.documentTypes,
    required this.uploadedDocuments,
    required this.completion,
  });
}

/// Suppression réussie
class ProfileDocumentDeleted extends ProfileState {
  final ProfileModel profile;
  final List<DocumentTypeModel> documentTypes;
  final List<UploadedDocumentModel> uploadedDocuments;
  final ProfileCompletionModel completion;

  const ProfileDocumentDeleted({
    required this.profile,
    required this.documentTypes,
    required this.uploadedDocuments,
    required this.completion,
  });
}

/// Modification dates réussie (PATCH)
class ProfileDocumentPatched extends ProfileState {
  final ProfileModel profile;
  final List<DocumentTypeModel> documentTypes;
  final List<UploadedDocumentModel> uploadedDocuments;
  final ProfileCompletionModel completion;

  const ProfileDocumentPatched({
    required this.profile,
    required this.documentTypes,
    required this.uploadedDocuments,
    required this.completion,
  });
}

/// Image d'un document chargée
class ProfileDocumentImageLoaded extends ProfileState {
  final String documentId;
  final List<int> bytes;
  const ProfileDocumentImageLoaded({
    required this.documentId,
    required this.bytes,
  });
}

/// Erreur chargement image document
class ProfileDocumentImageError extends ProfileState {
  final String documentId;
  const ProfileDocumentImageError({required this.documentId});
}
