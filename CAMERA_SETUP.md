# Configuration de la Caméra pour la Reconnaissance Faciale

## Changements effectués

### 1. Ajout du package camera
Le package `camera: ^0.11.0+2` a été ajouté au fichier `pubspec.yaml`.

### 2. Modification de face_verification_screen.dart
- Intégration du flux de la caméra frontale dans le cadre de reconnaissance faciale
- Remplacement du fond blanc par le flux vidéo en temps réel
- Initialisation automatique de la caméra au démarrage de l'écran

### 3. Permissions configurées

#### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA"/>
```
✅ Déjà présent dans le fichier

#### iOS (Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Cette application a besoin d'accéder à la caméra pour la vérification faciale</string>
```
✅ Ajouté

## Installation

1. Installez les dépendances :
```bash
flutter pub get
```

2. Pour Android, assurez-vous que minSdkVersion est au moins 21 dans `android/app/build.gradle`

3. Lancez l'application :
```bash
flutter run
```

## Fonctionnement

1. L'utilisateur upload un document dans Step2DocumentsScreen
2. Si le document nécessite une vérification faciale, FaceVerificationScreen s'ouvre
3. La caméra frontale s'initialise automatiquement
4. Le flux vidéo s'affiche dans le cadre de reconnaissance
5. Le scan démarre automatiquement après l'initialisation de la caméra
6. Après 3 secondes (simulation), la vérification est complétée

## Notes techniques

- La caméra frontale est sélectionnée par défaut
- Résolution : ResolutionPreset.medium (optimisé pour la performance)
- Audio désactivé (enableAudio: false)
- Fallback : Si la caméra n'est pas disponible, l'icône de personne s'affiche
- La caméra est automatiquement libérée lors de la fermeture de l'écran
