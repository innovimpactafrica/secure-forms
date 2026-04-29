abstract class BanquesEvent {
  const BanquesEvent();
}

class LoadBanquesEvent extends BanquesEvent {
  const LoadBanquesEvent();
}

class SearchBanquesEvent extends BanquesEvent {
  final String query;
  const SearchBanquesEvent(this.query);
}

class AjouterBanqueEvent extends BanquesEvent {
  final String organisationId;
  final String accountNumber;
  final String accountHolder;
  const AjouterBanqueEvent({
    required this.organisationId,
    required this.accountNumber,
    required this.accountHolder,
  });
}
