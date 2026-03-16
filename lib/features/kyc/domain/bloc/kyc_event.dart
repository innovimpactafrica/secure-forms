abstract class KycEvent {
  const KycEvent();
}

class KycCheckStatus extends KycEvent {
  const KycCheckStatus();
}

class KycMarkCompleted extends KycEvent {
  const KycMarkCompleted();
}
