import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:quick_forms/core/utils/base_url.dart';
import 'package:quick_forms/core/utils/http_client.dart';
import '../models/subscription_model.dart';

class SubscriptionService {
  final http.Client _client;
  SubscriptionService({http.Client? client})
      : _client = client ?? HttpClientSingleton.instance;

  Future<SubscriptionModel?> getEffectiveSubscription({
    required String accessToken,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse(BaseUrl.getSubscriptionEffective),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );
      debugPrint('[SubscriptionService] Status: ${response.statusCode}');
      debugPrint('[SubscriptionService] Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded == null) return null;
        final sub = SubscriptionModel.fromJson(decoded as Map<String, dynamic>);
        debugPrint('[SubscriptionService] planCode=${sub.planCode} isActive=${sub.isActive}');
        return sub;
      }
      // 404 ou autre = pas d'abonnement actif
      debugPrint('[SubscriptionService] Pas d\'abonnement actif (${response.statusCode})');
      return null;
    } catch (e) {
      debugPrint('[SubscriptionService] Erreur: $e');
      return null;
    }
  }
}
