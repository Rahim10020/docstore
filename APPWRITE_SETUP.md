# Guide d'Intégration Appwrite - DocStore EPL

## Configuration Initiale

### 1. Créer une instance Appwrite

```bash
# Docker (local)
docker run -d \
  -h appwrite \
  --name=appwrite \
  -p 80:80 \
  -p 443:443 \
  -e _APP_STORAGE_DEVICE=local \
  appwrite/appwrite:latest
```

Accès: http://localhost (créer un compte admin)

### 2. Créer un Projet

- Nom: `DocStore EPL`
- Description: `Application mobile pour explorer l'offre académique EPL`

### 3. Créer une Base de Données

Nom: `main_db`

### 4. Créer les Collections

#### Collection: Écoles
```
Attributs:
- nom (String, Requis)
- description (String, Requis)
- lieu (String, Requis)
- logo (String, Optionnel)
- couleur (String, Optionnel)

Permissions:
- Read: All
- Create: Admin
- Update: Admin
- Delete: Admin
```

#### Collection: Filières
```
Attributs:
- nom (String, Requis)
- parcoursId (String, Requis - Relationship → Parcours)
- description (String, Optionnel)

Permissions:
- Read: All
- Create: Admin
- Update: Admin
- Delete: Admin
```

#### Collection: Parcours
```
Attributs:
- nom (String, Requis)
- description (String, Optionnel)

Permissions:
- Read: All
- Create: Admin
- Update: Admin
- Delete: Admin
```

#### Collection: Années
```
Attributs:
- nom (String, Requis)
- annee (Integer, Requis)
- filiereId (String, Requis - Relationship → Filières)

Permissions:
- Read: All
- Create: Admin
- Update: Admin
- Delete: Admin
```

#### Collection: Semestres
```
Attributs:
- nom (String, Requis)
- type (String, Requis - Enum: "harmattan", "mousson")
- anneeId (String, Requis - Relationship → Années)

Permissions:
- Read: All
- Create: Admin
- Update: Admin
- Delete: Admin
```

#### Collection: Cours
```
Attributs:
- titre (String, Requis)
- description (String, Optionnel)
- semesterId (String, Requis - Relationship → Semestres)

Permissions:
- Read: All
- Create: Admin
- Update: Admin
- Delete: Admin
```

#### Collection: Ressources
```
Attributs:
- nom (String, Requis)
- type (String, Requis - Enum: "Cours", "Exercices", "TD", "TP", "Communiqué")
- url (String, Requis)
- description (String, Optionnel)

Permissions:
- Read: All
- Create: Admin
- Update: Admin
- Delete: Admin
```

#### Collection: Concours
```
Attributs:
- nom (String, Requis)
- description (String, Optionnel)
- annee (Integer, Requis)
- ecoleId (String, Requis - Relationship → Écoles)
- communiquePdfUrl (String, Optionnel)
- communiquePdfNom (String, Optionnel)

Permissions:
- Read: All
- Create: Admin
- Update: Admin
- Delete: Admin
```

### 5. Créer une Clé API

- Scopes: `databases.read`, `buckets.read`, `files.read`
- Secret à copier

### 6. Mettre à Jour la Configuration Flutter

Éditer `lib/config/app_constants.dart`:

```dart
static const String appwriteEndpoint = 'http://votre-domaine';
static const String appwriteProjectId = 'YOUR_PROJECT_ID';
static const String appwriteApiKey = 'YOUR_API_KEY';
static const String databaseId = 'main_db';
```

## Données d'Exemple

### Écoles
```json
{
  "nom": "Génie Logiciel",
  "description": "Filière d'excellence en informatique et développement logiciel",
  "lieu": "Campus Principal",
  "couleur": "#3b82f6"
}
```

### Parcours
```json
{
  "nom": "Informatique Générale",
  "description": "Formation généraliste en informatique"
}
```

### Filières
```json
{
  "nom": "Génie Logiciel",
  "parcoursId": "PARCOURS_ID",
  "description": "Spécialisation en développement logiciel"
}
```

### Années
```json
{
  "nom": "Première Année",
  "annee": 1,
  "filiereId": "FILIERE_ID"
}
```

### Semestres
```json
{
  "nom": "Semestre 1",
  "type": "harmattan",
  "anneeId": "ANNEE_ID"
}
```

### Cours
```json
{
  "titre": "Algorithmique et Programmation",
  "description": "Fondamentaux de la programmation",
  "semesterId": "SEMESTRE_ID"
}
```

### Ressources
```json
{
  "nom": "Cours Complet",
  "type": "Cours",
  "url": "https://example.com/file.pdf",
  "description": "Cours complet d'algorithmique"
}
```

### Concours
```json
{
  "nom": "Concours EPL 2024",
  "description": "Concours d'entrée à l'EPL 2024",
  "annee": 2024,
  "ecoleId": "ECOLE_ID",
  "communiquePdfUrl": "https://example.com/communique.pdf",
  "communiquePdfNom": "Communiqué 2024"
}
```

## Troubleshooting

### Erreur: "Endpoint not found"
- Vérifier l'URL Appwrite
- S'assurer que Appwrite est en cours d'exécution
- Vérifier la connectivité réseau

### Erreur: "Invalid API Key"
- Vérifier la clé API dans `app_constants.dart`
- S'assurer que la clé a les bons scopes
- Vérifier le Project ID

### Erreur: "Collection not found"
- Vérifier que les IDs de collection correspondent
- S'assurer que les collections sont bien créées dans la DB
- Vérifier les permissions

## Notes de Sécurité

- ⚠️ NE PAS committer les clés API en production
- Utiliser des variables d'environnement ou un fichier `.env`
- Restreindre les permissions par rôle utilisateur
- HTTPS obligatoire en production
- Mettre à jour régulièrement Appwrite
