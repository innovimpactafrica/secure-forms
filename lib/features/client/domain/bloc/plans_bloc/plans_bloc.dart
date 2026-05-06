import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_forms/features/client/data/services/plans_service.dart';
import 'plans_event.dart';
import 'plans_state.dart';

class PlansBloc extends Bloc<PlansEvent, PlansState> {
  final PlansService _service;

  PlansBloc({PlansService? service})
      : _service = service ?? PlansService(),
        super(const PlansInitial()) {
    on<LoadPlansEvent>(_onLoad);
    on<SelectPlanEvent>(_onSelect);
  }

  Future<void> _onLoad(LoadPlansEvent event, Emitter<PlansState> emit) async {
    emit(const PlansLoading());
    try {
      final plans = await _service.getPlans();
      emit(PlansLoaded(plans));
    } catch (e) {
      emit(PlansError(e.toString()));
    }
  }

  void _onSelect(SelectPlanEvent event, Emitter<PlansState> emit) {
    final current = state;
    if (current is PlansLoaded) {
      emit(PlansLoaded(current.plans, selectedPlanId: event.planId));
    }
  }
}
