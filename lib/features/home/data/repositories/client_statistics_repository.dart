import '../models/client_statistics_model.dart';
import '../services/client_statistics_service.dart';

class ClientStatisticsRepository {
  final ClientStatisticsService _service;
  ClientStatisticsRepository({ClientStatisticsService? service})
      : _service = service ?? ClientStatisticsService();

  Future<ClientStatisticsModel> getStatistics(String token) =>
      _service.getStatistics(token);
}
