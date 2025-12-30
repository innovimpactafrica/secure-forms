<<<<<<< HEAD
# Secure Link

Une application mobile Flutter pour la gestion sécurisée de connexions et de liens.

## Description

Secure Link est une application mobile qui permet aux utilisateurs de créer, gérer et partager des liens de connexion sécurisés. L'application met l'accent sur la sécurité et la confidentialité des données.

## Fonctionnalités

- 🔐 **Authentification sécurisée** : Connexion et inscription avec validation
- 🔗 **Gestion de liens** : Création et gestion de liens sécurisés
- 🛡️ **Centre de sécurité** : Monitoring et alertes de sécurité
- 👤 **Profil utilisateur** : Gestion du compte et des préférences
- 📊 **Tableau de bord** : Vue d'ensemble des statistiques et actions rapides

## Architecture

Le projet utilise l'architecture **BLoC (Business Logic Component)** pour une séparation claire entre la logique métier et l'interface utilisateur.

### Structure du projet

```
lib/
├── bloc/                 # Logique métier (BLoC)
│   ├── auth_bloc.dart
│   ├── auth_event.dart
│   ├── auth_state.dart
│   └── auth_barrel.dart
├── config/              # Configuration
│   └── api_config.dart
├── models/              # Modèles de données
│   ├── auth_request.dart
│   ├── auth_response.dart
│   └── user_model.dart
├── pages/               # Écrans de l'application
│   ├── auth/           # Authentification
│   ├── home/           # Accueil
│   ├── onboarding/     # Introduction
│   └── splash/         # Écran de démarrage
├── services/           # Services
│   ├── auth_service.dart
│   └── storage_service.dart
├── utils/              # Utilitaires
│   ├── app_colors.dart
│   └── constants.dart
└── main.dart           # Point d'entrée
```

## Technologies utilisées

- **Flutter** : Framework de développement mobile
- **flutter_bloc** : Gestion d'état avec le pattern BLoC
- **dio** : Client HTTP pour les appels API
- **shared_preferences** : Stockage local des données
- **equatable** : Comparaison d'objets
- **flutter_svg** : Support des images SVG

## Installation

1. Clonez le repository :
```bash
git clone <repository-url>
cd secure_link
```

2. Installez les dépendances :
```bash
flutter pub get
```

3. Lancez l'application :
```bash
flutter run
```

## Configuration

### API Configuration

Modifiez le fichier `lib/config/api_config.dart` pour configurer l'URL de votre API :

```dart
class ApiConfig {
  static const String baseUrl = 'https://votre-api.com';
  // ...
}
```

## Développement

### Ajout de nouvelles fonctionnalités

1. **Créer un nouveau BLoC** :
   - Ajoutez les événements dans `lib/bloc/`
   - Définissez les états correspondants
   - Implémentez la logique dans le BLoC

2. **Ajouter un nouvel écran** :
   - Créez le fichier dans `lib/pages/`
   - Intégrez-le avec le BLoC approprié
   - Ajoutez la navigation

3. **Ajouter un service** :
   - Créez le service dans `lib/services/`
   - Injectez-le dans le BLoC correspondant

### Tests

```bash
flutter test
```

## Contribution

1. Fork le projet
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Committez vos changements (`git commit -am 'Ajout d'une nouvelle fonctionnalité'`)
4. Poussez vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Créez une Pull Request

## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## Support

Pour toute question ou problème, veuillez ouvrir une issue sur GitHub.
=======
# secure-link-mobile
Application mobile Flutter pour la gestion sécurisée de connexions et liens
>>>>>>> ab7394afd4035afeb12d51f52f969ffb147a5a0f
