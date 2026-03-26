import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:secure_link/core/utils/base_url.dart';
import 'package:secure_link/core/utils/http_client.dart';
import '../models/client_statistics_model.dart';

class ClientStatisticsService {
  final http.Client _client;
  ClientStatisticsService({http.Client? client})
      : _client = client ?? HttpClientSingleton.instance;

  Future<ClientStatisticsModel> getStatistics(String token) async {
    final response = await _client.get(
      Uri.parse(BaseUrl.clientStatistics),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    // ignore: avoid_print
    print('[ClientStatisticsService] GET ${BaseUrl.clientStatistics} → ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ClientStatisticsModel.fromJson(data);
    }
    throw Exception('Erreur récupération statistiques');
  }
}
