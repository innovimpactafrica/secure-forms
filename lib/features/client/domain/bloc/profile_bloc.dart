import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/features/client/data/models/profile_model.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// ProfileBloc — gère la progression du profil client
///
/// Progression :
///   50% → initial (après connexion)
///   50% à 100% → chaque document validé ajoute (50 / nbDocuments) %
///
/// TODO: remplacer les emit locaux par des appels API quand les endpoints
/// seront disponibles. Chercher les commentaires "TODO: API" dans ce fichier.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  /// Nombre total de documents requis (6 selon le Figma)
  static const int _totalDocuments = 6;

  /// Pourcentage gagné par document validé
  static const double _progressPerDocument = 50.0 / _totalDocuments;

  ProfileBloc()
      : super(
          const ProfileInProgress(
            profile: ProfileModel(progressPercent: 0.50),
          ),
        ) {
    on<SavePersonalInfoEvent>(_onSavePersonalInfo);
    on<AddDocumentEvent>(_onAddDocument);
    on<FaceVerificationSuccessEvent>(_onFaceVerificationSuccess);
    on<FaceVerificationFailedEvent>(_onFaceVerificationFailed);
    on<UpdateDocumentStatusEvent>(_onUpdateDocumentStatus);
    on<ResetProfileEvent>(_onResetProfile);
    on<CompleteProfileEvent>(_onCompleteProfile);
  }

  // ─────────────────────────────────────────────────────────────────
  // ÉTAPE 1 : Sauvegarder les infos personnelles → 50%
  // ─────────────────────────────────────────────────────────────────
  void _onSavePersonalInfo(
    SavePersonalInfoEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    // TODO: API — POST /profile/personal-info avec les données du formulaire
    // final response = await profileRepository.savePersonalInfo(event);
    // if (response.isSuccess) { ... } else { emit(ProfileError(...)) }

    final currentProfile = _currentProfile(state);

    final updatedProfile = currentProfile.copyWith(
      firstName: event.firstName,
      lastName: event.lastName,
      phone: event.phone,
      email: event.email,
      birthDate: event.birthDate,
      gender: event.gender,
      maritalStatus: event.maritalStatus,
      progressPercent: 0.50, // Étape 1 validée → 50%
    );

    emit(ProfileStep1Validated(profile: updatedProfile));
  }

  // ─────────────────────────────────────────────────────────────────
  // ÉTAPE 2 : Ajouter un document
  // ─────────────────────────────────────────────────────────────────
  void _onAddDocument(
    AddDocumentEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentProfile = _currentProfile(state);

    // Vérifier si le document nécessite Face ID
    final requiresFaceId =
        DocumentType.requireFaceId.contains(event.document.type);

    // Ajouter/remplacer le document dans la liste
    final updatedDocuments = List<DocumentModel>.from(currentProfile.documents);
    final existingIndex = updatedDocuments
        .indexWhere((d) => d.type == event.document.type);
    if (existingIndex != -1) {
      updatedDocuments[existingIndex] = event.document;
    } else {
      updatedDocuments.add(event.document);
    }

    final updatedProfile = currentProfile.copyWith(
      documents: updatedDocuments,
    );

    emit(ProfileDocumentAdded(
      profile: updatedProfile,
      addedDocument: event.document,
      requiresFaceId: requiresFaceId,
    ));
  }

  // ─────────────────────────────────────────────────────────────────
  // ÉTAPE 2 : Face ID validé → document validé + progression
  // ─────────────────────────────────────────────────────────────────
  void _onFaceVerificationSuccess(
    FaceVerificationSuccessEvent event,
    Emitter<ProfileState> emit,
  ) async {
    // TODO: API — POST /documents/face-verify avec le résultat
    // + vérification date délivrance/expiration côté serveur

    final currentProfile = _currentProfile(state);

    final updatedDocuments = currentProfile.documents.map((doc) {
      if (doc.type == event.documentType) {
        return doc.copyWith(status: DocumentStatus.validated);
      }
      return doc;
    }).toList();

    // Recalculer la progression
    final validatedCount = updatedDocuments
        .where((d) => d.status == DocumentStatus.validated)
        .length;
    final newProgress = 0.50 + (validatedCount * _progressPerDocument / 100);

    final updatedProfile = currentProfile.copyWith(
      documents: updatedDocuments,
      progressPercent: newProgress.clamp(0.50, 1.0),
    );

    // Si tous les documents sont validés → 100%
    if (validatedCount >= _totalDocuments) {
      emit(ProfileCompleted(
        profile: updatedProfile.copyWith(progressPercent: 1.0),
      ));
    } else {
      emit(ProfileFaceVerificationSuccess(
        profile: updatedProfile,
        documentType: event.documentType,
      ));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Face ID échoué
  // ─────────────────────────────────────────────────────────────────
  void _onFaceVerificationFailed(
    FaceVerificationFailedEvent event,
    Emitter<ProfileState> emit,
  ) {
    final currentProfile = _currentProfile(state);

    final updatedDocuments = currentProfile.documents.map((doc) {
      if (doc.type == event.documentType) {
        return doc.copyWith(status: DocumentStatus.rejected);
      }
      return doc;
    }).toList();

    emit(ProfileFaceVerificationFailed(
      profile: currentProfile.copyWith(documents: updatedDocuments),
      documentType: event.documentType,
      reason: event.reason,
    ));
  }

  // ─────────────────────────────────────────────────────────────────
  // Mise à jour manuelle du statut d'un document
  // ─────────────────────────────────────────────────────────────────
  void _onUpdateDocumentStatus(
    UpdateDocumentStatusEvent event,
    Emitter<ProfileState> emit,
  ) {
    final currentProfile = _currentProfile(state);

    final updatedDocuments = currentProfile.documents.map((doc) {
      if (doc.type == event.documentType) {
        return doc.copyWith(status: event.status);
      }
      return doc;
    }).toList();

    emit(ProfileInProgress(
      profile: currentProfile.copyWith(documents: updatedDocuments),
    ));
  }

  // ─────────────────────────────────────────────────────────────────
  // Reset (déconnexion)
  // ─────────────────────────────────────────────────────────────────
  void _onResetProfile(
    ResetProfileEvent event,
    Emitter<ProfileState> emit,
  ) {
    emit(const ProfileInProgress(
      profile: ProfileModel(progressPercent: 0.50),
    ));
  }

  void _onCompleteProfile(
  CompleteProfileEvent event,
  Emitter<ProfileState> emit,
) {
  final currentProfile = _currentProfile(state);
  emit(ProfileCompleted(
    profile: currentProfile.copyWith(progressPercent: 1.0),
  ));
}

  // ─────────────────────────────────────────────────────────────────
  // Helper: extraire le ProfileModel de n'importe quel état
  // ─────────────────────────────────────────────────────────────────
  ProfileModel _currentProfile(ProfileState state) {
    if (state is ProfileInProgress) return state.profile;
    if (state is ProfileStep1Validated) return state.profile;
    if (state is ProfileDocumentAdded) return state.profile;
    if (state is ProfileFaceVerificationSuccess) return state.profile;
    if (state is ProfileFaceVerificationFailed) return state.profile;
    if (state is ProfileCompleted) return state.profile;
    return const ProfileModel(progressPercent: 0.50);
  }
}