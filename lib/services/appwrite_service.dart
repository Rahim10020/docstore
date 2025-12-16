import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import 'package:docstore/config/appwrite_config.dart';
import 'package:docstore/data/models/ecole.dart';
import 'package:docstore/data/models/filiere.dart';
import 'package:docstore/data/models/ue.dart' as ue_model;
import 'package:docstore/data/models/concours.dart';

/// Service principal pour interagir avec Appwrite
class AppwriteService {
  // Singleton pattern
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  final AppwriteConfig _config = AppwriteConfig();
  late final Databases _databases;
  late final Storage _storage;

  /// Cache pour les métadonnées des fichiers
  final Map<String, Map<String, dynamic>> _fileMetadataCache = {};

  /// Initialise le service
  void init() {
    _databases = _config.databases;
    _storage = _config.storage;
  }

  // ========== ECOLES ==========

  /// Récupère toutes les écoles
  Future<List<Ecole>> getEcoles() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ecolesCollectionId,
      );
      return response.documents.map((doc) => Ecole.fromMap(doc.data)).toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des écoles: $e');
      rethrow;
    }
  }

  /// Récupère une école par ID
  Future<Ecole> getEcole(String ecoleId) async {
    try {
      final response = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ecolesCollectionId,
        documentId: ecoleId,
      );
      return Ecole.fromMap(response.data);
    } catch (e) {
      debugPrint('Erreur lors de la récupération de l\'école: $e');
      rethrow;
    }
  }

  /// Crée une nouvelle école
  Future<Ecole> createEcole(Ecole ecole) async {
    try {
      final response = await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ecolesCollectionId,
        documentId: ID.unique(),
        data: ecole.toMap(),
      );
      return Ecole.fromMap(response.data);
    } catch (e) {
      debugPrint('Erreur lors de la création de l\'école: $e');
      rethrow;
    }
  }

  /// Met à jour une école
  Future<Ecole> updateEcole(String ecoleId, Ecole ecole) async {
    try {
      final response = await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ecolesCollectionId,
        documentId: ecoleId,
        data: ecole.toMap(),
      );
      return Ecole.fromMap(response.data);
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de l\'école: $e');
      rethrow;
    }
  }

  /// Supprime une école
  Future<void> deleteEcole(String ecoleId) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ecolesCollectionId,
        documentId: ecoleId,
      );
    } catch (e) {
      debugPrint('Erreur lors de la suppression de l\'école: $e');
      rethrow;
    }
  }

  // ========== FILIERES ==========

  /// Récupère toutes les filières
  Future<List<Filiere>> getFilieres() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.filieresCollectionId,
      );
      return response.documents
          .map((doc) => Filiere.fromMap(doc.data))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des filières: $e');
      rethrow;
    }
  }

  /// Récupère les filières d'une école
  Future<List<Filiere>> getFilieresByEcole(String ecoleId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.filieresCollectionId,
        queries: [Query.equal('idEcole', ecoleId)],
      );
      return response.documents
          .map((doc) => Filiere.fromMap(doc.data))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des filières: $e');
      rethrow;
    }
  }

  /// Récupère une filière par ID
  Future<Filiere> getFiliere(String filiereId) async {
    try {
      final response = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.filieresCollectionId,
        documentId: filiereId,
      );
      return Filiere.fromMap(response.data);
    } catch (e) {
      debugPrint('Erreur lors de la récupération de la filière: $e');
      rethrow;
    }
  }

  /// Crée une nouvelle filière
  Future<Filiere> createFiliere(Filiere filiere) async {
    try {
      final response = await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.filieresCollectionId,
        documentId: ID.unique(),
        data: filiere.toMap(),
      );
      return Filiere.fromMap(response.data);
    } catch (e) {
      debugPrint('Erreur lors de la création de la filière: $e');
      rethrow;
    }
  }

  /// Met à jour une filière
  Future<Filiere> updateFiliere(String filiereId, Filiere filiere) async {
    try {
      final response = await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.filieresCollectionId,
        documentId: filiereId,
        data: filiere.toMap(),
      );
      return Filiere.fromMap(response.data);
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de la filière: $e');
      rethrow;
    }
  }

  /// Supprime une filière
  Future<void> deleteFiliere(String filiereId) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.filieresCollectionId,
        documentId: filiereId,
      );
    } catch (e) {
      debugPrint('Erreur lors de la suppression de la filière: $e');
      rethrow;
    }
  }

  // ========== UES ==========

  /// Récupère toutes les UEs
  Future<List<ue_model.Ue>> getUEs() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.uesCollectionId,
      );
      return response.documents
          .map((doc) => ue_model.Ue.fromMap(doc.data))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des UEs: $e');
      rethrow;
    }
  }

  /// Récupère les UEs d'une filière
  Future<List<ue_model.Ue>> getUEsByFiliere(String filiereId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.uesCollectionId,
        queries: [Query.equal('idFiliere', filiereId)],
      );
      return response.documents
          .map((doc) => ue_model.Ue.fromMap(doc.data))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des UEs: $e');
      rethrow;
    }
  }

  /// Récupère une UE par ID
  Future<ue_model.Ue> getUE(String ueId) async {
    try {
      final response = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.uesCollectionId,
        documentId: ueId,
      );
      return ue_model.Ue.fromMap(response.data);
    } catch (e) {
      debugPrint('Erreur lors de la récupération de l\'UE: $e');
      rethrow;
    }
  }

  /// Crée une nouvelle UE
  Future<ue_model.Ue> createUE(ue_model.Ue ue) async {
    try {
      final response = await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.uesCollectionId,
        documentId: ID.unique(),
        data: ue.toMap(),
      );
      return ue_model.Ue.fromMap(response.data);
    } catch (e) {
      debugPrint('Erreur lors de la création de l\'UE: $e');
      rethrow;
    }
  }

  /// Met à jour une UE
  Future<ue_model.Ue> updateUE(String ueId, ue_model.Ue ue) async {
    try {
      final response = await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.uesCollectionId,
        documentId: ueId,
        data: ue.toMap(),
      );
      return ue_model.Ue.fromMap(response.data);
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de l\'UE: $e');
      rethrow;
    }
  }

  /// Supprime une UE
  Future<void> deleteUE(String ueId) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.uesCollectionId,
        documentId: ueId,
      );
    } catch (e) {
      debugPrint('Erreur lors de la suppression de l\'UE: $e');
      rethrow;
    }
  }

  // ========== CONCOURS ==========

  /// Récupère tous les concours
  Future<List<Concours>> getConcours() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.concoursCollectionId,
      );
      return response.documents
          .map((doc) => Concours.fromMap(doc.data))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des concours: $e');
      rethrow;
    }
  }

  /// Récupère un concours par ID
  Future<Concours> getConcoursById(String concoursId) async {
    try {
      final response = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.concoursCollectionId,
        documentId: concoursId,
      );
      return Concours.fromMap(response.data);
    } catch (e) {
      debugPrint('Erreur lors de la récupération du concours: $e');
      rethrow;
    }
  }

  /// Récupère les concours d'une ecole
  Future<List<Concours>> getConcoursByEcole(String ecoleId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.concoursCollectionId,
        queries: [Query.equal('idEcole', ecoleId)],
      );
      return response.documents.map((d) => Concours.fromMap(d.data)).toList();
    } catch (e) {
      debugPrint(
        'Erreur lors de la récupération des concours pour l\'école $ecoleId: $e',
      );
      rethrow;
    }
  }

  /// Crée un nouveau concours
  Future<Concours> createConcours(Concours concours) async {
    try {
      final response = await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.concoursCollectionId,
        documentId: ID.unique(),
        data: concours.toMap(),
      );
      return Concours.fromMap(response.data);
    } catch (e) {
      debugPrint('Erreur lors de la création du concours: $e');
      rethrow;
    }
  }

  /// Met à jour un concours
  Future<Concours> updateConcours(String concoursId, Concours concours) async {
    try {
      final response = await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.concoursCollectionId,
        documentId: concoursId,
        data: concours.toMap(),
      );
      return Concours.fromMap(response.data);
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du concours: $e');
      rethrow;
    }
  }

  /// Supprime un concours
  Future<void> deleteConcours(String concoursId) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.concoursCollectionId,
        documentId: concoursId,
      );
    } catch (e) {
      debugPrint('Erreur lors de la suppression du concours: $e');
      rethrow;
    }
  }

  /// Recherche paginée des écoles (serveur)
  Future<List<Ecole>> searchEcoles(String query, {int limit = 20, int offset = 0}) async {
    try {
      final List<Ecole> results = [];

      // Première passe: chercher par nom
      final byName = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ecolesCollectionId,
        queries: [
          Query.search('nom', query),
          Query.limit(limit),
          Query.offset(offset),
        ],
      );
      results.addAll(byName.documents.map((d) => Ecole.fromMap(d.data)));

      // Si on n'a pas assez de résultats, chercher dans la description et ajouter sans dupliquer
      if (results.length < limit) {
        final remaining = limit - results.length;
        final byDesc = await _databases.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.ecolesCollectionId,
          queries: [
            Query.search('description', query),
            Query.limit(remaining),
            Query.offset(0),
          ],
        );
        for (final d in byDesc.documents) {
          final e = Ecole.fromMap(d.data);
          if (!results.any((r) => r.id == e.id)) results.add(e);
          if (results.length == limit) break;
        }
      }

      return results;
    } catch (e) {
      debugPrint('Erreur lors de la recherche des écoles: $e');
      rethrow;
    }
  }

  /// Recherche paginée des concours (serveur)
  Future<List<Concours>> searchConcours(String query, {int limit = 20, int offset = 0}) async {
    try {
      final List<Concours> results = [];

      final byName = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.concoursCollectionId,
        queries: [
          Query.search('nom', query),
          Query.limit(limit),
          Query.offset(offset),
        ],
      );
      results.addAll(byName.documents.map((d) => Concours.fromMap(d.data)));

      if (results.length < limit) {
        final remaining = limit - results.length;
        final byDesc = await _databases.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.concoursCollectionId,
          queries: [
            Query.search('description', query),
            Query.limit(remaining),
            Query.offset(0),
          ],
        );
        for (final d in byDesc.documents) {
          final c = Concours.fromMap(d.data);
          if (!results.any((r) => r.id == c.id)) results.add(c);
          if (results.length == limit) break;
        }
      }

      return results;
    } catch (e) {
      debugPrint('Erreur lors de la recherche des concours: $e');
      rethrow;
    }
  }

  /// Recherche paginée des UEs (serveur)
  Future<List<ue_model.Ue>> searchUEs(String query, {int limit = 20, int offset = 0}) async {
    try {
      final List<ue_model.Ue> results = [];

      final byName = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.uesCollectionId,
        queries: [
          Query.search('nom', query),
          Query.limit(limit),
          Query.offset(offset),
        ],
      );
      results.addAll(byName.documents.map((d) => ue_model.Ue.fromMap(d.data)));

      if (results.length < limit) {
        final remaining = limit - results.length;
        final byDesc = await _databases.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.uesCollectionId,
          queries: [
            Query.search('description', query),
            Query.limit(remaining),
            Query.offset(0),
          ],
        );
        for (final d in byDesc.documents) {
          final u = ue_model.Ue.fromMap(d.data);
          if (!results.any((r) => r.id == u.id)) results.add(u);
          if (results.length == limit) break;
        }
      }

      return results;
    } catch (e) {
      debugPrint('Erreur lors de la recherche des UEs: $e');
      rethrow;
    }
  }

  // ========== STORAGE - MÉTHODES AMÉLIORÉES ==========

  /// Upload un fichier
  Future<String> uploadFile(String filePath, String fileName) async {
    try {
      final file = await _storage.createFile(
        bucketId: AppwriteConfig.bucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: filePath, filename: fileName),
      );
      return file.$id;
    } catch (e) {
      debugPrint('Erreur lors de l\'upload du fichier: $e');
      rethrow;
    }
  }

  /// Récupère l'URL d'un fichier
  String getFileUrl(String fileId) {
    return '${AppwriteConfig.endpoint}/storage/buckets/${AppwriteConfig.bucketId}/files/$fileId/view?project=${AppwriteConfig.projectId}';
  }

  /// Récupère l'URL de visualisation d'un fichier
  String getFileView(String fileId) {
    return '${AppwriteConfig.endpoint}/storage/buckets/${AppwriteConfig.bucketId}/files/$fileId/view?project=${AppwriteConfig.projectId}';
  }

  /// Récupère l'URL de téléchargement d'un fichier
  String getFileDownload(String fileId) {
    return '${AppwriteConfig.endpoint}/storage/buckets/${AppwriteConfig.bucketId}/files/$fileId/download?project=${AppwriteConfig.projectId}';
  }

  /// Télécharge un fichier
  Future<void> downloadFile(String fileId, String savePath) async {
    try {
      await _storage.getFileDownload(
        bucketId: AppwriteConfig.bucketId,
        fileId: fileId,
      );
    } catch (e) {
      debugPrint('Erreur lors du téléchargement du fichier: $e');
      rethrow;
    }
  }

  /// Supprime un fichier
  Future<void> deleteFile(String fileId) async {
    try {
      await _storage.deleteFile(
        bucketId: AppwriteConfig.bucketId,
        fileId: fileId,
      );
      // Supprimer du cache
      _fileMetadataCache.remove(fileId);
    } catch (e) {
      debugPrint('Erreur lors de la suppression du fichier: $e');
      rethrow;
    }
  }

  /// Liste tous les fichiers
  /// AMÉLIORATION: Cette méthode retourne maintenant les objets File complets
  Future<List<dynamic>> listFiles() async {
    try {
      final response = await _storage.listFiles(
        bucketId: AppwriteConfig.bucketId,
      );
      return response.files;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des fichiers: $e');
      rethrow;
    }
  }

  /// Récupère les métadonnées d'un fichier spécifique
  /// NOUVELLE MÉTHODE AMÉLIORÉE: Utilise getFile() au lieu de listFiles()
  Future<Map<String, dynamic>?> getFileInfo(String fileId) async {
    // Vérifier le cache d'abord
    if (_fileMetadataCache.containsKey(fileId)) {
      debugPrint('📦 Métadonnées de $fileId récupérées depuis le cache');
      return _fileMetadataCache[fileId];
    }

    try {
      debugPrint('🔍 Récupération des métadonnées pour le fichier: $fileId');

      // Méthode directe: utiliser getFile() pour obtenir les métadonnées
      final file = await _storage.getFile(
        bucketId: AppwriteConfig.bucketId,
        fileId: fileId,
      );

      // Construire le dictionnaire de métadonnées
      final metadata = {
        'id': file.$id,
        'name': file.name,
        'mimeType': file.mimeType,
        'size': file.sizeOriginal,
        'createdAt': file.$createdAt,
        'updatedAt': file.$updatedAt,
      };

      // Mettre en cache
      _fileMetadataCache[fileId] = metadata;

      debugPrint(
        '✅ Métadonnées récupérées: ${metadata['name']} (${metadata['size']} bytes)',
      );

      return metadata;
    } catch (e) {
      debugPrint(
        '❌ Erreur lors de la récupération des métadonnées du fichier $fileId: $e',
      );

      // Fallback: Essayer avec listFiles() si getFile() échoue
      try {
        debugPrint('🔄 Tentative de fallback avec listFiles()...');
        final files = await listFiles();

        for (final f in files) {
          if (f is Map) {
            final Map<String, dynamic> m = Map<String, dynamic>.from(f);
            final candidateIds = <String?>[
              m['\$id']?.toString(),
              m['id']?.toString(),
              m['fileId']?.toString(),
            ];

            if (candidateIds.any((id) => id == fileId)) {
              final metadata = {
                'id': m['\$id'] ?? m['id'] ?? m['fileId'] ?? fileId,
                'name':
                    m['name'] ??
                    m['\$name'] ??
                    m['fileName'] ??
                    m['filename'] ??
                    'Document Appwrite',
                'mimeType': m['mimeType'] ?? m['contentType'] ?? m['type'],
                'size':
                    m['sizeOriginal'] ?? m['size'] ?? m['\$size'] ?? m['bytes'],
                'createdAt': m['\$createdAt'] ?? m['createdAt'],
                'updatedAt': m['\$updatedAt'] ?? m['updatedAt'],
              };

              // Mettre en cache
              _fileMetadataCache[fileId] = metadata;

              debugPrint(
                '✅ Métadonnées récupérées via fallback: ${metadata['name']}',
              );
              return metadata;
            }
          }
        }
      } catch (fallbackError) {
        debugPrint('❌ Fallback échoué: $fallbackError');
      }

      return null;
    }
  }

  /// Récupère les métadonnées de plusieurs fichiers en batch
  /// NOUVELLE MÉTHODE: Optimisée pour récupérer plusieurs fichiers
  Future<Map<String, Map<String, dynamic>>> getMultipleFilesInfo(
    List<String> fileIds,
  ) async {
    final Map<String, Map<String, dynamic>> results = {};

    debugPrint(
      '📚 Récupération des métadonnées de ${fileIds.length} fichiers...',
    );

    for (final fileId in fileIds) {
      try {
        final info = await getFileInfo(fileId);
        if (info != null) {
          results[fileId] = info;
        }
      } catch (e) {
        debugPrint('⚠️ Impossible de récupérer les métadonnées de $fileId: $e');
        // Continuer avec les autres fichiers
      }
    }

    debugPrint(
      '✅ ${results.length}/${fileIds.length} fichiers récupérés avec succès',
    );

    return results;
  }

  /// Vide le cache des métadonnées
  void clearFileMetadataCache() {
    _fileMetadataCache.clear();
    debugPrint('🗑️ Cache des métadonnées vidé');
  }

  /// Précharge les métadonnées des fichiers
  /// NOUVELLE MÉTHODE: Utile pour charger toutes les métadonnées en une fois
  Future<void> preloadFileMetadata() async {
    try {
      debugPrint('⏳ Préchargement des métadonnées de tous les fichiers...');
      final files = await listFiles();

      for (final f in files) {
        if (f is Map) {
          final Map<String, dynamic> m = Map<String, dynamic>.from(f);
          final fileId = m['\$id'] ?? m['id'] ?? m['fileId'];

          if (fileId != null) {
            final metadata = {
              'id': fileId,
              'name':
                  m['name'] ??
                  m['\$name'] ??
                  m['fileName'] ??
                  m['filename'] ??
                  'Document',
              'mimeType': m['mimeType'] ?? m['contentType'] ?? m['type'],
              'size':
                  m['sizeOriginal'] ?? m['size'] ?? m['\$size'] ?? m['bytes'],
              'createdAt': m['\$createdAt'] ?? m['createdAt'],
              'updatedAt': m['\$updatedAt'] ?? m['updatedAt'],
            };

            _fileMetadataCache[fileId.toString()] = metadata;
          }
        }
      }

      debugPrint('✅ ${_fileMetadataCache.length} fichiers préchargés en cache');
    } catch (e) {
      debugPrint('❌ Erreur lors du préchargement: $e');
    }
  }
}
