import 'blacklist_service.dart';

class FeatureFlags {
  /// Abonnement caché si la version actuelle est dans la blacklist de l'API.
  /// Retourne true = visible, false = caché.
  static bool get isSubscriptionVisible =>
      !BlacklistService.instance.isSubscriptionHidden;
}

