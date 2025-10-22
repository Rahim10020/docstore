import 'package:appwrite/appwrite.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/appwrite_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/errors/exceptions.dart';
import '../models/filiere_model.dart';

class FiliereRepository {
  final AppwriteService _appwriteService;
  final StorageService _storageService;
  final ConnectivityService _connectivityService;

  FiliereRepository(
    this._appwriteService,
    this._storageService,
    this._connectivityService,
  );

  // Récupérer toutes les filières d'une école
  Future<List<FiliereModel>> getFilieresByEcole(
    String ecoleId, {
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = 'filieres_$ecoleId';
      final cacheExpired = _storageService.isCacheExpired(
        cacheKey,
        ApiConstants.cacheExpirationHours,
      );

      // Cache valide
      if (!forceRefresh && !cacheExpired) {
        final cachedData = _storageService.getFilieresByEcole(ecoleId);
        if (cachedData != null && cachedData.isNotEmpty) {
          return cachedData.map((e) => FiliereModel.fromMap(e)).toList();
        }
      }

      // Vérifier connexion
      final isConnected = await _connectivityService.checkConnection();
      if (!isConnected) {
        final cachedData = _storageService.getFilieresByEcole(ecoleId);
        if (cachedData != null && cachedData.isNotEmpty) {
          return cachedData.map((e) => FiliereModel.fromMap(e)).toList();
        }
        throw NetworkException('Aucune connexion Internet et pas de cache');
      }

      // Récupérer depuis Appwrite
      final response = await _appwriteService.databases.listDocuments(
        databaseId: ApiConstants.databaseId,
        collectionId: ApiConstants.filieresCollectionId,
        queries: [
          Query.equal('idEcole', ecoleId),
          Query.limit(ApiConstants.maxLimit),
          Query.orderAsc('nom'),
        ],
      );

      final filieres = response.documents
          .map((doc) => FiliereModel.fromJson(doc.data))
          .toList();

      // Sauvegarder dans cache
      await _storageService.saveFilieres(
        ecoleId,
        filieres.map((f) => f.toMap()).toList(),
      );

      return filieres;
    } on AppwriteException catch (e) {
      throw ServerException(_appwriteService.handleAppwriteError(e));
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // Filtrer par parcours
  Future<List<FiliereModel>> getFilieresByParcours(
    String ecoleId,
    String parcours,
  ) async {
    try {
      final isConnected = await _connectivityService.checkConnection();

      if (!isConnected) {
        // Filtrer depuis cache
        final cachedData = _storageService.getFilieresByEcole(ecoleId);
        if (cachedData != null) {
          final filtered = cachedData
              .where((f) => f['parcours'] == parcours)
              .toList();
          return filtered.map((e) => FiliereModel.fromMap(e)).toList();
        }
        throw NetworkException('Aucune connexion Internet');
      }

      final response = await _appwriteService.databases.listDocuments(
        databaseId: ApiConstants.databaseId,
        collectionId: ApiConstants.filieresCollectionId,
        queries: [
          Query.equal('idEcole', ecoleId),
          Query.equal('parcours', parcours),
          Query.limit(ApiConstants.maxLimit),
        ],
      );

      return response.documents
          .map((doc) => FiliereModel.fromJson(doc.data))
          .toList();
    } on AppwriteException catch (e) {
      throw ServerException(_appwriteService.handleAppwriteError(e));
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // Rechercher des filières
  Future<List<FiliereModel>> searchFilieres(String query) async {
    try {
      final isConnected = await _connectivityService.checkConnection();
      if (!isConnected) {
        throw NetworkException('Recherche nécessite une connexion Internet');
      }

      final response = await _appwriteService.databases.listDocuments(
        databaseId: ApiConstants.databaseId,
        collectionId: ApiConstants.filieresCollectionId,
        queries: [
          Query.search('nom', query),
          Query.limit(ApiConstants.defaultLimit),
        ],
      );

      return response.documents
          .map((doc) => FiliereModel.fromJson(doc.data))
          .toList();
    } on AppwriteException catch (e) {
      throw ServerException(_appwriteService.handleAppwriteError(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
