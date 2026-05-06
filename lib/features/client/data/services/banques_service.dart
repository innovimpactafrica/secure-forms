import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:quick_forms/core/utils/base_url.dart';
import 'package:quick_forms/core/utils/http_client.dart';
import '../models/banque_model.dart';

class BanquesService {
  final http.Client _client;
  BanquesService({http.Client? client})
      : _client = client ?? HttpClientSingleton.instance;

  /// Banques de l'utilisateur : filtre les organisations par ses préférences
  Future<List<BanqueModel>> getBanquesUtilisateur({
    required String accessToken,
  }) async {
    // 1. Récupérer les préférences de l'utilisateur
    final prefResp = await _client.get(
      Uri.parse(BaseUrl.getOrgPreferences),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );
    debugPrint('[BanquesService] GET preferences status: ${prefResp.statusCode}');
    if (prefResp.statusCode != 200) return [];

    final decoded = jsonDecode(prefResp.body) as Map<String, dynamic>;
    final preferences = decoded['preferences'] as List? ?? [];
    if (preferences.isEmpty) return [];

    final orgIds = preferences
        .map((p) => p['organisationId'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    debugPrint('[BanquesService] orgIds depuis préférences: $orgIds');

    // 2. Récupérer toutes les organisations et filtrer
    final allOrgs = await getOrganisations(
      accessToken: accessToken,
      forSelection: true,
    );

    final result = allOrgs.where((org) => orgIds.contains(org.id)).toList();
    debugPrint('[BanquesService] banques utilisateur: ${result.map((b) => b.nom).toList()}');
    return result;
  }

  Future<List<BanqueModel>> getOrganisations({
    required String accessToken,
    String? search,
    bool forSelection = false,
  }) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (forSelection) params['forSelection'] = 'true';

    final uri = Uri.parse(BaseUrl.getOrganisations)
        .replace(queryParameters: params.isEmpty ? null : params);

    debugPrint('[BanquesService] GET $uri');
    debugPrint(
        '[BanquesService] Token: ${accessToken.substring(0, accessToken.length > 20 ? 20 : accessToken.length)}...');

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    debugPrint('[BanquesService] Status: ${response.statusCode}');
    debugPrint(
        '[BanquesService] Body: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}');

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
    // 1. Lire et nettoyer les préférences existantes dès la lecture
    final getResp = await _client.get(
      Uri.parse(BaseUrl.getOrgPreferences),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    List<Map<String, dynamic>> cleanedItems = [];
    if (getResp.statusCode == 200) {
      final decoded = jsonDecode(getResp.body) as Map<String, dynamic>;
      final preferences = decoded['preferences'] as List? ?? [];
      cleanedItems = preferences.map((p) {
        final accounts = (p['bankAccounts'] as List? ?? []).map((a) {
          final num = a['accountNumber'] as String? ?? a['number'] as String? ?? '';
          final holder = a['accountHolder'] as String? ?? a['holder'] as String? ?? '';
          return {'accountNumber': num, 'accountHolder': holder};
        }).toList();
        final numbers = (p['bankAccountNumbers'] as List? ?? [])
            .map((n) => n.toString())
            .toList();
        return {
          'organisationId': p['organisationId'] as String? ?? '',
          'bankAccountNumbers': numbers,
          'bankAccounts': accounts,
        };
      }).where((p) => (p['organisationId'] as String).isNotEmpty).toList();
    }

    // 2. Merger la nouvelle banque
    final existingIndex =
        cleanedItems.indexWhere((p) => p['organisationId'] == organisationId);

    if (existingIndex >= 0) {
      final existing = cleanedItems[existingIndex];
      final accounts = List<Map<String, dynamic>>.from(existing['bankAccounts'] as List);
      final numbers = List<String>.from(existing['bankAccountNumbers'] as List);
      accounts.add({'accountNumber': accountNumber, 'accountHolder': accountHolder});
      if (!numbers.contains(accountNumber)) numbers.add(accountNumber);
      cleanedItems[existingIndex] = {
        'organisationId': organisationId,
        'bankAccountNumbers': numbers,
        'bankAccounts': accounts,
      };
    } else {
      cleanedItems.add({
        'organisationId': organisationId,
        'bankAccountNumbers': [accountNumber],
        'bankAccounts': [{'accountNumber': accountNumber, 'accountHolder': accountHolder}],
      });
    }

    // 3. POST
    final body = jsonEncode({'skip': false, 'items': cleanedItems});
    debugPrint('[BanquesService] POST body: $body');
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
    debugPrint('[BanquesService] POST Response: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur ajout banque: ${response.statusCode} - ${response.body}');
    }
  }
}
