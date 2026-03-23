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
    _log('KycCheckStatus — userId: "$userId"');
    if (userId.isEmpty) {
      _log('userId vide → KycRequired');
      emit(const KycRequired());
      return;
    }

    // 1. Vérifier d'abord le cache local
    final prefs = await SharedPreferences.getInstance();
    final cachedCompleted = prefs.getBool(_kycKey) ?? false;
    if (cachedCompleted) {
      _log('Cache local: KYC déjà completé → KycCompleted');
      emit(const KycCompleted());
      return;
    }

    // 2. Vérifier via l'API si les documents ont été soumis
    try {
      final token = UserSession.instance.accessToken;
      if (token.isEmpty) {
        emit(const KycRequired());
        return;
      }
      final docs = await _repository.getDocuments(token);
      _log('API: ${docs.length} document(s) trouvé(s)');

      // KYC considéré complet si au moins RECTO et SELFIE ont été soumis
      final hasRecto = docs.any((d) => d.kind.toUpperCase() == 'RECTO');
      final hasSelfie = docs.any((d) => d.kind.toUpperCase() == 'SELFIE');
      final apiCompleted = hasRecto && hasSelfie;

      _log('hasRecto=$hasRecto hasSelfie=$hasSelfie → ${apiCompleted ? "KycCompleted" : "KycRequired"}');

      if (apiCompleted) {
        // Sauvegarder localement pour éviter l'appel API au prochain démarrage
        await prefs.setBool(_kycKey, true);
        emit(const KycCompleted());
      } else {
        emit(const KycRequired());
      }
    } catch (e) {
      _log('Erreur vérification API KYC: $e → fallback KycRequired');
      emit(const KycRequired());
    }
  }

  Future<void> _onMarkCompleted(
      KycMarkCompleted event, Emitter<KycState> emit) async {
    _log('KycMarkCompleted — sauvegarde $_kycKey = true');
    if (userId.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kycKey, true);
    }
    emit(const KycCompleted());
  }

  Future<void> _onUploadIdDocuments(
      KycUploadIdDocuments event, Emitter<KycState> emit) async {
    _log('KycUploadIdDocuments — recto: ${event.recto.path} | verso: ${event.verso.path}');
    _log('Token présent: ${event.token.isNotEmpty} (longueur: ${event.token.length})');
    emit(const KycUploading(message: 'Envoi de la pièce d\'identité...'));
    try {
      _log('Upload RECTO → POST ${_kycKey.contains("_") ? "identityDocuments" : ""} kind=RECTO');
      final rectoResult = await _repository.uploadDocument(
        token: event.token,
        file: event.recto,
        kind: DocumentKind.recto,
      );
      _log('RECTO uploadé ✓ id=${rectoResult.id} status=${rectoResult.status}');

      _log('Upload VERSO → POST kind=VERSO');
      final versoResult = await _repository.uploadDocument(
        token: event.token,
        file: event.verso,
        kind: DocumentKind.verso,
      );
      _log('VERSO uploadé ✓ id=${versoResult.id} status=${versoResult.status}');

      emit(KycIdDocumentsUploaded(recto: rectoResult, verso: versoResult));
    } catch (e) {
      _log('ERREUR upload ID documents: $e');
      emit(KycError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUploadSelfie(
      KycUploadSelfie event, Emitter<KycState> emit) async {
    _log('KycUploadSelfie — selfie: ${event.selfie.path}');
    _log('Token présent: ${event.token.isNotEmpty} (longueur: ${event.token.length})');
    emit(const KycUploading(message: 'Envoi du selfie...'));
    try {
      _log('Upload SELFIE → POST kind=SELFIE');
      final selfieResult = await _repository.uploadDocument(
        token: event.token,
        file: event.selfie,
        kind: DocumentKind.selfie,
      );
      _log('SELFIE uploadé ✓ id=${selfieResult.id} status=${selfieResult.status}');

      if (userId.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_kycKey, true);
        _log('KYC marqué complété localement pour userId=$userId');
      }
      emit(KycSelfieUploaded(selfie: selfieResult));
    } catch (e) {
      _log('ERREUR upload selfie: $e');
      emit(KycError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadDocuments(
      KycLoadDocuments event, Emitter<KycState> emit) async {
    _log('KycLoadDocuments — chargement liste documents');
    try {
      final docs = await _repository.getDocuments(event.token);
      _log('Documents chargés: ${docs.length} document(s)');
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
