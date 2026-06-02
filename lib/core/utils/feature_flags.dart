class FeatureFlags {
  /// Abonnement visible seulement :
  /// - Après le 5 juin 2026
  /// - OU si la locale de l'appareil est Sénégal (fr_SN)
  static bool isSubscriptionVisible(String? countryCode) {
    final now = DateTime.now();
    final releaseDate = DateTime(2026, 6, 7);
    final afterReleaseDate = now.isAfter(releaseDate);
    return afterReleaseDate ;
  }
}