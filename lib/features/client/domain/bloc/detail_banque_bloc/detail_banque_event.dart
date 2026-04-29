abstract class DetailBanqueEvent {
  const DetailBanqueEvent();
}

class LoadComptesEvent extends DetailBanqueEvent {
  final String banqueId;
  const LoadComptesEvent(this.banqueId);
}

class SearchComptesEvent extends DetailBanqueEvent {
  final String query;
  const SearchComptesEvent(this.query);
}

class AjouterCompteEvent extends DetailBanqueEvent {
  final String organisationId;
  final String accountNumber;
  final String accountHolder;
  const AjouterCompteEvent({
    required this.organisationId,
    required this.accountNumber,
    required this.accountHolder,
  });
}
