import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import '../../core/constants/appwrite_constants.dart';
import '../../core/services/appwrite_service.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/utils/logger.dart';
import '../../core/enums/annee_enum.dart';
import '../../core/enums/semestre_enum.dart';
import '../models/ue_model.dart';

class UeRepository {
  final AppwriteService _appwriteService = Get.find();
  final CacheService _cacheService = Get.find();
  final ConnectivityService _connectivityService = Get.find();

  /// Génère la clé de cache pour une filière
  String _getCacheKey(String idFiliere) {
    return '${AppwriteConstants.cacheKeyUes}$idFiliere';
  }

  /// Récupère toutes les UEs d'une filière
  Future<List<UeModel>> getUesByFiliere(
    String idFiliere, {
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = _getCacheKey(idFiliere);

      // Vérifie le cache si pas de forceRefresh
      if (!forceRefresh) {
        final cachedData = _cacheService.getList(cacheKey);
        if (cachedData != null) {
          AppLogger.info(
            'UEs chargées depuis le cache pour filière: $idFiliere',
          );
          return cachedData.map((json) => UeModel.fromJson(json)).toList();
        }
      }

      // Vérifie la connexion
      if (!_connectivityService.isConnected.value) {
        AppLogger.warning('Pas de connexion - tentative cache');
        final cachedData = _cacheService.getList(cacheKey);
        if (cachedData != null) {
          return cachedData.map((json) => UeModel.fromJson(json)).toList();
        }
        throw Exception('Pas de connexion internet et pas de cache disponible');
      }

      // Récupère depuis Appwrite
      final queries = [
        Query.equal('idFiliere', idFiliere),
        Query.equal('isActive', true),
        Query.orderAsc('ordre'),
        Query.orderAsc('code'),
        Query.limit(AppwriteConstants.maxLimit),
      ];

      final documents = await _appwriteService.listDocuments(
        collectionId: AppwriteConstants.uesCollectionId,
        queries: queries,
      );

      final ues = documents.map((doc) => UeModel.fromJson(doc)).toList();

      // Sauvegarde dans le cache
      await _cacheService.putList(
        key: cacheKey,
        list: documents,
        expiration: AppwriteConstants.cacheDuration,
      );

      AppLogger.info('${ues.length} UEs chargées pour filière: $idFiliere');
      return ues;
    } catch (e) {
      AppLogger.error('Erreur getUesByFiliere', e);
      rethrow;
    }
  }

  /// Récupère une UE par son ID
  Future<UeModel?> getUeById(String id, {bool forceRefresh = false}) async {
    try {
      // Vérifie la connexion
      if (!_connectivityService.isConnected.value && !forceRefresh) {
        throw Exception('Pas de connexion internet');
      }

      // Récupère depuis Appwrite
      final document = await _appwriteService.getDocument(
        collectionId: AppwriteConstants.uesCollectionId,
        documentId: id,
      );

      return UeModel.fromJson(document);
    } catch (e) {
      AppLogger.error('Erreur getUeById', e);
      return null;
    }
  }

  /// Récupère les UEs par année
  Future<List<UeModel>> getUesByAnnee(
    String idFiliere,
    AnneeEnum annee, {
    bool forceRefresh = false,
  }) async {
    try {
      final ues = await getUesByFiliere(idFiliere, forceRefresh: forceRefresh);
      return ues.where((ue) => ue.annee == annee).toList();
    } catch (e) {
      AppLogger.error('Erreur getUesByAnnee', e);
      rethrow;
    }
  }

  /// Récupère les UEs par semestre
  Future<List<UeModel>> getUesBySemestre(
    String idFiliere,
    SemestreEnum semestre, {
    bool forceRefresh = false,
  }) async {
    try {
      final ues = await getUesByFiliere(idFiliere, forceRefresh: forceRefresh);
      return ues.where((ue) => ue.semestre == semestre).toList();
    } catch (e) {
      AppLogger.error('Erreur getUesBySemestre', e);
      rethrow;
    }
  }

  /// Récupère les UEs par année et semestre
  Future<List<UeModel>> getUesByAnneeAndSemestre(
    String idFiliere,
    AnneeEnum annee,
    SemestreEnum? semestre, {
    bool forceRefresh = false,
  }) async {
    try {
      final ues = await getUesByFiliere(idFiliere, forceRefresh: forceRefresh);
      return ues.where((ue) {
        if (semestre == null) {
          return ue.annee == annee;
        }
        return ue.annee == annee && ue.semestre == semestre;
      }).toList();
    } catch (e) {
      AppLogger.error('Erreur getUesByAnneeAndSemestre', e);
      rethrow;
    }
  }

  /// Groupe les UEs par année
  Future<Map<AnneeEnum, List<UeModel>>> groupUesByAnnee(
    String idFiliere, {
    bool forceRefresh = false,
  }) async {
    try {
      final ues = await getUesByFiliere(idFiliere, forceRefresh: forceRefresh);
      final Map<AnneeEnum, List<UeModel>> grouped = {};

      for (final ue in ues) {
        if (!grouped.containsKey(ue.annee)) {
          grouped[ue.annee] = [];
        }
        grouped[ue.annee]!.add(ue);
      }

      return grouped;
    } catch (e) {
      AppLogger.error('Erreur groupUesByAnnee', e);
      return {};
    }
  }

  /// Groupe les UEs par semestre pour une année donnée
  Future<Map<SemestreEnum?, List<UeModel>>> groupUesBySemestre(
    String idFiliere,
    AnneeEnum annee, {
    bool forceRefresh = false,
  }) async {
    try {
      final ues = await getUesByAnnee(
        idFiliere,
        annee,
        forceRefresh: forceRefresh,
      );
      final Map<SemestreEnum?, List<UeModel>> grouped = {};

      for (final ue in ues) {
        if (!grouped.containsKey(ue.semestre)) {
          grouped[ue.semestre] = [];
        }
        grouped[ue.semestre]!.add(ue);
      }

      return grouped;
    } catch (e) {
      AppLogger.error('Erreur groupUesBySemestre', e);
      return {};
    }
  }

  /// Recherche d'UEs dans une filière
  Future<List<UeModel>> searchUes(String idFiliere, String query) async {
    try {
      final ues = await getUesByFiliere(idFiliere);
      final lowerQuery = query.toLowerCase();

      return ues.where((ue) {
        return ue.code.toLowerCase().contains(lowerQuery) ||
            ue.nom.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      AppLogger.error('Erreur searchUes', e);
      rethrow;
    }
  }

  /// Compte le nombre d'UEs par filière
  Future<int> countUesByFiliere(String idFiliere) async {
    try {
      final ues = await getUesByFiliere(idFiliere);
      return ues.length;
    } catch (e) {
      AppLogger.error('Erreur countUesByFiliere', e);
      return 0;
    }
  }

  /// Compte les UEs par année pour une filière
  Future<Map<AnneeEnum, int>> countByAnnee(String idFiliere) async {
    try {
      final grouped = await groupUesByAnnee(idFiliere);
      return grouped.map((annee, ues) => MapEntry(annee, ues.length));
    } catch (e) {
      AppLogger.error('Erreur countByAnnee', e);
      return {};
    }
  }

  /// Calcule le total de crédits pour une année
  Future<int> getTotalCredits(String idFiliere, AnneeEnum annee) async {
    try {
      final ues = await getUesByAnnee(idFiliere, annee);
      return ues.fold(0, (sum, ue) => sum + (ue.credits ?? 0));
    } catch (e) {
      AppLogger.error('Erreur getTotalCredits', e);
      return 0;
    }
  }

  /// Vide le cache des UEs d'une filière
  Future<void> clearCache(String idFiliere) async {
    try {
      final cacheKey = _getCacheKey(idFiliere);
      await _cacheService.delete(cacheKey);
      AppLogger.info('Cache UEs vidé pour filière: $idFiliere');
    } catch (e) {
      AppLogger.error('Erreur clearCache', e);
    }
  }

  /// Vide tout le cache des UEs
  Future<void> clearAllCache() async {
    try {
      await _cacheService.deleteByPrefix(AppwriteConstants.cacheKeyUes);
      AppLogger.info('Tout le cache UEs vidé');
    } catch (e) {
      AppLogger.error('Erreur clearAllCache', e);
    }
  }

  /// Force le rafraîchissement des données
  Future<List<UeModel>> refresh(String idFiliere) async {
    await clearCache(idFiliere);
    return await getUesByFiliere(idFiliere, forceRefresh: true);
  }
}
