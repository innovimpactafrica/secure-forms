import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:secure_link/core/utils/base_url.dart';
import 'package:secure_link/core/utils/http_client.dart';
import '../models/archive_model.dart';

class ArchivesService {
  final http.Client _client;
  ArchivesService({http.Client? client}) : _client = client ?? HttpClientSingleton.instance;

  Future<List<ArchiveModel>> getArchives({
    required String accessToken,
    String type = 'all',
    String? status,
  }) async {
    final params = <String, String>{'type': type};
    if (status != null && status.isNotEmpty) params['status'] = status;
    final uri = Uri.parse(BaseUrl.getArchives).replace(queryParameters: params);

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      // ignore: avoid_print
      print('[ArchivesService] items: ${response.body}');
      final List<dynamic> list = decoded is List
          ? decoded
          : (decoded['items'] ?? decoded['data'] ?? decoded['archives'] ?? []);
      return list.map((e) => ArchiveModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Erreur chargement archives: ${response.statusCode}');
  }
}
