import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:secure_link/core/utils/base_url.dart';
import 'package:secure_link/core/utils/http_client.dart';
import '../models/notification_model.dart';

class NotificationsService {
  final http.Client _client;
  NotificationsService({http.Client? client})
      : _client = client ?? HttpClientSingleton.instance;

  Future<List<NotificationModel>> getNotifications({
    required String accessToken,
    bool unreadOnly = false,
  }) async {
    final params = <String, String>{};
    if (unreadOnly) params['unreadOnly'] = 'true';
    final uri = Uri.parse(BaseUrl.getNotifications).replace(queryParameters: params);

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );
    print('[NotificationsService] GET ${uri.path} → ${response.statusCode}');
    print('[NotificationsService] Body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> list = decoded is List
          ? decoded
          : (decoded['data'] ?? decoded['notifications'] ?? []);
      return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Erreur chargement notifications: ${response.statusCode}');
  }
}
