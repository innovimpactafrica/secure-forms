import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:secure_link/core/utils/base_url.dart';
import 'package:secure_link/core/utils/http_client.dart';
import '../models/demande_model.dart';

class DemandesService {
  final http.Client _client;
  DemandesService({http.Client? client}) : _client = client ?? HttpClientSingleton.instance;

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

  Future<List<DemandeModel>> getRecentRequests({
    required String accessToken,
    int limit = 5,
    String? status,
    String? category,
    String? institution,
    String? type,
    String? search,
  }) async {
    final params = <String, String>{'limit': '$limit'};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (institution != null && institution.isNotEmpty) params['institution'] = institution;
    if (type != null && type.isNotEmpty) params['type'] = type;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse(BaseUrl.recentRequests).replace(queryParameters: params);
    final response = await _client.get(uri, headers: _headers(accessToken));
    // ignore: avoid_print
    print('[RecentRequests] status=${response.statusCode}');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      // ignore: avoid_print
      print('[RecentRequests] decoded type=${decoded.runtimeType}');
      // ignore: avoid_print
      print('[RecentRequests] raw body=${response.body.substring(0, response.body.length.clamp(0, 800))}');
      final List<dynamic> list = decoded is List
          ? decoded
          : (decoded['items'] ?? decoded['data'] ?? decoded['requests'] ?? []);
      // ignore: avoid_print
      print('[RecentRequests] count=${list.length}');
      if (list.isNotEmpty) {
        final first = list.first as Map<String, dynamic>;
        // ignore: avoid_print
        print('[RecentRequests] first keys=${first.keys.toList()}');
        // ignore: avoid_print
        print('[RecentRequests] first full=$first');
      }
      return list.map((e) => DemandeModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Erreur demandes récentes: ${response.statusCode}');
  }

  Future<DemandesPage> getRequests({
    required String accessToken,
    String? status,
    String? formType,
    String? sector,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final params = <String, String>{'page': '$page', 'limit': '$limit'};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (formType != null && formType.isNotEmpty) params['formType'] = formType;
    if (sector != null && sector.isNotEmpty) params['sector'] = sector;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse(BaseUrl.requests).replace(queryParameters: params);
    final response = await _client.get(uri, headers: _headers(accessToken));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        final items = decoded.map((e) => DemandeModel.fromJson(e as Map<String, dynamic>)).toList();
        return DemandesPage(items: items, total: items.length, page: page, limit: limit);
      }
      final items = (decoded['items'] as List? ?? [])
          .map((e) => DemandeModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return DemandesPage(
        items: items,
        total: decoded['total'] as int? ?? items.length,
        page: decoded['page'] as int? ?? page,
        limit: decoded['limit'] as int? ?? limit,
      );
    }
    throw Exception('Erreur liste demandes: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getRequestByIdRaw({
    required String accessToken,
    required String id,
  }) async {
    final uri = Uri.parse(BaseUrl.requestById(id));
    final response = await _client.get(uri, headers: _headers(accessToken));
    debugPrint('[DemandesService] GET $uri → ${response.statusCode}');
    if (response.statusCode == 200) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
debugPrint('[DemandesService] submittedForms raw=${json['submittedForms']}');
debugPrint('[DemandesService] requiredDocuments raw=${json['requiredDocuments']}');

// 👇 LOGS DATES — à supprimer après
debugPrint('[DemandesService] ===== TOUS LES CHAMPS DE DATES =====');
debugPrint('[DemandesService] createdAt=${json['createdAt']}');
debugPrint('[DemandesService] updatedAt=${json['updatedAt']}');
debugPrint('[DemandesService] submittedAt=${json['submittedAt']}');
debugPrint('[DemandesService] inProgressAt=${json['inProgressAt']}');
debugPrint('[DemandesService] processedAt=${json['processedAt']}');
debugPrint('[DemandesService] completedAt=${json['completedAt']}');
debugPrint('[DemandesService] finalizedAt=${json['finalizedAt']}');
debugPrint('[DemandesService] validatedAt=${json['validatedAt']}');
debugPrint('[DemandesService] rejectedAt=${json['rejectedAt']}');
debugPrint('[DemandesService] ALL KEYS=${json.keys.toList()}');
debugPrint('[DemandesService] =====================================');

return json;
    }
    throw Exception('Erreur détail demande: ${response.statusCode}');
  }

  Future<DemandeModel> getRequestById({
    required String accessToken,
    required String id,
  }) async {
    final raw = await getRequestByIdRaw(accessToken: accessToken, id: id);
    return DemandeModel.fromJson(raw);
  }

  Future<void> deleteDraft({
    required String accessToken,
    required String id,
  }) async {
    final uri = Uri.parse(BaseUrl.draftById(id));
    final response = await _client.delete(uri, headers: _headers(accessToken));

    if (response.statusCode != 204) {
      throw Exception('Erreur suppression brouillon: ${response.statusCode}');
    }
  }
}
