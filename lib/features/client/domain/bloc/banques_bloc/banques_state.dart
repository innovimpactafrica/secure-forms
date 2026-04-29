import 'package:secure_link/features/client/data/models/banque_model.dart';

abstract class BanquesState {
  const BanquesState();
}

class BanquesInitial extends BanquesState {
  const BanquesInitial();
}

class BanquesLoading extends BanquesState {
  const BanquesLoading();
}

class BanquesLoaded extends BanquesState {
  final List<BanqueModel> banques;
  const BanquesLoaded(this.banques);
}

class BanquesError extends BanquesState {
  final String message;
  const BanquesError(this.message);
}

class BanqueAjouteeState extends BanquesState {
  const BanqueAjouteeState();
}

class BanqueAjoutEnCoursState extends BanquesState {
  const BanqueAjoutEnCoursState();
}

class BanqueAjoutErreurState extends BanquesState {
  final String message;
  const BanqueAjoutErreurState(this.message);
}
