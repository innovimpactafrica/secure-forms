import 'dart:io';

abstract class KycEvent {
  const KycEvent();
}

class KycCheckStatus extends KycEvent {
  const KycCheckStatus();
}

class KycMarkCompleted extends KycEvent {
  const KycMarkCompleted();
}

/// Upload recto + verso de la CNI
class KycUploadIdDocuments extends KycEvent {
  final File recto;
  final File verso;
  final String token;

  const KycUploadIdDocuments({
    required this.recto,
    required this.verso,
    required this.token,
  });
}

/// Upload selfie
class KycUploadSelfie extends KycEvent {
  final File selfie;
  final String token;

  const KycUploadSelfie({required this.selfie, required this.token});
}

/// Charger la liste des documents déjà uploadés
class KycLoadDocuments extends KycEvent {
  final String token;
  const KycLoadDocuments({required this.token});
}
