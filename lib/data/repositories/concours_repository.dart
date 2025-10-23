// ===== data/repositories/concours_repository.dart =====
import 'package:appwrite/appwrite.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/appwrite_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/errors/exceptions.dart';
import '../models/concours_model.dart';

class ConcoursRepository {
  final AppwriteService _appwriteService;
  final StorageService _storageService;
  final ConnectivityService _connectivityService;

  ConcoursRepository(
    this._appwriteService,
    this._storageService,
    this._connectivityService,
  );

  // Récupérer tous les concours (cache plus court : 12h)
  Future<List<ConcoursModel>> getAllConcours({
    bool forceRefresh = false,
  }) async {
    try {
      final cacheExpired = _storageService.isCacheExpired(
        'concours',
        ApiConstants.concoursExpirationHours,
      );

      if (!forceRefresh && !cacheExpired) {
        final cachedData = _storageService.getConcours();
        if (cachedData.isNotEmpty) {
          return cachedData.map((e) => ConcoursModel.fromMap(e)).toList();
        }
      }

      final isConnected = await _connectivityService.checkConnection();
      if (!isConnected) {
        final cachedData = _storageService.getConcours();
        if (cachedData.isNotEmpty) {
          return cachedData.map((e) => ConcoursModel.fromMap(e)).toList();
        }
        throw NetworkException('Aucune connexion Internet et pas de cache');
      }

      final response = await _appwriteService.databases.listDocuments(
        databaseId: ApiConstants.databaseId,
        collectionId: ApiConstants.concoursCollectionId,
        queries: [Query.limit(ApiConstants.maxLimit), Query.orderDesc('annee')],
      );

      final concours = response.documents
          .map((doc) => ConcoursModel.fromJson(doc.data))
          .toList();

      await _storageService.saveConcours(
        concours.map((c) => c.toMap()).toList(),
      );

      return concours;
    } on AppwriteException catch (e) {
      throw ServerException(_appwriteService.handleAppwriteError(e));
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // Récupérer les concours d'une école
  Future<List<ConcoursModel>> getConcoursByEcole(String ecoleId) async {
    try {
      final isConnected = await _connectivityService.checkConnection();

      if (!isConnected) {
        final cachedData = _storageService.getConcours();
        final filtered = cachedData
            .where((c) => c['idEcole'] == ecoleId)
            .toList();
        return filtered.map((e) => ConcoursModel.fromMap(e)).toList();
      }

      final response = await _appwriteService.databases.listDocuments(
        databaseId: ApiConstants.databaseId,
        collectionId: ApiConstants.concoursCollectionId,
        queries: [
          Query.equal('idEcole', ecoleId),
          Query.limit(ApiConstants.maxLimit),
          Query.orderDesc('annee'),
        ],
      );

      return response.documents
          .map((doc) => ConcoursModel.fromJson(doc.data))
          .toList();
    } on AppwriteException catch (e) {
      throw ServerException(_appwriteService.handleAppwriteError(e));
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // Filtrer par année
  Future<List<ConcoursModel>> getConcoursByYear(String annee) async {
    try {
      final isConnected = await _connectivityService.checkConnection();

      if (!isConnected) {
        final cachedData = _storageService.getConcours();
        final filtered = cachedData.where((c) => c['annee'] == annee).toList();
        return filtered.map((e) => ConcoursModel.fromMap(e)).toList();
      }

      final response = await _appwriteService.databases.listDocuments(
        databaseId: ApiConstants.databaseId,
        collectionId: ApiConstants.concoursCollectionId,
        queries: [
          Query.equal('annee', annee),
          Query.limit(ApiConstants.maxLimit),
        ],
      );

      return response.documents
          .map((doc) => ConcoursModel.fromJson(doc.data))
          .toList();
    } on AppwriteException catch (e) {
      throw ServerException(_appwriteService.handleAppwriteError(e));
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // Récupérer uniquement les concours actifs
  Future<List<ConcoursModel>> getActiveConcours() async {
    try {
      final allConcours = await getAllConcours();
      return allConcours.where((c) => c.isActive).toList();
    } catch (e) {
      rethrow;
    }
  }
}
