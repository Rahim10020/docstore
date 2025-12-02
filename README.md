# DocStore EPL - Mobile

Une application mobile Flutter pour explorer l'offre académique de l'École Polytechnique de Lomé : écoles, filières, parcours, cours, ressources PDF et concours d'entrée.

## 🎨 Identité Visuelle

### Couleurs Clés
- **Écoles**: Bleu (#3b82f6) → Indigo (#4f46e5)
- **Concours**: Orange (#f97316) → Jaune (#eab308)
- **Fond**: #f8fafc → #f1f5f9
- **Texte**: #1f2937, #374151
- **Statuts**: Succès #22c55e, Erreur #ef4444

### Gradients
- **Écoles**: linear-gradient(135deg, #3b82f6, #4f46e5)
- **Concours**: linear-gradient(135deg, #f97316, #eab308)
- **Fond**: linear-gradient(to br, #f8fafc, #f1f5f9)

## 🗂️ Architecture

```
lib/
  config/              # Configuration (theme, routes, constants)
  data/
    models/            # Modèles de données
    repositories/      # Accès aux données Appwrite
    services/          # Services (Appwrite, téléchargement, connectivité)
  presentation/
    bloc/              # State management avec BLoC
    pages/             # Pages principales
    widgets/           # Widgets réutilisables
  utils/               # Utilitaires
```

## 📦 Dépendances Principales

- **flutter_bloc** (8.1.3) - State management
- **appwrite** (14.0.0) - Backend API
- **dio** (5.4.0) - HTTP client pour téléchargements
- **syncfusion_flutter_pdfviewer** (25.1.35) - Visionnage PDF
- **path_provider** (2.1.1) - Accès au stockage local
- **permission_handler** (11.4.4) - Gestion des permissions
- **connectivity_plus** (5.0.1) - Détection connectivité
- **logger** (2.1.0) - Logging
- **google_fonts** (6.1.0) - Polices de caractères

## 🏗️ Structure des Données

### Collections Appwrite

**Écoles**
- nom, description, lieu, logo, couleur

**Filières**
- nom, parcoursId, description

**Parcours**
- nom, description

**Années**
- nom, annee, filiereId

**Semestres**
- nom, type (Harmattan/Mousson), anneeId

**Cours**
- titre, description, semesterId, ressources[]

**Ressources**
- nom, type (Cours/Exercices/TD/TP/Communiqué), url, description

**Concours**
- nom, description, annee, ecoleId, communiquePdfUrl, communiquePdfNom

## 📄 Pages Principales

### HomePage (Tabs)
- **Tab 1: Écoles** - Grille de cards gradient bleu avec nom, description, lieu
- **Tab 2: Concours** - Grille responsive avec filtres année/école
- **Tab 3: Recherche** - Recherche multi-entités avec historique (max 10)

### EcoleDetailPage
- Affichage complet de l'école
- Description détaillée
- Accès aux filières

### ConcoursDetailPage
- Détails du concours
- Visionnage/téléchargement du communiqué PDF
- Partage

### CoursDetailPage
- Titre et description
- Liste des ressources (Cours, TD, TP, etc.)
- Téléchargement et visionnage des PDF

### PdfViewerPage
- Visionnage PDF in-app via Syncfusion
- Barre d'outils avec recherche et favoris
- Options de partage et téléchargement

## 🌟 Fonctionnalités

### Core Features
✅ Navigation par tabs fluide
✅ Grille responsive (1 col mobile, 2 col tablette, 3 col desktop)
✅ Chargement paginé des données
✅ Recherche multi-entités avec debounce (500ms)
✅ Historique de recherche
✅ Loader animé et gestion d'erreurs

### PDF & Téléchargements
✅ Visionnage PDF in-app
✅ Téléchargement avec barre de progression
✅ Stockage local des PDFs
✅ Partage via système

### Design & UX
✅ Thème cohérent avec identity visuelle web
✅ Padding standardisé (16px)
✅ Cards avec radius 16px
✅ Animations fluides (300ms, easeInOutCubic)
✅ States widgets (Loader, Error, Empty)

## 🔧 Configuration Appwrite

Avant de lancer l'app, mettre à jour les constantes dans `lib/config/app_constants.dart`:

```dart
static const String appwriteEndpoint = 'YOUR_APPWRITE_ENDPOINT';
static const String appwriteProjectId = 'YOUR_PROJECT_ID';
static const String appwriteApiKey = 'YOUR_API_KEY';
static const String databaseId = 'YOUR_DATABASE_ID';
```

## 🚀 Installation & Lancement

```bash
# Installer les dépendances
flutter pub get

# Lancer en développement
flutter run

# Build APK (Android)
flutter build apk

# Build IPA (iOS)
flutter build ios
```

## 📱 Permissions Requises

**Android** (`android/app/src/main/AndroidManifest.xml`)
- INTERNET
- READ_EXTERNAL_STORAGE
- WRITE_EXTERNAL_STORAGE

**iOS** (`ios/Runner/Info.plist`)
- NSPhotoLibraryUsageDescription
- NSPhotoLibraryAddOnlyUsageDescription

## 🎨 Composants Réutilisables

- **CustomLoader** - Loader animé avec message
- **CustomErrorWidget** - Widget d'erreur avec bouton retry
- **EmptyStateWidget** - État vide personnalisable
- **EcoleCard** - Card d'école avec gradient
- **CoursCard** - Card de cours avec badge ressources
- **ConcoursCard** - Card de concours avec icône PDF
- **RessourceCard** - Card ressource avec type et couleur
- **CustomSearchBar** - Barre de recherche avec clear

## 🔄 État Management (BLoC)

### EcoleBloc
- `FetchEcoles` - Chargement paginé
- `FetchEcoleById` - Détails d'une école
- `SearchEcoles` - Recherche

### ConcoursBloc
- `FetchConcours` - Chargement paginé
- `FetchConcoursById` - Détails d'un concours
- `SearchConcours` - Recherche

### SearchBloc
- `PerformSearch` - Recherche multi-entités
- `AddToHistory` - Ajout à l'historique
- `ClearHistory` - Effacement historique

## 📊 Responsive Design

```
Mobile (< 600px):  1 colonne
Tablette (600-900): 2 colonnes
Desktop (> 900px):  3 colonnes
```

## ⚠️ Gestion d'Erreurs

- Try-catch dans tous les repositor ies
- Messages d'erreur utilisateur
- Bouton retry sur les erreurs
- Logging via Logger
- Detection de connectivité

## 🌐 Intégration Appwrite

- CRUD complet pour toutes les collections
- Gestion des erreurs Appwrite
- Logging des opérations
- Pagination avec limite d'items
- Recherche côté client

## 💾 Stockage Local

- Téléchargements dans `/docstore/downloads/`
- Vérification d'existence avant download
- Suppression de fichiers
- Utilisation de path_provider

## 🎯 Prochaines Améliorations

- [ ] Mode offline complet
- [ ] Système de favoris
- [ ] Notifications pour nouveaux concours
- [ ] Thème sombre
- [ ] Historique des consultations
- [ ] Lazy loading images
- [ ] Cache 24h
- [ ] Accessibilité améliorée

## 📝 Notes de Développement

- Tous les modèles étendent `Equatable` pour la comparaison
- BLoC pour l'état global de l'app
- Services injectés via RepositoryProvider
- Repositories comme couche métier
- Widgets stateless autant que possible

## 👨‍💻 Auteur

Équipe de développement DocStore EPL

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
