import 'package:shared_preferences/shared_preferences.dart';
import 'package:quick_forms/core/utils/user_session.dart';
import 'package:quick_forms/features/kyc/data/repositories/identity_document_repository.dart';

class KycChecker {
  static Future<bool> isKycCompleted() async {
    final token = UserSession.instance.accessToken;
    final userId = UserSession.instance.userId;

    if (token.isEmpty || userId.isEmpty) return false;

    // 1. Vérifier le cache local d'abord
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getBool('kyc_completed_$userId') ?? false;
    if (cached) return true;

    // 2. Vérifier via l'API backend
    try {
      final repo = IdentityDocumentRepository();
      final docs = await repo.getDocuments(token);
      final hasRecto = docs.any((d) => d.kind.toUpperCase() == 'RECTO');
      final hasSelfie = docs.any((d) => d.kind.toUpperCase() == 'SELFIE');
      final done = hasRecto && hasSelfie;

      // Mettre à jour le cache si KYC complété
      if (done) await prefs.setBool('kyc_completed_$userId', true);

      return done;
    } catch (_) {
      return false;
    }
  }
}
