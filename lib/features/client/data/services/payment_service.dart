import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:quick_forms/core/utils/base_url.dart';
import 'package:quick_forms/core/utils/http_client.dart';
import '../models/payment_model.dart';

class PaymentService {
  final http.Client _client;
  PaymentService({http.Client? client})
      : _client = client ?? HttpClientSingleton.instance;

  Future<TouchpayMobileResponse> initTouchpayMobilePayment({
    required String accessToken,
    required String planId,
    required String billingPeriod,
    required String paymentMethod,
    String city = 'Dakar',
  }) async {
    final body = jsonEncode({
      'planId': planId,
      'billingPeriod': billingPeriod,
      'city': city,
      'paymentMethod': paymentMethod,
    });

    debugPrint('[PaymentService] POST init-mobile | planId=$planId | method=$paymentMethod | period=$billingPeriod');

    final response = await _client.post(
      Uri.parse(BaseUrl.initTouchpayMobilePayment),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );

    debugPrint('[PaymentService] Status: ${response.statusCode}');
    debugPrint('[PaymentService] Body: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return TouchpayMobileResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Erreur paiement: ${response.statusCode}');
  }
}
