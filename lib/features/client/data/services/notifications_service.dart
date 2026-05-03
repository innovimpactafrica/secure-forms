import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quick_forms/core/utils/base_url.dart';
import 'package:quick_forms/core/utils/http_client.dart';
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
    final uri =
        Uri.parse(BaseUrl.getNotifications).replace(queryParameters: params);

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );
    print('[NotificationsService] GET ${uri.path} → ${response.statusCode}');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> list = decoded is List
          ? decoded
          : (decoded['data'] ?? decoded['notifications'] ?? []);
      return list
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Erreur chargement notifications: ${response.statusCode}');
  }

  Future<void> markRead(String accessToken, List<String> ids) async {
    await _client.post(
      Uri.parse(BaseUrl.markNotificationsRead),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'ids': ids}),
    );
  }

  Future<void> markAllRead(String accessToken) async {
    await _client.post(
      Uri.parse(BaseUrl.markAllNotificationsRead),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }
}
