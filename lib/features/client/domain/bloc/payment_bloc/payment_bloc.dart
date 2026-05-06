import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:quick_forms/core/utils/user_session.dart';
import 'package:quick_forms/features/client/data/services/payment_service.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentService _service;

  PaymentBloc({PaymentService? service})
      : _service = service ?? PaymentService(),
        super(const PaymentInitial()) {
    on<InitPaymentEvent>(_onInit);
  }

  Future<void> _onInit(
      InitPaymentEvent event, Emitter<PaymentState> emit) async {
    debugPrint('[PaymentBloc] _onInit START | planId=${event.planId} | billingPeriod=${event.billingPeriod} | paymentMethod=${event.paymentMethod}');
    debugPrint('[PaymentBloc] accessToken vide: ${UserSession.instance.accessToken.isEmpty}');
    emit(const PaymentLoading());
    debugPrint('[PaymentBloc] PaymentLoading emis');
    try {
      final response = await _service.initTouchpayMobilePayment(
        accessToken: UserSession.instance.accessToken,
        planId: event.planId,
        billingPeriod: event.billingPeriod,
        paymentMethod: event.paymentMethod,
      );
      debugPrint('[PaymentBloc] SUCCESS | paymentId=${response.paymentId} | checkoutUrl=${response.checkoutUrl}');
      emit(PaymentSuccess(response));
    } catch (e) {
      debugPrint('[PaymentBloc] ERROR: $e');
      emit(PaymentError(e.toString()));
    }
  }
}
