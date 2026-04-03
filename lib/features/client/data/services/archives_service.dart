import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:secure_link/core/utils/base_url.dart';
import 'package:secure_link/core/utils/http_client.dart';
import '../models/archive_model.dart';

class ArchivesService {
  final http.Client _client;
  ArchivesService({http.Client? client}) : _client = client ?? HttpClientSingleton.instance;

  Future<ArchivesPage> getArchives({
    required String accessToken,
    String type = 'all',
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final params = <String, String>{
      'type': type,
      'page': '$page',
      'limit': '$limit',
    };
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
      if (decoded is List) {
        final items = decoded.map((e) => ArchiveModel.fromJson(e as Map<String, dynamic>)).toList();
        return ArchivesPage(items: items, total: items.length, page: page, limit: limit);
      }
      final items = ((decoded['items'] ?? decoded['data'] ?? decoded['archives'] ?? []) as List)
          .map((e) => ArchiveModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ArchivesPage(
        items: items,
        total: decoded['total'] as int? ?? items.length,
        page: decoded['page'] as int? ?? page,
        limit: decoded['limit'] as int? ?? limit,
      );
    }
    throw Exception('Erreur chargement archives: ${response.statusCode}');
  }
}

class ArchivesPage {
  final List<ArchiveModel> items;
  final int total;
  final int page;
  final int limit;
  const ArchivesPage({required this.items, required this.total, required this.page, required this.limit});
  bool get hasMore => (page * limit) < total;
}
