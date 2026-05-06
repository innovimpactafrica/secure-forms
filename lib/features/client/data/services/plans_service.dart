import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:quick_forms/core/utils/base_url.dart';
import 'package:quick_forms/core/utils/http_client.dart';
import '../models/plan_model.dart';
import '../models/plan_service_model.dart';

class PlansService {
  final http.Client _client;
  PlansService({http.Client? client})
      : _client = client ?? HttpClientSingleton.instance;

  Future<List<PlanModel>> getPlans() async {
    final response = await _client.get(
      Uri.parse(BaseUrl.getPlans),
      headers: {'Accept': 'application/json'},
    );
    debugPrint('[PlansService] GET plans status: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw Exception('Erreur chargement plans: ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List;
    final plans = list
        .map((e) => PlanModel.fromJson(e as Map<String, dynamic>))
        .where((p) => p.isActive)
        .toList();

    // Charger les services de chaque plan en parallèle
    final plansWithServices = await Future.wait(
      plans.map((plan) => _loadPlanWithServices(plan)),
    );
    return plansWithServices;
  }

  Future<PlanModel> _loadPlanWithServices(PlanModel plan) async {
    try {
      final services = await getPlanServices(planId: plan.id);
      return plan.copyWithServices(services);
    } catch (e) {
      debugPrint('[PlansService] Erreur services plan ${plan.id}: $e');
      return plan;
    }
  }

  Future<List<PlanServiceModel>> getPlanServices({
    required String planId,
  }) async {
    final response = await _client.get(
      Uri.parse(BaseUrl.getPlanServices(planId)),
      headers: {'Accept': 'application/json'},
    );
    debugPrint('[PlansService] GET services plan $planId: ${response.statusCode}');
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list
          .map((e) => PlanServiceModel.fromJson(e as Map<String, dynamic>))
          .where((s) => s.isActive)
          .toList();
    }
    return [];
  }
}
