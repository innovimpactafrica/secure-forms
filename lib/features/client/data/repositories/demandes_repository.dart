import 'package:secure_link/features/client/data/models/demande_model.dart';
import 'package:secure_link/features/client/data/services/demandes_service.dart';

class DemandesRepository {
  final DemandesService _service;
  DemandesRepository({DemandesService? service})
      : _service = service ?? DemandesService();

  Future<List<DemandeModel>> getRecentRequests({
    required String accessToken,
    int limit = 5,
    String? status,
    String? category,
    String? institution,
    String? type,
    String? search,
  }) =>
      _service.getRecentRequests(
        accessToken: accessToken,
        limit: limit,
        status: status,
        category: category,
        institution: institution,
        type: type,
        search: search,
      );

  Future<DemandesPage> getRequests({
    required String accessToken,
    String? status,
    String? formType,
    String? sector,
    String? search,
    int page = 1,
    int limit = 10,
  }) =>
      _service.getRequests(
        accessToken: accessToken,
        status: status,
        formType: formType,
        sector: sector,
        search: search,
        page: page,
        limit: limit,
      );

  Future<DemandeModel> getRequestById({
    required String accessToken,
    required String id,
  }) =>
      _service.getRequestById(accessToken: accessToken, id: id);

  Future<void> deleteDraft({
    required String accessToken,
    required String id,
  }) =>
      _service.deleteDraft(accessToken: accessToken, id: id);
}
