import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/kyc/data/models/identity_document_model.dart';
import 'package:secure_link/features/kyc/data/repositories/identity_document_repository.dart';
import 'kyc_event.dart';
import 'kyc_state.dart';

class KycBloc extends Bloc<KycEvent, KycState> {
  final String userId;
  final IdentityDocumentRepository _repository;

  KycBloc({
    required this.userId,
    IdentityDocumentRepository? repository,
  })  : _repository = repository ?? IdentityDocumentRepository(),
        super(const KycInitial()) {
    on<KycCheckStatus>(_onCheckStatus);
    on<KycMarkCompleted>(_onMarkCompleted);
    on<KycUploadIdDocuments>(_onUploadIdDocuments);
    on<KycUploadSelfie>(_onUploadSelfie);
    on<KycLoadDocuments>(_onLoadDocuments);
  }

  String get _kycKey => 'kyc_completed_$userId';

  Future<void> _onCheckStatus(
      KycCheckStatus event, Emitter<KycState> emit) async {
    _log('━━━ KycCheckStatus ━━━ userId: "$userId"');

    // Émettre KycChecking pour forcer un changement d'état
    // (évite que BLoC ignore KycRequired si déjà en KycRequired)
    emit(const KycChecking());

    if (userId.isEmpty) {
      _log('userId vide → KycRequired émis');
      emit(const KycRequired());
      return;
    }

    // 1. Cache local
    final prefs = await SharedPreferences.getInstance();
    final cachedCompleted = prefs.getBool(_kycKey) ?? false;
    _log('Cache local "$_kycKey" = $cachedCompleted');

    if (cachedCompleted) {
      _log('Cache local: KYC déjà complété → KycCompleted émis');
      emit(const KycCompleted());
      return;
    }

    // 2. Vérification API
    try {
      final token = UserSession.instance.accessToken;
      _log('Token présent: ${token.isNotEmpty} (longueur: ${token.length})');

      if (token.isEmpty) {
        _log('Token vide → KycRequired émis');
        emit(const KycRequired());
        return;
      }

      _log('Appel API identity-documents...');
      final docs = await _repository.getDocuments(token);
      _log('API: ${docs.length} document(s) reçu(s)');
      for (final d in docs) {
        _log('  doc → id=${d.id} kind=${d.kind} status=${d.status}');
      }

      final hasRecto = docs.any((d) => d.kind.toUpperCase() == 'RECTO');
      final hasSelfie = docs.any((d) => d.kind.toUpperCase() == 'SELFIE');
      _log('hasRecto=$hasRecto | hasSelfie=$hasSelfie');

      if (hasRecto && hasSelfie) {
        _log('API: recto+selfie présents → KYC validé, sauvegarde cache + KycCompleted émis');
        await prefs.setBool(_kycKey, true);
        emit(const KycCompleted());
      } else {
        _log('API: documents incomplets → KycRequired émis');
        emit(const KycRequired());
      }
    } catch (e) {
      _log('ERREUR appel API: $e → KycRequired émis par défaut');
      emit(const KycRequired());
    }
  }

  Future<void> _onMarkCompleted(
      KycMarkCompleted event, Emitter<KycState> emit) async {
    _log('━━━ KycMarkCompleted ━━━ userId: "$userId"');
    if (userId.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kycKey, true);
      _log('SharedPreferences "$_kycKey" = true → sauvegardé');
    } else {
      _log('userId vide → pas de sauvegarde SharedPreferences');
    }
    _log('KycCompleted émis');
    emit(const KycCompleted());
  }

  Future<void> _onUploadIdDocuments(
      KycUploadIdDocuments event, Emitter<KycState> emit) async {
    _log('━━━ KycUploadIdDocuments ━━━');
    _log('recto: ${event.recto.path}');
    _log('verso: ${event.verso.path}');
    _log('token présent: ${event.token.isNotEmpty} (longueur: ${event.token.length})');
    emit(const KycUploading(message: 'Envoi de la pièce d\'identité...'));
    try {
      _log('Upload RECTO → kind=RECTO documentTypeId=${event.documentTypeId}');
      final rectoResult = await _repository.uploadDocument(
        token: event.token,
        file: event.recto,
        kind: DocumentKind.recto,
        documentTypeId: event.documentTypeId,
      );
      _log('RECTO uploadé ✓ id=${rectoResult.id} status=${rectoResult.status}');

      _log('Upload VERSO → kind=VERSO documentTypeId=${event.documentTypeId}');
      final versoResult = await _repository.uploadDocument(
        token: event.token,
        file: event.verso,
        kind: DocumentKind.verso,
        documentTypeId: event.documentTypeId,
      );
      _log('VERSO uploadé ✓ id=${versoResult.id} status=${versoResult.status}');

      _log('KycIdDocumentsUploaded émis');
      emit(KycIdDocumentsUploaded(recto: rectoResult, verso: versoResult));
    } catch (e) {
      _log('ERREUR upload ID documents: $e');
      emit(KycError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUploadSelfie(
      KycUploadSelfie event, Emitter<KycState> emit) async {
    _log('━━━ KycUploadSelfie ━━━');
    _log('selfie: ${event.selfie.path}');
    _log('token présent: ${event.token.isNotEmpty} (longueur: ${event.token.length})');
    emit(const KycUploading(message: 'Envoi du selfie...'));
    try {
      _log('Upload SELFIE → kind=SELFIE');
      final selfieResult = await _repository.uploadDocument(
        token: event.token,
        file: event.selfie,
        kind: DocumentKind.selfie,
      );
      _log('SELFIE uploadé ✓ id=${selfieResult.id} status=${selfieResult.status}');
      _log('KycSelfieUploaded émis (KycMarkCompleted sera appelé par la page preview)');
      emit(KycSelfieUploaded(selfie: selfieResult));
    } catch (e) {
      _log('ERREUR upload selfie: $e');
      emit(KycError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadDocuments(
      KycLoadDocuments event, Emitter<KycState> emit) async {
    _log('━━━ KycLoadDocuments ━━━');
    try {
      final docs = await _repository.getDocuments(event.token);
      _log('${docs.length} document(s) chargé(s)');
      for (final d in docs) {
        _log('  → id=${d.id} kind=${d.kind} status=${d.status}');
      }
      emit(KycDocumentsLoaded(documents: docs));
    } catch (e) {
      _log('ERREUR chargement documents: $e');
      emit(KycError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _log(String msg) {
    // ignore: avoid_print
    print('[KycBloc] $msg');
  }
}
