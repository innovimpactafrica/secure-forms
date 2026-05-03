import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:quick_forms/core/utils/base_url.dart';
import 'package:quick_forms/core/utils/http_client.dart';
import '../models/compte_model.dart';

class DetailBanqueService {
  final http.Client _client;
  DetailBanqueService({http.Client? client})
      : _client = client ?? HttpClientSingleton.instance;

  /// Retourne les comptes bancaires d'une organisation spécifique
  Future<List<CompteModel>> getComptes({
    required String accessToken,
    required String organisationId,
  }) async {
    final response = await _client.get(
      Uri.parse(BaseUrl.getOrgPreferences),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    debugPrint('[DetailBanqueService] GET Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final preferences = decoded['preferences'] as List? ?? [];
      final pref = preferences.firstWhere(
        (p) => p['organisationId'] == organisationId,
        orElse: () => null,
      );
      if (pref == null) return [];
      final bankAccounts = pref['bankAccounts'] as List? ?? [];
      return bankAccounts
          .map((e) => CompteModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Erreur chargement comptes: ${response.statusCode}');
  }

  /// Ajoute un compte bancaire via POST /api/clients/me/organization-preferences
  Future<void> ajouterCompte({
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

    debugPrint('[DetailBanqueService] POST Status: ${response.statusCode}');
    debugPrint('[DetailBanqueService] POST Body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur ajout compte: ${response.statusCode}');
    }
  }
}
