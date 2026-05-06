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

  Future<void> ajouterCompte({
    required String accessToken,
    required String organisationId,
    required String accountNumber,
    required String accountHolder,
  }) async {
    // 1. Lire les préférences existantes
    final getResp = await _client.get(
      Uri.parse(BaseUrl.getOrgPreferences),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    // 2. Nettoyer et normaliser les items existants dès la lecture
    List<Map<String, dynamic>> cleanedItems = [];
    if (getResp.statusCode == 200) {
      final decoded = jsonDecode(getResp.body) as Map<String, dynamic>;
      final preferences = decoded['preferences'] as List? ?? [];
      cleanedItems = preferences.map((p) {
        final pMap = Map<String, dynamic>.from(p as Map);
        final accounts = (pMap['bankAccounts'] as List? ?? []).map((a) {
          final aMap = Map<String, dynamic>.from(a as Map);
          final num = aMap['accountNumber'] as String? ?? aMap['number'] as String? ?? '';
          final holder = aMap['accountHolder'] as String? ?? aMap['holder'] as String? ?? '';
          return <String, dynamic>{'accountNumber': num, 'accountHolder': holder};
        }).toList();
        final numbers = (pMap['bankAccountNumbers'] as List? ?? [])
            .map((n) => n.toString())
            .toList();
        return <String, dynamic>{
          'organisationId': pMap['organisationId'] as String? ?? '',
          'bankAccountNumbers': numbers,
          'bankAccounts': accounts,
        };
      }).where((p) => (p['organisationId'] as String).isNotEmpty).toList();
    }

    // 3. Merger le nouveau compte
    final existingIndex =
        cleanedItems.indexWhere((p) => p['organisationId'] == organisationId);

    if (existingIndex >= 0) {
      final existing = cleanedItems[existingIndex];
      final accounts = (existing['bankAccounts'] as List)
          .map((a) => Map<String, dynamic>.from(a as Map))
          .toList();
      final numbers = List<String>.from(existing['bankAccountNumbers'] as List);
      accounts.add(<String, dynamic>{'accountNumber': accountNumber, 'accountHolder': accountHolder});
      if (!numbers.contains(accountNumber)) numbers.add(accountNumber);
      cleanedItems[existingIndex] = <String, dynamic>{
        'organisationId': organisationId,
        'bankAccountNumbers': numbers,
        'bankAccounts': accounts,
      };
    } else {
      cleanedItems.add(<String, dynamic>{
        'organisationId': organisationId,
        'bankAccountNumbers': [accountNumber],
        'bankAccounts': [<String, dynamic>{'accountNumber': accountNumber, 'accountHolder': accountHolder}],
      });
    }

    // 4. POST
    final body = jsonEncode({'skip': false, 'items': cleanedItems});
    debugPrint('[DetailBanqueService] POST body: $body');
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
    debugPrint('[DetailBanqueService] POST Response: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur ajout compte: ${response.statusCode} - ${response.body}');
    }
  }
}
