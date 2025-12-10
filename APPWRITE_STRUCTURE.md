# DocStore - Documentation de la structure Appwrite

## Structure des Collections Appwrite

### 1. Collection `ecoles` (Schools)
**ID Collection**: `67f727d60008a5965d9e`

Champs:
- `id` (string, required) - Identifiant unique de l'école
- `nom` (string, required) - Nom complet de l'école
- `description` (string, optional) - Description de l'école
- `$createdAt` (datetime) - Date de création
- `$updatedAt` (datetime) - Date de mise à jour

### 2. Collection `filieres` (Programs/Departments)
**ID Collection**: `67f728960028e33b576a`

Champs:
- `id` (string, required) - Identifiant unique de la filière
- `nom` (string, required) - Nom de la filière
- `description` (string, optional) - Description de la filière
- `parcours` (string, required) - Type de parcours (ex: "L1-L3", "M1-M2")
- `idEcole` (string, required) - ID de l'école parente
- `$createdAt` (datetime) - Date de création
- `$updatedAt` (datetime) - Date de mise à jour

Relation: `idEcole` → `ecoles.$id`

### 3. Collection `ues` (Course Units)
**ID Collection**: `67f72a8f00239ccc2b36`

Champs:
- `id` (string, required) - Identifiant unique de l'UE
- `nom` (string, required) - Nom de l'UE
- `description` (string, optional) - Description de l'UE
- `anneeEnseignement` (string, optional) - Année d'enseignement (ex: "L1", "M2")
- `ressources[]` (array of strings) - IDs des fichiers dans le bucket Appwrite
- `idFiliere` (string, required) - ID de la filière parente
- `$createdAt` (datetime) - Date de création
- `$updatedAt` (datetime) - Date de mise à jour

Relation: `idFiliere` → `filieres.$id`

### 4. Collection `concours` (Competitions/Exams)
**ID Collection**: `6893ba70001b392138f7`

Champs:
- `nom` (string, optional) - Nom du concours
- `annee` (string, optional) - Année du concours
- `description` (string, optional) - Description du concours
- `ressources[]` (array of strings) - IDs des fichiers (sujets, corrigés)
- `idEcole` (string, optional) - ID de l'école concernée
- `communiques[]` (array of strings) - IDs des fichiers de communiqués
- `$createdAt` (datetime) - Date de création
- `$updatedAt` (datetime) - Date de mise à jour

Relation: `idEcole` → `ecoles.$id` (optionnelle)

### 5. Storage Bucket
**ID Bucket**: `67efdc26000acfe7e2ea`

Contient tous les fichiers PDF et autres ressources.

## Configuration Appwrite

### Fichier: `lib/config/appwrite_config.dart`

Ce fichier contient toutes les configurations Appwrite:
- Project ID: `67efdbc8003bcb27bcaf`
- Database ID: `67efdc570033ac52dd43`
- Endpoint: `https://cloud.appwrite.io/v1`

## Modèles Dart

Tous les modèles sont dans `lib/data/models/`:
- `ecole.dart` - Modèle École
- `filiere.dart` - Modèle Filière
- `ue.dart` - Modèle UE
- `concours.dart` - Modèle Concours

Chaque modèle a:
- `fromMap()` - Constructeur depuis un Map
- `toMap()` - Conversion vers Map
- `fromJson()` / `toJson()` - Sérialisation JSON

## Services

### AppwriteService (`lib/services/appwrite_service.dart`)

Méthodes disponibles:

**Écoles:**
- `getEcoles()` - Récupère toutes les écoles
- `getEcole(String ecoleId)` - Récupère une école spécifique

**Filières:**
- `getFilieresByEcole(String ecoleId)` - Récupère les filières d'une école
- `getFiliere(String filiereId)` - Récupère une filière spécifique

**UEs:**
- `getUesByFiliere(String filiereId)` - Récupère les UEs d'une filière
- `getUe(String ueId)` - Récupère une UE spécifique

**Concours:**
- `getConcours({String? ecoleId})` - Récupère tous les concours (filtrés par école si spécifié)
- `getConcoursById(String concoursId)` - Récupère un concours spécifique

**Storage:**
- `getFilePreview(String fileId)` - URL de preview d'un fichier
- `getFileDownload(String fileId)` - URL de téléchargement
- `getFileView(String fileId)` - URL de visualisation

## Providers Riverpod

Fichier: `lib/providers/data_provider.dart`

Providers disponibles:
- `ecolesProvider` - Liste des écoles
- `ecoleProvider(ecoleId)` - Une école spécifique
- `filieresByEcoleProvider(ecoleId)` - Filières d'une école
- `filiereProvider(filiereId)` - Une filière spécifique
- `uesByFiliereProvider(filiereId)` - UEs d'une filière
- `ueProvider(ueId)` - Une UE spécifique
- `concoursProvider` - Tous les concours
- `concoursByEcoleProvider(ecoleId)` - Concours d'une école
- `concoursDetailProvider(concoursId)` - Un concours spécifique

## Écrans

Navigation: `Home → Filières → UEs → Détails UE`

1. **HomeScreen** - Liste des écoles
2. **FilieresScreen** - Liste des filières d'une école
3. **UesScreen** - Liste des UEs d'une filière
4. **UeDetailScreen** - Détails d'une UE avec ses ressources
5. **PdfViewerScreen** - Visualiseur PDF

## Migration depuis l'ancien système

### Changements principaux:

1. **Données statiques → Base de données Appwrite**
   - Avant: `schools_data.dart` avec données en dur
   - Après: Collections Appwrite dynamiques

2. **Google Drive → Appwrite Storage**
   - Avant: Fichiers sur Google Drive
   - Après: Fichiers dans le bucket Appwrite

3. **Modèles simplifiés**
   - Avant: `School` → `Department` → Cours
   - Après: `Ecole` → `Filiere` → `Ue` → Ressources

4. **Architecture plus claire**
   - Séparation des préoccupations
   - Providers Riverpod pour la gestion d'état
   - Service centralisé pour Appwrite

## Installation

1. Assurez-vous d'avoir le SDK Appwrite installé:
   ```yaml
   dependencies:
     appwrite: ^13.0.0
   ```

2. Initialisez Appwrite dans votre `main.dart`:
   ```dart
   void main() {
     AppwriteConfig().init();
     runApp(MyApp());
   }
   ```

## Notes importantes

- Les IDs de fichiers dans `ressources[]` correspondent aux IDs des fichiers dans le bucket Appwrite
- Les relations entre collections sont gérées via les champs `idEcole`, `idFiliere`
- Tous les providers utilisent Riverpod pour le cache et la gestion d'état
- Les erreurs sont remontées et affichées avec des boutons de réessai

