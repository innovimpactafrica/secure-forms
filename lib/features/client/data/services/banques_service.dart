import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:secure_link/core/utils/base_url.dart';
import 'package:secure_link/core/utils/http_client.dart';
import '../models/banque_model.dart';

class BanquesService {
  final http.Client _client;
  BanquesService({http.Client? client})
      : _client = client ?? HttpClientSingleton.instance;

  Future<List<BanqueModel>> getOrganisations({
    required String accessToken,
    String? search,
  }) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse(BaseUrl.getOrganisations)
        .replace(queryParameters: params.isEmpty ? null : params);

    debugPrint('[BanquesService] GET $uri');
    debugPrint('[BanquesService] Token: ${accessToken.substring(0, accessToken.length > 20 ? 20 : accessToken.length)}...');

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    debugPrint('[BanquesService] Status: ${response.statusCode}');
    debugPrint('[BanquesService] Body: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final list = decoded is List ? decoded : (decoded['data'] ?? []) as List;
      final banques = list
          .map((e) => BanqueModel.fromJson(e as Map<String, dynamic>))
          .toList();
      for (final b in banques) {
        debugPrint('[BanquesService] Banque: ${b.nom} | logoUrl: ${b.logoUrl}');
      }
      return banques;
    }
    throw Exception('Erreur chargement banques: ${response.statusCode}');
  }

  Future<void> ajouterBanque({
    required String accessToken,
    required String organisationId,
    required String accountNumber,
    required String accountHolder,
  }) async {
    final body = jsonEncode({
      'skip': false,
      'items': [
        {
          'organisationId': organisationId,
          'bankAccountNumbers': [accountNumber],
          'bankAccounts': [
            {
              'accountNumber': accountNumber,
              'accountHolder': accountHolder,
            }
          ],
        }
      ],
    });
    final response = await _client.post(
      Uri.parse(BaseUrl.getOrgPreferences),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );
    debugPrint('[BanquesService] POST Status: ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur ajout banque: ${response.statusCode}');
    }
  }
}
