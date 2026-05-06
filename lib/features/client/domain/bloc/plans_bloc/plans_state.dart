import 'package:quick_forms/features/client/data/models/plan_model.dart';

abstract class PlansState {
  const PlansState();
}

class PlansInitial extends PlansState {
  const PlansInitial();
}

class PlansLoading extends PlansState {
  const PlansLoading();
}

class PlansLoaded extends PlansState {
  final List<PlanModel> plans;
  final String? selectedPlanId;
  const PlansLoaded(this.plans, {this.selectedPlanId});
}

class PlansError extends PlansState {
  final String message;
  const PlansError(this.message);
}
