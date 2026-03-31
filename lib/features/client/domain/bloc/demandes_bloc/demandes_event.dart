abstract class DemandesEvent {
  const DemandesEvent();
}

/// Charger les demandes récentes (home)
class LoadRecentDemandesEvent extends DemandesEvent {
  final int limit;
  final String? status;
  final String? category;
  final String? search;
  final bool forceRefresh;
  const LoadRecentDemandesEvent({
    this.limit = 5,
    this.status,
    this.category,
    this.search,
    this.forceRefresh = false,
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

/// Réinitialiser le BLoC (changement d'utilisateur)
class ResetDemandesEvent extends DemandesEvent {
  const ResetDemandesEvent();
}

/// Aller à une page spécifique
class GoToDemandesPageEvent extends DemandesEvent {
  final int page;
  const GoToDemandesPageEvent(this.page);
}
