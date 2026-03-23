abstract class DemandesEvent {
  const DemandesEvent();
}

/// Charger les demandes récentes (home)
class LoadRecentDemandesEvent extends DemandesEvent {
  final int limit;
  final String? status;
  final String? category;
  final String? search;
  const LoadRecentDemandesEvent({
    this.limit = 5,
    this.status,
    this.category,
    this.search,
  });
}

/// Charger la liste complète avec filtres et pagination
class LoadDemandesEvent extends DemandesEvent {
  final String? status;
  final String? sector;
  final String? search;
  final int page;
  final int limit;
  const LoadDemandesEvent({
    this.status,
    this.sector,
    this.search,
    this.page = 1,
    this.limit = 10,
  });
}

/// Charger la page suivante (pagination)
class LoadMoreDemandesEvent extends DemandesEvent {
  const LoadMoreDemandesEvent();
}

/// Supprimer un brouillon
class DeleteDraftEvent extends DemandesEvent {
  final String id;
  const DeleteDraftEvent(this.id);
}
