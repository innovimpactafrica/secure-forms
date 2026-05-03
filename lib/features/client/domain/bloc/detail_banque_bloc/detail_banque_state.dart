import 'package:quick_forms/features/client/data/models/compte_model.dart';

abstract class DetailBanqueState {
  const DetailBanqueState();
}

class DetailBanqueInitial extends DetailBanqueState {
  const DetailBanqueInitial();
}

class DetailBanqueLoading extends DetailBanqueState {
  const DetailBanqueLoading();
}

class DetailBanqueLoaded extends DetailBanqueState {
  final List<CompteModel> comptes;
  const DetailBanqueLoaded(this.comptes);
}

class DetailBanqueError extends DetailBanqueState {
  final String message;
  const DetailBanqueError(this.message);
}

class CompteAjouteState extends DetailBanqueState {
  const CompteAjouteState();
}

class CompteAjoutEnCoursState extends DetailBanqueState {
  const CompteAjoutEnCoursState();
}

class CompteAjoutErreurState extends DetailBanqueState {
  final String message;
  const CompteAjoutErreurState(this.message);
}
