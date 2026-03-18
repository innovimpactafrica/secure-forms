import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/client/data/models/profile_model.dart';
import 'package:secure_link/features/client/data/repositories/profile_document_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  static const int _totalDocuments = 6;
  static const double _progressPerDocument = 50.0 / _totalDocuments;

  final ProfileDocumentRepository _repository;
  ProfileDocumentRepository get repository => _repository;

  // Cache des données API
  List<DocumentTypeModel> _documentTypes = [];
  List<UploadedDocumentModel> _uploadedDocuments = [];
  ProfileCompletionModel _completion = const ProfileCompletionModel(
    completion: 50,
    requiredDocuments: [],
  );

  ProfileBloc({ProfileDocumentRepository? repository})
      : _repository = repository ?? ProfileDocumentRepository(),
        super(
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
    on<LoadDocumentTypesEvent>(_onLoadDocumentTypes);
    on<UploadProfileDocumentEvent>(_onUploadProfileDocument);
    on<DeleteProfileDocumentEvent>(_onDeleteProfileDocument);
    on<PatchProfileDocumentEvent>(_onPatchProfileDocument);
    on<FetchDocumentImageEvent>(_onFetchDocumentImage);
  }

  void _log(String msg) {
    // ignore: avoid_print
    print('[ProfileBloc] $msg');
  }

  // ─────────────────────────────────────────────────────────────────
  // CHARGER TYPES + DOCUMENTS + COMPLÉTION
  // ─────────────────────────────────────────────────────────────────
  Future<void> _onLoadDocumentTypes(
    LoadDocumentTypesEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final token = UserSession.instance.accessToken;
    _log('LoadDocumentTypes — token présent: ${token.isNotEmpty}');
    emit(const ProfileLoading());
    try {
      _log('Chargement types de documents...');
      _documentTypes = await _repository.getDocumentTypes(token);
      _log('${_documentTypes.length} type(s) chargé(s)');
      for (final t in _documentTypes) {
        _log('  → id=${t.id} title=${t.title} identityVerif=${t.isForIdentityVerification} required=${t.isRequired}');
      }

      _log('Chargement complétion profil...');
      _completion = await _repository.getProfileCompletion(token);
      _log('Complétion: ${_completion.completion}%');

      _log('Chargement documents uploadés...');
      _uploadedDocuments = await _repository.getDocuments(token);
      _log('${_uploadedDocuments.length} document(s) uploadé(s)');
      for (final d in _uploadedDocuments) {
        _log('  → id=${d.id} typeId=${d.documentTypeId} title=${d.documentTypeTitle} status=${d.status}');
      }

      final currentProfile = _currentProfile(state).copyWith(
        progressPercent: _completion.completion / 100.0,
      );

      emit(ProfileDocumentsLoaded(
        profile: currentProfile,
        documentTypes: _documentTypes,
        uploadedDocuments: _uploadedDocuments,
        completion: _completion,
      ));
    } catch (e) {
      _log('ERREUR LoadDocumentTypes: $e');
      emit(ProfileError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // UPLOAD DOCUMENT VIA API
  // ─────────────────────────────────────────────────────────────────
  Future<void> _onUploadProfileDocument(
    UploadProfileDocumentEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final token = UserSession.instance.accessToken;
    _log('UploadProfileDocument — documentTypeId=${event.documentTypeId}');
    _log('issueDate=${event.issueDate} expirationDate=${event.expirationDate}');

    final currentProfile = _currentProfile(state);

    emit(ProfileDocumentUploading(
      profile: currentProfile,
      documentTypes: _documentTypes,
      uploadedDocuments: _uploadedDocuments,
      completion: _completion,
    ));

    try {
      final uploaded = await _repository.uploadDocument(
        token: token,
        file: event.file,
        documentTypeId: event.documentTypeId,
        issueDate: event.issueDate,
        expirationDate: event.expirationDate,
      );
      _log('Upload réussi ✓ id=${uploaded.id} status=${uploaded.status}');

      // Recharger la liste et la complétion
      _uploadedDocuments = await _repository.getDocuments(token);
      _completion = await _repository.getProfileCompletion(token);
      _log('Complétion après upload: ${_completion.completion}%');

      final updatedProfile = currentProfile.copyWith(
        progressPercent: _completion.completion / 100.0,
      );

      // Trouver le type pour savoir si vérification identité requise
      final docType = _documentTypes.firstWhere(
        (t) => t.id == event.documentTypeId,
        orElse: () => DocumentTypeModel(
          id: event.documentTypeId,
          title: '',
          hasExpirationDate: false,
          isForIdentityVerification: false,
          mappedType: '',
          isRequired: false,
        ),
      );

      _log('isForIdentityVerification=${docType.isForIdentityVerification}');

      if (docType.isForIdentityVerification) {
        emit(ProfileDocumentUploadedNeedsVerification(
          profile: updatedProfile,
          documentTypes: _documentTypes,
          uploadedDocuments: _uploadedDocuments,
          completion: _completion,
          documentType: docType,
        ));
      } else {
        emit(ProfileDocumentUploadedSuccess(
          profile: updatedProfile,
          documentTypes: _documentTypes,
          uploadedDocuments: _uploadedDocuments,
          completion: _completion,
        ));
      }
    } catch (e) {
      _log('ERREUR UploadProfileDocument: $e');
      emit(ProfileError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // SUPPRIMER DOCUMENT VIA API
  // ─────────────────────────────────────────────────────────────────
  Future<void> _onDeleteProfileDocument(
    DeleteProfileDocumentEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final token = UserSession.instance.accessToken;
    _log('DeleteProfileDocument — documentId=${event.documentId}');

    final currentProfile = _currentProfile(state);

    try {
      await _repository.deleteDocument(token: token, documentId: event.documentId);
      _log('Suppression réussie ✓');

      _uploadedDocuments = await _repository.getDocuments(token);
      _completion = await _repository.getProfileCompletion(token);
      _log('Complétion après suppression: ${_completion.completion}%');

      final updatedProfile = currentProfile.copyWith(
        progressPercent: _completion.completion / 100.0,
      );

      emit(ProfileDocumentDeleted(
        profile: updatedProfile,
        documentTypes: _documentTypes,
        uploadedDocuments: _uploadedDocuments,
        completion: _completion,
      ));
    } catch (e) {
      _log('ERREUR DeleteProfileDocument: $e');
      emit(ProfileError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // MODIFIER DATES DOCUMENT VIA API (PATCH)
  // ─────────────────────────────────────────────────────────────────
  Future<void> _onPatchProfileDocument(
    PatchProfileDocumentEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final token = UserSession.instance.accessToken;
    _log('PatchProfileDocument — documentId=${event.documentId}');
    final currentProfile = _currentProfile(state);
    try {
      await _repository.patchDocument(
        token: token,
        documentId: event.documentId,
        issueDate: event.issueDate,
        expirationDate: event.expirationDate,
      );
      _log('Patch réussi ✓');
      _uploadedDocuments = await _repository.getDocuments(token);
      _completion = await _repository.getProfileCompletion(token);
      _log('Complétion après patch: ${_completion.completion}%');
      final updatedProfile = currentProfile.copyWith(
        progressPercent: _completion.completion / 100.0,
      );
      emit(ProfileDocumentPatched(
        profile: updatedProfile,
        documentTypes: _documentTypes,
        uploadedDocuments: _uploadedDocuments,
        completion: _completion,
      ));
    } catch (e) {
      _log('ERREUR PatchProfileDocument: $e');
      emit(ProfileError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // CHARGER IMAGE D'UN DOCUMENT
  // ─────────────────────────────────────────────────────────────────
  Future<void> _onFetchDocumentImage(
    FetchDocumentImageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final token = UserSession.instance.accessToken;
    _log('FetchDocumentImage — documentId=${event.documentId}');
    try {
      final bytes = await _repository.getDocumentFile(
        token: token,
        documentId: event.documentId,
      );
      _log('Image chargée ✓ ${bytes.length} bytes');
      emit(ProfileDocumentImageLoaded(
        documentId: event.documentId,
        bytes: bytes,
      ));
    } catch (e) {
      _log('ERREUR FetchDocumentImage: $e');
      emit(ProfileDocumentImageError(documentId: event.documentId));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // LEGACY HANDLERS (conservés pour compatibilité)
  // ─────────────────────────────────────────────────────────────────
  void _onSavePersonalInfo(
    SavePersonalInfoEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final currentProfile = _currentProfile(state);
    final updatedProfile = currentProfile.copyWith(
      firstName: event.firstName,
      lastName: event.lastName,
      phone: event.phone,
      email: event.email,
      birthDate: event.birthDate,
      gender: event.gender,
      maritalStatus: event.maritalStatus,
      progressPercent: 0.50,
    );
    emit(ProfileStep1Validated(profile: updatedProfile));
  }

  void _onAddDocument(
    AddDocumentEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentProfile = _currentProfile(state);
    final requiresFaceId =
        DocumentType.requireFaceId.contains(event.document.type);
    final updatedDocuments = List<DocumentModel>.from(currentProfile.documents);
    final existingIndex =
        updatedDocuments.indexWhere((d) => d.type == event.document.type);
    if (existingIndex != -1) {
      updatedDocuments[existingIndex] = event.document;
    } else {
      updatedDocuments.add(event.document);
    }
    final updatedProfile =
        currentProfile.copyWith(documents: updatedDocuments);
    emit(ProfileDocumentAdded(
      profile: updatedProfile,
      addedDocument: event.document,
      requiresFaceId: requiresFaceId,
    ));
  }

  void _onFaceVerificationSuccess(
    FaceVerificationSuccessEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentProfile = _currentProfile(state);
    final updatedDocuments = currentProfile.documents.map((doc) {
      if (doc.type == event.documentType) {
        return doc.copyWith(status: DocumentStatus.validated);
      }
      return doc;
    }).toList();
    final validatedCount = updatedDocuments
        .where((d) => d.status == DocumentStatus.validated)
        .length;
    final newProgress = 0.50 + (validatedCount * _progressPerDocument / 100);
    final updatedProfile = currentProfile.copyWith(
      documents: updatedDocuments,
      progressPercent: newProgress.clamp(0.50, 1.0),
    );
    if (validatedCount >= _totalDocuments) {
      emit(ProfileCompleted(
          profile: updatedProfile.copyWith(progressPercent: 1.0)));
    } else {
      emit(ProfileFaceVerificationSuccess(
        profile: updatedProfile,
        documentType: event.documentType,
      ));
    }
  }

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
        profile: currentProfile.copyWith(documents: updatedDocuments)));
  }

  void _onResetProfile(ResetProfileEvent event, Emitter<ProfileState> emit) {
    _documentTypes = [];
    _uploadedDocuments = [];
    _completion = const ProfileCompletionModel(
      completion: 50,
      requiredDocuments: [],
    );
    emit(const ProfileInProgress(
        profile: ProfileModel(progressPercent: 0.50)));
  }

  void _onCompleteProfile(
      CompleteProfileEvent event, Emitter<ProfileState> emit) {
    final currentProfile = _currentProfile(state);
    emit(ProfileCompleted(
        profile: currentProfile.copyWith(progressPercent: 1.0)));
  }

  // ─────────────────────────────────────────────────────────────────
  // HELPER
  // ─────────────────────────────────────────────────────────────────
  ProfileModel _currentProfile(ProfileState state) {
    if (state is ProfileInProgress) return state.profile;
    if (state is ProfileStep1Validated) return state.profile;
    if (state is ProfileDocumentAdded) return state.profile;
    if (state is ProfileFaceVerificationSuccess) return state.profile;
    if (state is ProfileFaceVerificationFailed) return state.profile;
    if (state is ProfileCompleted) return state.profile;
    if (state is ProfileDocumentsLoaded) return state.profile;
    if (state is ProfileDocumentUploading) return state.profile;
    if (state is ProfileDocumentUploadedNeedsVerification) return state.profile;
    if (state is ProfileDocumentUploadedSuccess) return state.profile;
    if (state is ProfileDocumentDeleted) return state.profile;
    if (state is ProfileDocumentPatched) return state.profile;
    return const ProfileModel(progressPercent: 0.50);
  }
}
