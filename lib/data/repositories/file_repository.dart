import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import '../../core/constants/appwrite_constants.dart';
import '../../core/services/appwrite_service.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/utils/logger.dart';
import '../../core/enums/source_type_enum.dart';
import '../models/file_model.dart';

class FileRepository {
  final AppwriteService _appwriteService = Get.find();
  final CacheService _cacheService = Get.find();
  final ConnectivityService _connectivityService = Get.find();

  /// Génère la clé de cache pour un parent
  String _getCacheKey(String parentType, String parentId) {
    return '${AppwriteConstants.cacheKeyFichiers}${parentType}_$parentId';
  }

  /// Récupère tous les fichiers d'un parent (UE ou Concours)
  Future<List<FileModel>> getFilesByParent(
    String parentType,
    String parentId, {
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = _getCacheKey(parentType, parentId);

      // Vérifie le cache si pas de forceRefresh
      if (!forceRefresh) {
        final cachedData = _cacheService.getList(cacheKey);
        if (cachedData != null) {
          AppLogger.info(
            'Fichiers chargés depuis le cache pour $parentType: $parentId',
          );
          return cachedData.map((json) => FileModel.fromJson(json)).toList();
        }
      }

      // Vérifie la connexion
      if (!_connectivityService.isConnected.value) {
        AppLogger.warning('Pas de connexion - tentative cache');
        final cachedData = _cacheService.getList(cacheKey);
        if (cachedData != null) {
          return cachedData.map((json) => FileModel.fromJson(json)).toList();
        }
        throw Exception('Pas de connexion internet et pas de cache disponible');
      }

      // Récupère depuis Appwrite
      final queries = [
        Query.equal('parentType', parentType),
        Query.equal('parentId', parentId),
        Query.equal('isActive', true),
        Query.orderDesc('annee'),
        Query.orderAsc('nom'),
        Query.limit(AppwriteConstants.maxLimit),
      ];

      final documents = await _appwriteService.listDocuments(
        collectionId: AppwriteConstants.fichiersCollectionId,
        queries: queries,
      );

      final files = documents.map((doc) => FileModel.fromJson(doc)).toList();

      // Sauvegarde dans le cache
      await _cacheService.putList(
        key: cacheKey,
        list: documents,
        expiration: AppwriteConstants.cacheDuration,
      );

      AppLogger.info(
        '${files.length} fichiers chargés pour $parentType: $parentId',
      );
      return files;
    } catch (e) {
      AppLogger.error('Erreur getFilesByParent', e);
      rethrow;
    }
  }

  /// Récupère tous les fichiers d'une UE
  Future<List<FileModel>> getFilesByUe(
    String ueId, {
    bool forceRefresh = false,
  }) async {
    return await getFilesByParent('ue', ueId, forceRefresh: forceRefresh);
  }

  /// Récupère tous les fichiers d'un concours
  Future<List<FileModel>> getFilesByConcours(
    String concoursId, {
    bool forceRefresh = false,
  }) async {
    return await getFilesByParent(
      'concours',
      concoursId,
      forceRefresh: forceRefresh,
    );
  }

  /// Récupère un fichier par son ID
  Future<FileModel?> getFileById(String id, {bool forceRefresh = false}) async {
    try {
      // Vérifie la connexion
      if (!_connectivityService.isConnected.value && !forceRefresh) {
        throw Exception('Pas de connexion internet');
      }

      // Récupère depuis Appwrite
      final document = await _appwriteService.getDocument(
        collectionId: AppwriteConstants.fichiersCollectionId,
        documentId: id,
      );

      return FileModel.fromJson(document);
    } catch (e) {
      AppLogger.error('Erreur getFileById', e);
      return null;
    }
  }

  /// Récupère les fichiers par type
  Future<List<FileModel>> getFilesByType(
    String parentType,
    String parentId,
    String type, {
    bool forceRefresh = false,
  }) async {
    try {
      final files = await getFilesByParent(
        parentType,
        parentId,
        forceRefresh: forceRefresh,
      );
      return files.where((f) => f.type == type).toList();
    } catch (e) {
      AppLogger.error('Erreur getFilesByType', e);
      rethrow;
    }
  }

  /// Récupère les ressources d'une UE
  Future<List<FileModel>> getRessourcesByUe(
    String ueId, {
    bool forceRefresh = false,
  }) async {
    return await getFilesByType(
      'ue',
      ueId,
      'ressource',
      forceRefresh: forceRefresh,
    );
  }

  /// Récupère les devoirs d'une UE
  Future<List<FileModel>> getDevoirsByUe(
    String ueId, {
    bool forceRefresh = false,
  }) async {
    return await getFilesByType(
      'ue',
      ueId,
      'devoir',
      forceRefresh: forceRefresh,
    );
  }

  /// Récupère les épreuves d'un concours
  Future<List<FileModel>> getEpreuvesByConcours(
    String concoursId, {
    bool forceRefresh = false,
  }) async {
    return await getFilesByType(
      'concours',
      concoursId,
      'epreuve',
      forceRefresh: forceRefresh,
    );
  }

  /// Récupère les communiqués d'un concours
  Future<List<FileModel>> getCommuniquesByConcours(
    String concoursId, {
    bool forceRefresh = false,
  }) async {
    return await getFilesByType(
      'concours',
      concoursId,
      'communique',
      forceRefresh: forceRefresh,
    );
  }

  /// Récupère les fichiers par année
  Future<List<FileModel>> getFilesByAnnee(
    String parentType,
    String parentId,
    String annee, {
    bool forceRefresh = false,
  }) async {
    try {
      final files = await getFilesByParent(
        parentType,
        parentId,
        forceRefresh: forceRefresh,
      );
      return files.where((f) => f.annee == annee).toList();
    } catch (e) {
      AppLogger.error('Erreur getFilesByAnnee', e);
      rethrow;
    }
  }

  /// Récupère les fichiers par source
  Future<List<FileModel>> getFilesBySource(
    String parentType,
    String parentId,
    SourceTypeEnum sourceType, {
    bool forceRefresh = false,
  }) async {
    try {
      final files = await getFilesByParent(
        parentType,
        parentId,
        forceRefresh: forceRefresh,
      );
      return files.where((f) => f.sourceType == sourceType).toList();
    } catch (e) {
      AppLogger.error('Erreur getFilesBySource', e);
      rethrow;
    }
  }

  /// Groupe les fichiers par type
  Future<Map<String, List<FileModel>>> groupFilesByType(
    String parentType,
    String parentId, {
    bool forceRefresh = false,
  }) async {
    try {
      final files = await getFilesByParent(
        parentType,
        parentId,
        forceRefresh: forceRefresh,
      );
      final Map<String, List<FileModel>> grouped = {};

      for (final file in files) {
        if (!grouped.containsKey(file.type)) {
          grouped[file.type] = [];
        }
        grouped[file.type]!.add(file);
      }

      return grouped;
    } catch (e) {
      AppLogger.error('Erreur groupFilesByType', e);
      return {};
    }
  }

  /// Groupe les fichiers par année
  Future<Map<String?, List<FileModel>>> groupFilesByAnnee(
    String parentType,
    String parentId, {
    bool forceRefresh = false,
  }) async {
    try {
      final files = await getFilesByParent(
        parentType,
        parentId,
        forceRefresh: forceRefresh,
      );
      final Map<String?, List<FileModel>> grouped = {};

      for (final file in files) {
        if (!grouped.containsKey(file.annee)) {
          grouped[file.annee] = [];
        }
        grouped[file.annee]!.add(file);
      }

      return grouped;
    } catch (e) {
      AppLogger.error('Erreur groupFilesByAnnee', e);
      return {};
    }
  }

  /// Recherche de fichiers
  Future<List<FileModel>> searchFiles(
    String parentType,
    String parentId,
    String query,
  ) async {
    try {
      final files = await getFilesByParent(parentType, parentId);
      final lowerQuery = query.toLowerCase();

      return files.where((file) {
        return file.nom.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      AppLogger.error('Erreur searchFiles', e);
      rethrow;
    }
  }

  /// Compte le nombre de fichiers par parent
  Future<int> countFilesByParent(String parentType, String parentId) async {
    try {
      final files = await getFilesByParent(parentType, parentId);
      return files.length;
    } catch (e) {
      AppLogger.error('Erreur countFilesByParent', e);
      return 0;
    }
  }

  /// Compte les fichiers par type
  Future<Map<String, int>> countByType(
    String parentType,
    String parentId,
  ) async {
    try {
      final grouped = await groupFilesByType(parentType, parentId);
      return grouped.map((type, files) => MapEntry(type, files.length));
    } catch (e) {
      AppLogger.error('Erreur countByType', e);
      return {};
    }
  }

  /// Récupère l'URL de téléchargement d'un fichier Appwrite
  String getDownloadUrl(FileModel file) {
    if (file.sourceType == SourceTypeEnum.appwrite) {
      return _appwriteService.getFileDownload(
        bucketId: AppwriteConstants.documentsBucketId,
        fileId: file.fileId,
      );
    }
    return file
        .fileId; // Pour Google Drive et liens externes, fileId contient l'URL
  }

  /// Récupère l'URL de prévisualisation d'un fichier Appwrite
  String? getPreviewUrl(FileModel file) {
    if (file.sourceType == SourceTypeEnum.appwrite && file.isPdf) {
      return _appwriteService.getFileView(
        bucketId: AppwriteConstants.documentsBucketId,
        fileId: file.fileId,
      );
    }
    return null;
  }

  /// Vide le cache des fichiers d'un parent
  Future<void> clearCache(String parentType, String parentId) async {
    try {
      final cacheKey = _getCacheKey(parentType, parentId);
      await _cacheService.delete(cacheKey);
      AppLogger.info('Cache fichiers vidé pour $parentType: $parentId');
    } catch (e) {
      AppLogger.error('Erreur clearCache', e);
    }
  }

  /// Vide tout le cache des fichiers
  Future<void> clearAllCache() async {
    try {
      await _cacheService.deleteByPrefix(AppwriteConstants.cacheKeyFichiers);
      AppLogger.info('Tout le cache fichiers vidé');
    } catch (e) {
      AppLogger.error('Erreur clearAllCache', e);
    }
  }

  /// Force le rafraîchissement des données
  Future<List<FileModel>> refresh(String parentType, String parentId) async {
    await clearCache(parentType, parentId);
    return await getFilesByParent(parentType, parentId, forceRefresh: true);
  }
}
