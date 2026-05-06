class PlanServiceModel {
  final String id;
  final String planId;
  final int maxRequests;
  final String serviceName;
  final String serviceCode;
  final String serviceDescription;
  final bool isActive;

  const PlanServiceModel({
    required this.id,
    required this.planId,
    required this.maxRequests,
    required this.serviceName,
    required this.serviceCode,
    required this.serviceDescription,
    required this.isActive,
  });

  factory PlanServiceModel.fromJson(Map<String, dynamic> json) {
    final service = json['service'] as Map<String, dynamic>? ?? {};
    return PlanServiceModel(
      id: json['id'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      maxRequests: json['maxRequests'] as int? ?? 0,
      serviceName: service['name'] as String? ?? '',
      serviceCode: service['code'] as String? ?? '',
      serviceDescription: service['description'] as String? ?? '',
      isActive: service['isActive'] as bool? ?? false,
    );
  }
}
