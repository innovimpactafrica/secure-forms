class SubscriptionModel {
  final bool isActive;
  final String? planId;
  final String? planName;
  final String? planCode;

  const SubscriptionModel({
    required this.isActive,
    this.planId,
    this.planName,
    this.planCode,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final planId = json['planId'] as String?;
    return SubscriptionModel(
      isActive: planId != null && planId.isNotEmpty,
      planId: planId,
      planName: json['planName'] as String?,
      planCode: json['planCode'] as String?,
    );
  }
}
