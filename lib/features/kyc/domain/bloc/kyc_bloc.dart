import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'kyc_event.dart';
import 'kyc_state.dart';

class KycBloc extends Bloc<KycEvent, KycState> {
  final String userId;

  KycBloc({required this.userId}) : super(const KycInitial()) {
    on<KycCheckStatus>(_onCheckStatus);
    on<KycMarkCompleted>(_onMarkCompleted);
  }

  String get _kycKey => 'kyc_completed_$userId';

  Future<void> _onCheckStatus(KycCheckStatus event, Emitter<KycState> emit) async {
    // Sans userId valide → toujours requis
    if (userId.isEmpty) {
      emit(const KycRequired());
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_kycKey) ?? false;
    emit(completed ? const KycCompleted() : const KycRequired());
  }

  Future<void> _onMarkCompleted(KycMarkCompleted event, Emitter<KycState> emit) async {
    if (userId.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kycKey, true);
    }
    emit(const KycCompleted());
  }
}
