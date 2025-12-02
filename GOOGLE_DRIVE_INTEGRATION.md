# 🚀 Intégration Google Drive - Documentation

## Vue d'ensemble

L'application supporte désormais un système hybride de gestion de fichiers qui permet de stocker et récupérer des ressources depuis :
- **Appwrite Storage** : Fichiers hébergés directement sur Appwrite
- **Google Drive** : Liens vers des fichiers hébergés sur Google Drive

## 📁 Architecture

### Services créés

#### 1. `GoogleDriveService`
**Fichier** : `lib/data/services/google_drive_service.dart`

Gère toutes les opérations liées à Google Drive :
- ✅ Détection des URLs Google Drive
- ✅ Extraction de l'ID de fichier depuis l'URL
- ✅ Génération d'URLs de prévisualisation et téléchargement
- ✅ Récupération optionnelle des métadonnées via API backend

**Méthodes principales** :
```dart
bool isGoogleDriveUrl(String url)
String? extractFileId(String url)
String getPreviewUrl(String fileId)
String getDownloadUrl(String fileId)
Future<Map<String, dynamic>?> getFileMetadata(String driveUrl)
Future<String> getFileName(String driveUrl)
```

#### 2. `FileService`
**Fichier** : `lib/data/services/file_service.dart`

Service unifié qui :
- ✅ Détecte automatiquement le type de ressource (Appwrite ou Google Drive)
- ✅ Récupère les métadonnées appropriées
- ✅ Convertit les ressources en objets `FileResource` uniformes

**Méthodes principales** :
```dart
Future<List<FileResource>> processResources(List<String> resources)
Future<FileResource?> getFile(String resourceIdOrUrl)
bool isGoogleDriveUrl(String resource)
```

### Modèles

#### `FileResource`
**Fichier** : `lib/data/models/file_resource.dart`

Modèle unifié représentant un fichier, quelle que soit sa source :

```dart
class FileResource {
  final String id;              // ID Appwrite ou Google Drive
  final String name;            // Nom du fichier
  final String url;             // URL de visualisation
  final String downloadUrl;     // URL de téléchargement
  final FileSourceType sourceType; // appwrite ou googleDrive
  final String? mimeType;
  final int? size;
  final String? description;
}
```

**Propriétés utiles** :
- `isPdf` : Vérifie si c'est un PDF
- `isImage` : Vérifie si c'est une image
- `formattedSize` : Taille formatée (KB, MB, GB)
- `fileIcon` : Emoji représentant le type de fichier

### Modifications des modèles existants

#### `Cours`
```dart
class Cours {
  // ...
  final List<String> ressources; // IDs Appwrite ou URLs Google Drive
}
```

#### `Concours`
```dart
class Concours {
  // ...
  final List<String> communiques; // IDs Appwrite ou URLs Google Drive
  final List<String> ressources;  // IDs Appwrite ou URLs Google Drive
}
```

### Repositories mis à jour

#### `CoursRepository`
Nouvelles méthodes :
```dart
Future<List<FileResource>> getCoursResources(String coursId)
Future<List<FileResource>> getResourcesFromCours(Cours cours)
```

#### `ConcoursRepository`
Nouvelles méthodes :
```dart
Future<List<FileResource>> getConcoursCommuniques(String concoursId)
Future<List<FileResource>> getConcoursRessources(String concoursId)
Future<List<FileResource>> getCommuniquesFromConcours(Concours concours)
Future<List<FileResource>> getRessourcesFromConcours(Concours concours)
```

## 🔧 Utilisation

### Stocker des ressources dans Appwrite

Lors de la création d'un document (cours ou concours), le champ `ressources` peut contenir :

```json
{
  "ressources": [
    "67abc123def456789",  // ID Appwrite Storage
    "https://drive.google.com/file/d/1ABCxyz123/view"  // URL Google Drive
  ]
}
```

### Formats d'URLs Google Drive supportés

```
https://drive.google.com/file/d/FILE_ID/view
https://drive.google.com/file/d/FILE_ID/edit
https://docs.google.com/document/d/FILE_ID/view
```

### Dans le code Flutter

#### Récupérer les ressources d'un cours

```dart
final repository = CoursRepository(AppwriteService());
final resources = await repository.getResourcesFromCours(cours);

// resources est une List<FileResource>
for (final resource in resources) {
  print('Nom: ${resource.name}');
  print('Type: ${resource.sourceType}');
  print('URL: ${resource.url}');
  print('Taille: ${resource.formattedSize}');
}
```

#### Afficher dans l'UI

Les pages `CoursDetailPage` et `ConcoursDetailPage` ont été mises à jour pour :
- ✅ Charger automatiquement les ressources (Appwrite + Google Drive)
- ✅ Afficher la source de chaque fichier (icône cloud ou storage)
- ✅ Afficher la taille du fichier si disponible
- ✅ Ouvrir les fichiers en prévisualisation

## 🌐 API Backend (Optionnel)

### Endpoint
```
https://biblio-epl.vercel.app/api/google-drive
```

### Utilisation
```
GET /api/google-drive?url=ENCODED_GOOGLE_DRIVE_URL
```

### Réponse réussie
```json
{
  "success": true,
  "fileInfo": {
    "id": "1ABC123xyz",
    "name": "Document.pdf",
    "mimeType": "application/pdf",
    "size": "1234567",
    "modifiedTime": "2024-01-01T00:00:00.000Z"
  }
}
```

### Réponse en erreur
```json
{
  "error": "Invalid Google Drive URL",
  "name": "Document Google Drive"
}
```

**Note** : Si l'API n'est pas disponible, l'application fonctionne toujours en utilisant un nom par défaut.

## 📱 UI/UX

### Indicateurs visuels

Chaque fichier affiche :
- 📄 **Icône** : Type de fichier (PDF, image, document)
- ☁️ **Source** : Badge "Google Drive" ou "Appwrite"
- 📊 **Taille** : Si disponible, affichée en KB/MB/GB

### Actions disponibles

- **Prévisualiser** : Ouvre le fichier dans le PDF viewer
- **Télécharger** : Télécharge le fichier localement (via `DownloadService`)

## 🔄 Flux de données

```
1. Appwrite Database contient:
   ressources: ["appwriteId1", "https://drive.google.com/...", "appwriteId2"]

2. Repository appelle FileService.processResources()

3. Pour chaque ressource:
   - Si contient "drive.google.com" → GoogleDriveService
     * Extrait l'ID du fichier
     * Génère les URLs de preview/download
     * (Optionnel) Récupère les métadonnées via API
   
   - Sinon → Appwrite Storage
     * Récupère les métadonnées via storage.getFile()
     * Génère les URLs avec storage.getFileView/Download()

4. Retourne une List<FileResource> unifiée

5. UI affiche la liste avec les infos appropriées
```

## ✅ Avantages de cette approche

1. **Flexibilité** : Support de multiples sources de fichiers
2. **Performance** : Pas besoin de dupliquer les fichiers
3. **Cohérence** : Interface unifiée via `FileResource`
4. **Évolutivité** : Facile d'ajouter d'autres sources (Dropbox, OneDrive, etc.)
5. **Graceful degradation** : Fonctionne même si l'API Google Drive est indisponible

## 🚨 Gestion des erreurs

Le système gère automatiquement :
- ✅ URLs Google Drive invalides
- ✅ Fichiers Appwrite introuvables
- ✅ API backend indisponible
- ✅ Erreurs réseau

En cas d'erreur, un message est affiché avec option de réessayer.

## 📦 Dépendances ajoutées

```yaml
dependencies:
  http: ^1.2.0  # Pour les requêtes API Google Drive
```

## 🔮 Améliorations futures possibles

- [ ] Cache des métadonnées Google Drive
- [ ] Support d'autres providers (Dropbox, OneDrive)
- [ ] Authentification Google Drive pour fichiers privés
- [ ] Prévisualisation en ligne des documents Google Docs/Sheets
- [ ] Upload direct vers Google Drive depuis l'app
- [ ] Synchronisation bidirectionnelle

## 📝 Notes importantes

1. Les URLs Google Drive doivent être **publiques** ou accessibles via le lien
2. L'API backend est optionnelle mais recommandée pour de meilleures métadonnées
3. Les fichiers ne sont pas dupliqués, seuls les liens sont stockés
4. La taille des fichiers Google Drive peut ne pas être disponible sans l'API

## 🛠️ Tests recommandés

1. Créer un cours avec un mix de fichiers Appwrite et Google Drive
2. Vérifier que tous les fichiers s'affichent correctement
3. Tester la prévisualisation de chaque type
4. Tester le téléchargement depuis les deux sources
5. Vérifier le comportement en mode hors ligne
