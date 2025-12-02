# 🚀 Démarrage - DocStore EPL Mobile

## ⚡ Quick Start (5 minutes)

### 1. Installer les dépendances
```bash
cd /home/rahimdev/vscodeprojects/docstore
flutter pub get
```

### 2. Configurer Appwrite (Important!)
Voir: `APPWRITE_SETUP.md`

Essentiellement:
- [ ] Appwrite running (local ou cloud)
- [ ] Base de données créée
- [ ] Collections créées
- [ ] IDs copiés dans `lib/config/app_constants.dart`

### 3. Lancer l'app
```bash
flutter run
```

Vous verrez:
- ✅ HomePage avec 3 tabs (Écoles, Concours, Recherche)
- ✅ Écoles chargées depuis Appwrite
- ✅ Recherche multi-entités
- ✅ Navigation vers détails

## 📋 Checklist Installation

### Avant de commencer
- [ ] Flutter SDK 3.8+ installé
- [ ] Android SDK configuré (pour Android)
- [ ] Xcode configuré (pour iOS)
- [ ] Appwrite instance disponible

### Installation étape par étape
```bash
# 1. Clone du repo
git clone <url> docstore
cd docstore

# 2. Dépendances
flutter pub get
flutter pub upgrade

# 3. Vérifier la config
# Ouvrir lib/config/app_constants.dart
# Mettre à jour les valeurs YOUR_*

# 4. Lancer
flutter run

# 5. Hot reload (optionnel)
# Cmd+S (Mac) ou Ctrl+S (Windows/Linux)
```

## 🎨 Configuration Appwrite

### En Local (Docker)
```bash
docker run -d \
  -h appwrite \
  --name=appwrite \
  -p 80:80 \
  -p 443:443 \
  appwrite/appwrite:latest

# URL: http://localhost
# Admin: créer compte
```

### En Cloud
- [ ] Créer compte Appwrite Cloud
- [ ] Créer projet
- [ ] Copier endpoint

### Collections à créer
Voir la section "Create Collections" dans `APPWRITE_SETUP.md`

```
✅ Écoles
✅ Filières
✅ Parcours
✅ Années
✅ Semestres
✅ Cours
✅ Ressources
✅ Concours
```

### Mettre à jour constants
```dart
// lib/config/app_constants.dart

// À remplacer:
static const String appwriteEndpoint = 'YOUR_APPWRITE_ENDPOINT';
static const String appwriteProjectId = 'YOUR_PROJECT_ID';
static const String appwriteApiKey = 'YOUR_API_KEY';

// Par vos vraies valeurs
static const String appwriteEndpoint = 'http://localhost';
static const String appwriteProjectId = 'abc123def456';
static const String appwriteApiKey = 'sk_live_...';
static const String databaseId = 'main_db';
```

## 📱 Tester sur Device

### Android
```bash
# Device physique ou émulateur
flutter run

# Build APK release
flutter build apk --release
```

### iOS
```bash
# Device physique ou simulateur
flutter run

# Build IPA
flutter build ios --release
```

## 🐛 Dépannage Rapide

### "Target of URI doesn't exist"
```bash
flutter pub get
flutter clean
flutter pub get
```

### "No BlocProvider found"
Vérifier que les BLoCs sont enregistrés dans `lib/main.dart`

### "Appwrite connection failed"
- Vérifier Appwrite est running
- Vérifier endpoint correct
- Vérifier Project ID

### Autres erreurs
Voir: `TROUBLESHOOTING.md`

## 📚 Documentation Complète

- **README.md** - Vue d'ensemble générale
- **APPWRITE_SETUP.md** - Configuration Appwrite détaillée
- **BLOC_ARCHITECTURE.md** - Comment fonctionne le BLoC
- **DEVELOPER_GUIDE.md** - Pour les développeurs
- **FILE_INDEX.md** - Index des fichiers
- **TROUBLESHOOTING.md** - Résolution erreurs
- **PROJECT_SUMMARY.md** - Synthèse complète

## 🎯 Après Installation

### Phase 1: Vérifier que ça marche
1. [ ] App lance sans erreur
2. [ ] HomePage affiche 3 tabs
3. [ ] Tab "Écoles" montre loader (en attente données)
4. [ ] Tab "Concours" montre loader
5. [ ] Tab "Recherche" montre barre de recherche

### Phase 2: Importer données
1. [ ] Ajouter écoles dans Appwrite
2. [ ] Ajouter parcours
3. [ ] Ajouter filières
4. [ ] Ajouter années
5. [ ] Ajouter semestres
6. [ ] Ajouter cours
7. [ ] Ajouter ressources
8. [ ] Ajouter concours

Voir: `APPWRITE_SETUP.md` pour structures JSON

### Phase 3: Tester fonctionnalités
- [ ] Charger écoles
- [ ] Cliquer sur une école
- [ ] Voir détails de l'école
- [ ] Charger concours
- [ ] Rechercher une école
- [ ] Historique de recherche

### Phase 4: Développer features additionnelles
- [ ] Filière → Années → Semestres → Cours
- [ ] Télécharger ressources
- [ ] Ouvrir PDF in-app
- [ ] Favoris
- [ ] Mode offline
- Voir: `DEVELOPER_GUIDE.md`

## 🏗️ Structure Application

```
HomePage
├── Tab 1: Écoles
│   └── Grille d'EcoleCards
│       └── Tap → EcoleDetailPage
│
├── Tab 2: Concours
│   └── Grille de ConcoursCards
│       └── Tap → ConcoursDetailPage
│           └── PDF button → PdfViewerPage
│
└── Tab 3: Recherche
    └── CustomSearchBar
        └── Multi-entity results
            ├── Écoles
            ├── Filières
            ├── Cours
            └── Concours
```

## 🎓 Apprentissage

### Si vous débutez en Flutter
1. Lire Flutter Basics: https://flutter.dev/docs/get-started/learn-more
2. Comprendre BLoC: https://bloclibrary.dev/
3. Material Design: https://material.io/

### Si vous débutez avec Appwrite
1. Lire Appwrite Docs: https://appwrite.io/docs
2. SDK Dart: https://pub.dev/packages/appwrite
3. Créer collections: https://appwrite.io/docs/databases

## 🤔 Questions Fréquentes

**Q: Puis-je faire tourner en offline?**
A: Pas actuellement, à ajouter. Voir `PROJECT_SUMMARY.md`

**Q: Comment ajouter l'authentification?**
A: Implémenter avec Appwrite Auth. À faire dans Sprint 2.

**Q: Comment déployer?**
A: Voir `DEVELOPER_GUIDE.md` section déploiement.

**Q: Quel est le coverage de tests?**
A: À ajouter. Actuellement ~0%, target 80%+

**Q: Puis-je utiliser sur iOS?**
A: Oui! À compiler avec `flutter build ios`

**Q: Comment ajouter une nouvelle page?**
A: Voir `DEVELOPER_GUIDE.md` section "Ajouter une nouvelle fonctionnalité"

## 🚀 Commandes Utiles

```bash
# Développement
flutter run                    # Lancer l'app
flutter run -v                # Avec verbose logs
flutter pub get               # Installer dépendances
flutter pub upgrade           # Mettre à jour

# Testing
flutter test                  # Tests unitaires
flutter drive --target=test_driver/app.dart  # Tests d'intégration

# Building
flutter build apk --release   # APK Android
flutter build appbundle       # App Bundle Play Store
flutter build ios --release   # iOS

# Maintenance
flutter clean                 # Nettoyer builds
flutter analyze              # Linter
flutter format .             # Formatter
dart fix --apply            # Auto-fixes

# DevTools
devtools                     # Lancer DevTools
flutter pub global run devtools

# Logs
flutter logs                 # Voir logs en direct
```

## 📞 Support

- **Erreurs compilation**: `TROUBLESHOOTING.md`
- **Questions architecture**: `BLOC_ARCHITECTURE.md`
- **Guide développement**: `DEVELOPER_GUIDE.md`
- **Index fichiers**: `FILE_INDEX.md`
- **Setup Appwrite**: `APPWRITE_SETUP.md`

## ✅ Vous êtes Prêt!

Suivez les étapes ci-dessus et vous aurez une app DocStore EPL fonctionnelle en quelques minutes.

**Let's go! 🚀**

---

**Besoin d'aide?**
1. Lire la doc appropriée
2. Chercher dans Google/Stackoverflow
3. Ouvrir une issue Github
4. Consulter la communauté Flutter

**Happy Coding!** 😊
