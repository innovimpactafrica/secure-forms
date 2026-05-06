import 'package:quick_forms/features/client/data/models/payment_model.dart';

abstract class PaymentState {
  const PaymentState();
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentSuccess extends PaymentState {
  final TouchpayMobileResponse response;
  const PaymentSuccess(this.response);
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError(this.message);
}
