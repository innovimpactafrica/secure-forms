class TouchpayInitResponse {
  final String paymentId;
  final String reference;
  final String billingPeriod;
  final double amount;
  final TouchpayWidgetParams widgetParams;

  const TouchpayInitResponse({
    required this.paymentId,
    required this.reference,
    required this.billingPeriod,
    required this.amount,
    required this.widgetParams,
  });

  factory TouchpayInitResponse.fromJson(Map<String, dynamic> json) {
    return TouchpayInitResponse(
      paymentId: json['paymentId'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      billingPeriod: json['billingPeriod'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      widgetParams: TouchpayWidgetParams.fromJson(
          json['widgetParams'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class TouchpayWidgetParams {
  final int timestamp;
  final String agencyCode;
  final String token;
  final String serviceId;
  final String callbackUrl;
  final double amount;
  final String city;
  final String reference;

  const TouchpayWidgetParams({
    required this.timestamp,
    required this.agencyCode,
    required this.token,
    required this.serviceId,
    required this.callbackUrl,
    required this.amount,
    required this.city,
    required this.reference,
  });

  factory TouchpayWidgetParams.fromJson(Map<String, dynamic> json) {
    return TouchpayWidgetParams(
      timestamp: json['timestamp'] as int? ?? 0,
      agencyCode: json['agencyCode'] as String? ?? '',
      token: json['token'] as String? ?? '',
      serviceId: json['serviceId'] as String? ?? '',
      callbackUrl: json['callbackUrl'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      city: json['city'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
    );
  }
}

class TouchpayMobileResponse {
  final String paymentId;
  final String reference;
  final String billingPeriod;
  final double amount;
  final String checkoutUrl;

  const TouchpayMobileResponse({
    required this.paymentId,
    required this.reference,
    required this.billingPeriod,
    required this.amount,
    required this.checkoutUrl,
  });

  factory TouchpayMobileResponse.fromJson(Map<String, dynamic> json) {
    return TouchpayMobileResponse(
      paymentId: json['paymentId'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      billingPeriod: json['billingPeriod'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      checkoutUrl: json['checkoutUrl'] as String? ?? '',
    );
  }
}
