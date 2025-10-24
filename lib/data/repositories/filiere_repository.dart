import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import '../../core/constants/appwrite_constants.dart';
import '../../core/services/appwrite_service.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/utils/logger.dart';
import '../models/filiere_model.dart';

class FiliereRepository {
  final AppwriteService _appwriteService = Get.find();
  final CacheService _cacheService = Get.find();
  final ConnectivityService _connectivityService = Get.find();

  /// Génère la clé de cache pour une école
  String _getCacheKey(String idEcole) {
    return '${AppwriteConstants.cacheKeyFilieres}$idEcole';
  }

  /// Récupère toutes les filières d'un établissement
  Future<List<FiliereModel>> getFilieresByEcole(
    String idEcole, {
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = _getCacheKey(idEcole);

      // Vérifie le cache si pas de forceRefresh
      if (!forceRefresh) {
        final cachedData = _cacheService.getList(cacheKey);
        if (cachedData != null) {
          AppLogger.info(
            'Filières chargées depuis le cache pour école: $idEcole',
          );
          return cachedData.map((json) => FiliereModel.fromJson(json)).toList();
        }
      }

      // Vérifie la connexion
      if (!_connectivityService.isConnected.value) {
        AppLogger.warning('Pas de connexion - tentative cache');
        final cachedData = _cacheService.getList(cacheKey);
        if (cachedData != null) {
          return cachedData.map((json) => FiliereModel.fromJson(json)).toList();
        }
        throw Exception('Pas de connexion internet et pas de cache disponible');
      }

      // Récupère depuis Appwrite
      final queries = [
        Query.equal('idEcole', idEcole),
        Query.equal('isActive', true),
        Query.orderAsc('ordre'),
        Query.orderAsc('nom'),
        Query.limit(AppwriteConstants.maxLimit),
      ];

      final documents = await _appwriteService.listDocuments(
        collectionId: AppwriteConstants.filieresCollectionId,
        queries: queries,
      );

      final filieres = documents
          .map((doc) => FiliereModel.fromJson(doc))
          .toList();

      // Sauvegarde dans le cache
      await _cacheService.putList(
        key: cacheKey,
        list: documents,
        expiration: AppwriteConstants.cacheDuration,
      );

      AppLogger.info(
        '${filieres.length} filières chargées pour école: $idEcole',
      );
      return filieres;
    } catch (e) {
      AppLogger.error('Erreur getFilieresByEcole', e);
      rethrow;
    }
  }

  /// Récupère une filière par son ID
  Future<FiliereModel?> getFiliereById(
    String id, {
    bool forceRefresh = false,
  }) async {
    try {
      // Vérifie la connexion
      if (!_connectivityService.isConnected.value && !forceRefresh) {
        throw Exception('Pas de connexion internet');
      }

      // Récupère depuis Appwrite
      final document = await _appwriteService.getDocument(
        collectionId: AppwriteConstants.filieresCollectionId,
        documentId: id,
      );

      return FiliereModel.fromJson(document);
    } catch (e) {
      AppLogger.error('Erreur getFiliereById', e);
      return null;
    }
  }

  /// Récupère les départements d'un établissement
  Future<List<FiliereModel>> getDepartementsByEcole(
    String idEcole, {
    bool forceRefresh = false,
  }) async {
    try {
      final filieres = await getFilieresByEcole(
        idEcole,
        forceRefresh: forceRefresh,
      );
      return filieres.where((f) => f.typeFiliere == 'departement').toList();
    } catch (e) {
      AppLogger.error('Erreur getDepartementsByEcole', e);
      rethrow;
    }
  }

  /// Récupère les parcours d'un établissement
  Future<List<FiliereModel>> getParcoursByEcole(
    String idEcole, {
    bool forceRefresh = false,
  }) async {
    try {
      final filieres = await getFilieresByEcole(
        idEcole,
        forceRefresh: forceRefresh,
      );
      return filieres.where((f) => f.typeFiliere == 'parcours').toList();
    } catch (e) {
      AppLogger.error('Erreur getParcoursByEcole', e);
      rethrow;
    }
  }

  /// Récupère les filières par type de licence
  Future<List<FiliereModel>> getFilieresByTypeLicence(
    String idEcole,
    String typeLicence, {
    bool forceRefresh = false,
  }) async {
    try {
      final filieres = await getFilieresByEcole(
        idEcole,
        forceRefresh: forceRefresh,
      );
      return filieres.where((f) => f.typeLicence.label == typeLicence).toList();
    } catch (e) {
      AppLogger.error('Erreur getFilieresByTypeLicence', e);
      rethrow;
    }
  }

  /// Recherche de filières pour un établissement
  Future<List<FiliereModel>> searchFilieres(
    String idEcole,
    String query,
  ) async {
    try {
      final filieres = await getFilieresByEcole(idEcole);
      final lowerQuery = query.toLowerCase();

      return filieres.where((filiere) {
        return filiere.nom.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      AppLogger.error('Erreur searchFilieres', e);
      rethrow;
    }
  }

  /// Compte le nombre de filières par établissement
  Future<int> countFilieresByEcole(String idEcole) async {
    try {
      final filieres = await getFilieresByEcole(idEcole);
      return filieres.length;
    } catch (e) {
      AppLogger.error('Erreur countFilieresByEcole', e);
      return 0;
    }
  }

  /// Compte les filières par type pour un établissement
  Future<Map<String, int>> countByType(String idEcole) async {
    try {
      final filieres = await getFilieresByEcole(idEcole);

      return {
        'departement': filieres
            .where((f) => f.typeFiliere == 'departement')
            .length,
        'parcours': filieres.where((f) => f.typeFiliere == 'parcours').length,
      };
    } catch (e) {
      AppLogger.error('Erreur countByType', e);
      return {'departement': 0, 'parcours': 0};
    }
  }

  /// Vide le cache des filières d'un établissement
  Future<void> clearCache(String idEcole) async {
    try {
      final cacheKey = _getCacheKey(idEcole);
      await _cacheService.delete(cacheKey);
      AppLogger.info('Cache filières vidé pour école: $idEcole');
    } catch (e) {
      AppLogger.error('Erreur clearCache', e);
    }
  }

  /// Vide tout le cache des filières
  Future<void> clearAllCache() async {
    try {
      await _cacheService.deleteByPrefix(AppwriteConstants.cacheKeyFilieres);
      AppLogger.info('Tout le cache filières vidé');
    } catch (e) {
      AppLogger.error('Erreur clearAllCache', e);
    }
  }

  /// Force le rafraîchissement des données
  Future<List<FiliereModel>> refresh(String idEcole) async {
    await clearCache(idEcole);
    return await getFilieresByEcole(idEcole, forceRefresh: true);
  }
}
