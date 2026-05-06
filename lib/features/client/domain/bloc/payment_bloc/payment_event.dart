abstract class PaymentEvent {
  const PaymentEvent();
}

class InitPaymentEvent extends PaymentEvent {
  final String planId;
  final String billingPeriod;
  final String paymentMethod;

  const InitPaymentEvent({
    required this.planId,
    required this.billingPeriod,
    required this.paymentMethod,
  });
}
