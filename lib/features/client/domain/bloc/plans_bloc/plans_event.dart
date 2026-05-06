abstract class PlansEvent {
  const PlansEvent();
}

class LoadPlansEvent extends PlansEvent {
  const LoadPlansEvent();
}

class SelectPlanEvent extends PlansEvent {
  final String planId;
  const SelectPlanEvent(this.planId);
}
