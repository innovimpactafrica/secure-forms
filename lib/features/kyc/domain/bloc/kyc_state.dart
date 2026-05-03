import 'package:quick_forms/features/kyc/data/models/identity_document_model.dart';

abstract class KycState {
  const KycState();
}

class KycInitial extends KycState {
  const KycInitial();
}

class KycChecking extends KycState {
  const KycChecking();
}

class KycRequired extends KycState {
  const KycRequired();
}

class KycCompleted extends KycState {
  const KycCompleted();
}

/// Upload en cours
class KycUploading extends KycState {
  final String message;
  const KycUploading({this.message = 'Envoi en cours...'});
}

/// Upload recto/verso réussi → passer à l'étape selfie
class KycIdDocumentsUploaded extends KycState {
  final UploadDocumentResponse recto;
  final UploadDocumentResponse verso;
  const KycIdDocumentsUploaded({required this.recto, required this.verso});
}

/// Upload selfie réussi → afficher modal succès
class KycSelfieUploaded extends KycState {
  final UploadDocumentResponse selfie;
  const KycSelfieUploaded({required this.selfie});
}

/// Documents chargés depuis l'API
class KycDocumentsLoaded extends KycState {
  final List<IdentityDocumentModel> documents;
  const KycDocumentsLoaded({required this.documents});
}

/// Erreur API
class KycError extends KycState {
  final String message;
  const KycError({required this.message});
}
