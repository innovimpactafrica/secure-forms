import 'plan_service_model.dart';

class PlanModel {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String clientTypes;
  final double monthlyPrice;
  final double annualPrice;
  final bool annualTwoMonthsOff;
  final String billingPeriod;
  final double priceAmount;
  final String currency;
  final bool isActive;
  final List<PlanServiceModel> services;

  const PlanModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.clientTypes,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.annualTwoMonthsOff,
    required this.billingPeriod,
    required this.priceAmount,
    required this.currency,
    required this.isActive,
    this.services = const [],
  });

  PlanModel copyWithServices(List<PlanServiceModel> services) {
    return PlanModel(
      id: id, code: code, name: name, description: description,
      clientTypes: clientTypes, monthlyPrice: monthlyPrice,
      annualPrice: annualPrice, annualTwoMonthsOff: annualTwoMonthsOff,
      billingPeriod: billingPeriod, priceAmount: priceAmount,
      currency: currency, isActive: isActive, services: services,
    );
  }

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      clientTypes: json['clientTypes'] as String? ?? '',
      monthlyPrice: (json['monthlyPrice'] as num?)?.toDouble() ?? 0,
      annualPrice: (json['annualPrice'] as num?)?.toDouble() ?? 0,
      annualTwoMonthsOff: json['annualTwoMonthsOff'] as bool? ?? false,
      billingPeriod: json['billingPeriod'] as String? ?? '',
      priceAmount: (json['priceAmount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'XOF',
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  String get formattedPrice {
    final amount = monthlyPrice;
    final formatted = amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
    return '$formatted $currency';
  }
}
