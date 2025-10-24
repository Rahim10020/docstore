import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import '../../core/constants/appwrite_constants.dart';
import '../../core/services/appwrite_service.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/utils/logger.dart';
import '../models/ecole_model.dart';

class EcoleRepository {
  final AppwriteService _appwriteService = Get.find();
  final CacheService _cacheService = Get.find();
  final ConnectivityService _connectivityService = Get.find();

  /// Récupère tous les établissements
  Future<List<EcoleModel>> getAllEcoles({bool forceRefresh = false}) async {
    try {
      // Vérifie le cache si pas de forceRefresh
      if (!forceRefresh) {
        final cachedData = _cacheService.getList(
          AppwriteConstants.cacheKeyEcoles,
        );
        if (cachedData != null) {
          AppLogger.info('Écoles chargées depuis le cache');
          return cachedData.map((json) => EcoleModel.fromJson(json)).toList();
        }
      }

      // Vérifie la connexion
      if (!_connectivityService.isConnected.value) {
        AppLogger.warning('Pas de connexion - tentative cache');
        final cachedData = _cacheService.getList(
          AppwriteConstants.cacheKeyEcoles,
        );
        if (cachedData != null) {
          return cachedData.map((json) => EcoleModel.fromJson(json)).toList();
        }
        throw Exception('Pas de connexion internet et pas de cache disponible');
      }

      // Récupère depuis Appwrite
      final queries = [
        Query.equal('isActive', true),
        Query.orderAsc('ordre'),
        Query.orderAsc('nom'),
        Query.limit(AppwriteConstants.maxLimit),
      ];

      final documents = await _appwriteService.listDocuments(
        collectionId: AppwriteConstants.ecolesCollectionId,
        queries: queries,
      );

      final ecoles = documents.map((doc) => EcoleModel.fromJson(doc)).toList();

      // Sauvegarde dans le cache
      await _cacheService.putList(
        key: AppwriteConstants.cacheKeyEcoles,
        list: documents,
        expiration: AppwriteConstants.cacheDuration,
      );

      AppLogger.info('${ecoles.length} écoles chargées depuis Appwrite');
      return ecoles;
    } catch (e) {
      AppLogger.error('Erreur getAllEcoles', e);
      rethrow;
    }
  }

  /// Récupère les établissements par type
  Future<List<EcoleModel>> getEcolesByType(
    String type, {
    bool forceRefresh = false,
  }) async {
    try {
      final allEcoles = await getAllEcoles(forceRefresh: forceRefresh);
      return allEcoles.where((ecole) => ecole.type.name == type).toList();
    } catch (e) {
      AppLogger.error('Erreur getEcolesByType', e);
      rethrow;
    }
  }

  /// Récupère un établissement par son ID
  Future<EcoleModel?> getEcoleById(
    String id, {
    bool forceRefresh = false,
  }) async {
    try {
      // Tente de trouver dans le cache d'abord
      if (!forceRefresh) {
        final allEcoles = await getAllEcoles(forceRefresh: false);
        try {
          return allEcoles.firstWhere((ecole) => ecole.id == id);
        } catch (e) {
          // Pas trouvé dans le cache, continue
        }
      }

      // Vérifie la connexion
      if (!_connectivityService.isConnected.value) {
        throw Exception('Pas de connexion internet');
      }

      // Récupère depuis Appwrite
      final document = await _appwriteService.getDocument(
        collectionId: AppwriteConstants.ecolesCollectionId,
        documentId: id,
      );

      return EcoleModel.fromJson(document);
    } catch (e) {
      AppLogger.error('Erreur getEcoleById', e);
      return null;
    }
  }

  /// Récupère les écoles (avec concours et devoirs)
  Future<List<EcoleModel>> getEcoles({bool forceRefresh = false}) async {
    try {
      final allEcoles = await getAllEcoles(forceRefresh: forceRefresh);
      return allEcoles.where((ecole) => ecole.type.name == 'ecole').toList();
    } catch (e) {
      AppLogger.error('Erreur getEcoles', e);
      rethrow;
    }
  }

  /// Récupère les facultés (sans concours ni devoirs)
  Future<List<EcoleModel>> getFacultes({bool forceRefresh = false}) async {
    try {
      final allEcoles = await getAllEcoles(forceRefresh: forceRefresh);
      return allEcoles.where((ecole) => ecole.type.name == 'faculte').toList();
    } catch (e) {
      AppLogger.error('Erreur getFacultes', e);
      rethrow;
    }
  }

  /// Récupère les instituts (avec concours, sans devoirs)
  Future<List<EcoleModel>> getInstituts({bool forceRefresh = false}) async {
    try {
      final allEcoles = await getAllEcoles(forceRefresh: forceRefresh);
      return allEcoles.where((ecole) => ecole.type.name == 'institut').toList();
    } catch (e) {
      AppLogger.error('Erreur getInstituts', e);
      rethrow;
    }
  }

  /// Récupère les établissements avec concours
  Future<List<EcoleModel>> getEcolesAvecConcours({
    bool forceRefresh = false,
  }) async {
    try {
      final allEcoles = await getAllEcoles(forceRefresh: forceRefresh);
      return allEcoles.where((ecole) => ecole.hasConcours).toList();
    } catch (e) {
      AppLogger.error('Erreur getEcolesAvecConcours', e);
      rethrow;
    }
  }

  /// Recherche d'établissements
  Future<List<EcoleModel>> searchEcoles(String query) async {
    try {
      final allEcoles = await getAllEcoles();
      final lowerQuery = query.toLowerCase();

      return allEcoles.where((ecole) {
        return ecole.nom.toLowerCase().contains(lowerQuery) ||
            ecole.nomComplet.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      AppLogger.error('Erreur searchEcoles', e);
      rethrow;
    }
  }

  /// Compte le nombre d'établissements par type
  Future<Map<String, int>> countByType() async {
    try {
      final allEcoles = await getAllEcoles();

      return {
        'ecole': allEcoles.where((e) => e.type.name == 'ecole').length,
        'faculte': allEcoles.where((e) => e.type.name == 'faculte').length,
        'institut': allEcoles.where((e) => e.type.name == 'institut').length,
      };
    } catch (e) {
      AppLogger.error('Erreur countByType', e);
      return {'ecole': 0, 'faculte': 0, 'institut': 0};
    }
  }

  /// Vide le cache des écoles
  Future<void> clearCache() async {
    try {
      await _cacheService.delete(AppwriteConstants.cacheKeyEcoles);
      AppLogger.info('Cache écoles vidé');
    } catch (e) {
      AppLogger.error('Erreur clearCache', e);
    }
  }

  /// Force le rafraîchissement des données
  Future<List<EcoleModel>> refresh() async {
    await clearCache();
    return await getAllEcoles(forceRefresh: true);
  }
}
