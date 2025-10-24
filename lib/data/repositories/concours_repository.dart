import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import '../../core/constants/appwrite_constants.dart';
import '../../core/services/appwrite_service.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/utils/logger.dart';
import '../../core/enums/statut_concours.dart';
import '../models/concours_model.dart';

class ConcoursRepository {
  final AppwriteService _appwriteService = Get.find();
  final CacheService _cacheService = Get.find();
  final ConnectivityService _connectivityService = Get.find();

  /// Génère la clé de cache pour une école
  String _getCacheKey(String idEcole) {
    return '${AppwriteConstants.cacheKeyConcours}$idEcole';
  }

  /// Récupère tous les concours d'un établissement
  Future<List<ConcoursModel>> getConcoursByEcole(
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
            'Concours chargés depuis le cache pour école: $idEcole',
          );
          return cachedData
              .map((json) => ConcoursModel.fromJson(json))
              .toList();
        }
      }

      // Vérifie la connexion
      if (!_connectivityService.isConnected.value) {
        AppLogger.warning('Pas de connexion - tentative cache');
        final cachedData = _cacheService.getList(cacheKey);
        if (cachedData != null) {
          return cachedData
              .map((json) => ConcoursModel.fromJson(json))
              .toList();
        }
        throw Exception('Pas de connexion internet et pas de cache disponible');
      }

      // Récupère depuis Appwrite
      final queries = [
        Query.equal('idEcole', idEcole),
        Query.equal('isActive', true),
        Query.orderDesc('annee'),
        Query.orderAsc('ordre'),
        Query.limit(AppwriteConstants.maxLimit),
      ];

      final documents = await _appwriteService.listDocuments(
        collectionId: AppwriteConstants.concoursCollectionId,
        queries: queries,
      );

      final concours = documents
          .map((doc) => ConcoursModel.fromJson(doc))
          .toList();

      // Sauvegarde dans le cache
      await _cacheService.putList(
        key: cacheKey,
        list: documents,
        expiration: AppwriteConstants
            .shortCacheDuration, // Cache plus court pour concours
      );

      AppLogger.info(
        '${concours.length} concours chargés pour école: $idEcole',
      );
      return concours;
    } catch (e) {
      AppLogger.error('Erreur getConcoursByEcole', e);
      rethrow;
    }
  }

  /// Récupère tous les concours (toutes écoles)
  Future<List<ConcoursModel>> getAllConcours({
    bool forceRefresh = false,
  }) async {
    try {
      const cacheKey = '${AppwriteConstants.cacheKeyConcours}all';

      // Vérifie le cache si pas de forceRefresh
      if (!forceRefresh) {
        final cachedData = _cacheService.getList(cacheKey);
        if (cachedData != null) {
          AppLogger.info('Tous les concours chargés depuis le cache');
          return cachedData
              .map((json) => ConcoursModel.fromJson(json))
              .toList();
        }
      }

      // Vérifie la connexion
      if (!_connectivityService.isConnected.value) {
        throw Exception('Pas de connexion internet');
      }

      // Récupère depuis Appwrite
      final queries = [
        Query.equal('isActive', true),
        Query.orderDesc('annee'),
        Query.orderAsc('ordre'),
        Query.limit(AppwriteConstants.maxLimit),
      ];

      final documents = await _appwriteService.listDocuments(
        collectionId: AppwriteConstants.concoursCollectionId,
        queries: queries,
      );

      final concours = documents
          .map((doc) => ConcoursModel.fromJson(doc))
          .toList();

      // Sauvegarde dans le cache
      await _cacheService.putList(
        key: cacheKey,
        list: documents,
        expiration: AppwriteConstants.shortCacheDuration,
      );

      AppLogger.info('${concours.length} concours chargés au total');
      return concours;
    } catch (e) {
      AppLogger.error('Erreur getAllConcours', e);
      rethrow;
    }
  }

  /// Récupère un concours par son ID
  Future<ConcoursModel?> getConcoursById(
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
        collectionId: AppwriteConstants.concoursCollectionId,
        documentId: id,
      );

      return ConcoursModel.fromJson(document);
    } catch (e) {
      AppLogger.error('Erreur getConcoursById', e);
      return null;
    }
  }

  /// Récupère les concours par statut
  Future<List<ConcoursModel>> getConcoursByStatut(
    StatutConcours statut, {
    bool forceRefresh = false,
  }) async {
    try {
      final allConcours = await getAllConcours(forceRefresh: forceRefresh);
      return allConcours.where((c) => c.statut == statut).toList();
    } catch (e) {
      AppLogger.error('Erreur getConcoursByStatut', e);
      rethrow;
    }
  }

  /// Récupère les concours par année
  Future<List<ConcoursModel>> getConcoursByAnnee(
    String annee, {
    bool forceRefresh = false,
  }) async {
    try {
      final allConcours = await getAllConcours(forceRefresh: forceRefresh);
      return allConcours.where((c) => c.annee == annee).toList();
    } catch (e) {
      AppLogger.error('Erreur getConcoursByAnnee', e);
      rethrow;
    }
  }

  /// Récupère les concours en cours
  Future<List<ConcoursModel>> getConcoursEnCours({
    bool forceRefresh = false,
  }) async {
    try {
      return await getConcoursByStatut(
        StatutConcours.enCours,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      AppLogger.error('Erreur getConcoursEnCours', e);
      rethrow;
    }
  }

  /// Récupère les concours à venir
  Future<List<ConcoursModel>> getConcoursAVenir({
    bool forceRefresh = false,
  }) async {
    try {
      return await getConcoursByStatut(
        StatutConcours.aVenir,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      AppLogger.error('Erreur getConcoursAVenir', e);
      rethrow;
    }
  }

  /// Récupère les concours ouverts (en cours et pas encore expirés)
  Future<List<ConcoursModel>> getConcoursOuverts({
    bool forceRefresh = false,
  }) async {
    try {
      final concoursEnCours = await getConcoursEnCours(
        forceRefresh: forceRefresh,
      );
      return concoursEnCours.where((c) => c.isOpen).toList();
    } catch (e) {
      AppLogger.error('Erreur getConcoursOuverts', e);
      rethrow;
    }
  }

  /// Recherche de concours
  Future<List<ConcoursModel>> searchConcours(String query) async {
    try {
      final allConcours = await getAllConcours();
      final lowerQuery = query.toLowerCase();

      return allConcours.where((concours) {
        return concours.nom.toLowerCase().contains(lowerQuery) ||
            concours.annee.contains(query);
      }).toList();
    } catch (e) {
      AppLogger.error('Erreur searchConcours', e);
      rethrow;
    }
  }

  /// Compte le nombre de concours par école
  Future<int> countConcoursByEcole(String idEcole) async {
    try {
      final concours = await getConcoursByEcole(idEcole);
      return concours.length;
    } catch (e) {
      AppLogger.error('Erreur countConcoursByEcole', e);
      return 0;
    }
  }

  /// Compte les concours par statut
  Future<Map<StatutConcours, int>> countByStatut() async {
    try {
      final allConcours = await getAllConcours();

      return {
        StatutConcours.aVenir: allConcours
            .where((c) => c.statut == StatutConcours.aVenir)
            .length,
        StatutConcours.enCours: allConcours
            .where((c) => c.statut == StatutConcours.enCours)
            .length,
        StatutConcours.termine: allConcours
            .where((c) => c.statut == StatutConcours.termine)
            .length,
      };
    } catch (e) {
      AppLogger.error('Erreur countByStatut', e);
      return {
        StatutConcours.aVenir: 0,
        StatutConcours.enCours: 0,
        StatutConcours.termine: 0,
      };
    }
  }

  /// Groupe les concours par année
  Future<Map<String, List<ConcoursModel>>> groupConcoursByAnnee() async {
    try {
      final allConcours = await getAllConcours();
      final Map<String, List<ConcoursModel>> grouped = {};

      for (final concours in allConcours) {
        if (!grouped.containsKey(concours.annee)) {
          grouped[concours.annee] = [];
        }
        grouped[concours.annee]!.add(concours);
      }

      return grouped;
    } catch (e) {
      AppLogger.error('Erreur groupConcoursByAnnee', e);
      return {};
    }
  }

  /// Vide le cache des concours d'une école
  Future<void> clearCache(String idEcole) async {
    try {
      final cacheKey = _getCacheKey(idEcole);
      await _cacheService.delete(cacheKey);
      AppLogger.info('Cache concours vidé pour école: $idEcole');
    } catch (e) {
      AppLogger.error('Erreur clearCache', e);
    }
  }

  /// Vide tout le cache des concours
  Future<void> clearAllCache() async {
    try {
      await _cacheService.deleteByPrefix(AppwriteConstants.cacheKeyConcours);
      AppLogger.info('Tout le cache concours vidé');
    } catch (e) {
      AppLogger.error('Erreur clearAllCache', e);
    }
  }

  /// Force le rafraîchissement des données
  Future<List<ConcoursModel>> refresh(String idEcole) async {
    await clearCache(idEcole);
    return await getConcoursByEcole(idEcole, forceRefresh: true);
  }
}
