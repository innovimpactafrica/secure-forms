abstract class KycState {
  const KycState();
}

class KycInitial extends KycState {
  const KycInitial();
}

class KycRequired extends KycState {
  const KycRequired();
}

class KycCompleted extends KycState {
  const KycCompleted();
}
