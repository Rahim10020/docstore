import 'package:appwrite/appwrite.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/appwrite_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/errors/exceptions.dart';
import '../models/ecole_model.dart';

class EcoleRepository {
  final AppwriteService _appwriteService;
  final StorageService _storageService;
  final ConnectivityService _connectivityService;

  EcoleRepository(
    this._appwriteService,
    this._storageService,
    this._connectivityService,
  );

  // Récupérer toutes les écoles (avec cache intelligent)
  Future<List<EcoleModel>> getAllEcoles({bool forceRefresh = false}) async {
    try {
      // Vérifier si cache existe et n'est pas expiré
      final cacheExpired = _storageService.isCacheExpired(
        'ecoles',
        ApiConstants.cacheExpirationHours,
      );

      // Si cache valide et pas de refresh forcé, retourner depuis cache
      if (!forceRefresh && !cacheExpired) {
        final cachedData = _storageService.getEcoles();
        if (cachedData.isNotEmpty) {
          return cachedData.map((e) => EcoleModel.fromMap(e)).toList();
        }
      }

      // Vérifier la connexion
      final isConnected = await _connectivityService.checkConnection();
      if (!isConnected) {
        // Mode offline : retourner cache même expiré
        final cachedData = _storageService.getEcoles();
        if (cachedData.isNotEmpty) {
          return cachedData.map((e) => EcoleModel.fromMap(e)).toList();
        }
        throw NetworkException(
          'Aucune connexion Internet et pas de cache disponible',
        );
      }

      // Récupérer depuis Appwrite
      final response = await _appwriteService.databases.listDocuments(
        databaseId: ApiConstants.databaseId,
        collectionId: ApiConstants.ecolesCollectionId,
        queries: [Query.limit(ApiConstants.maxLimit), Query.orderAsc('nom')],
      );

      final ecoles = response.documents
          .map((doc) => EcoleModel.fromJson(doc.data))
          .toList();

      // Sauvegarder dans le cache
      await _storageService.saveEcoles(ecoles.map((e) => e.toMap()).toList());

      return ecoles;
    } on AppwriteException catch (e) {
      throw ServerException(_appwriteService.handleAppwriteError(e));
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // Récupérer une école par ID
  Future<EcoleModel> getEcoleById(String id) async {
    try {
      // Essayer depuis le cache d'abord
      final cachedEcole = _storageService.getEcoleById(id);
      if (cachedEcole != null) {
        return EcoleModel.fromMap(cachedEcole);
      }

      // Vérifier la connexion
      final isConnected = await _connectivityService.checkConnection();
      if (!isConnected) {
        throw NetworkException('Aucune connexion Internet');
      }

      // Récupérer depuis Appwrite
      final response = await _appwriteService.databases.getDocument(
        databaseId: ApiConstants.databaseId,
        collectionId: ApiConstants.ecolesCollectionId,
        documentId: id,
      );

      return EcoleModel.fromJson(response.data);
    } on AppwriteException catch (e) {
      throw ServerException(_appwriteService.handleAppwriteError(e));
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // Rechercher des écoles
  Future<List<EcoleModel>> searchEcoles(String query) async {
    try {
      final isConnected = await _connectivityService.checkConnection();
      if (!isConnected) {
        // Recherche dans le cache
        final cachedEcoles = _storageService.getEcoles();
        final filtered = cachedEcoles
            .where(
              (e) => e['nom'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
        return filtered.map((e) => EcoleModel.fromMap(e)).toList();
      }

      final response = await _appwriteService.databases.listDocuments(
        databaseId: ApiConstants.databaseId,
        collectionId: ApiConstants.ecolesCollectionId,
        queries: [
          Query.search('nom', query),
          Query.limit(ApiConstants.defaultLimit),
        ],
      );

      return response.documents
          .map((doc) => EcoleModel.fromJson(doc.data))
          .toList();
    } on AppwriteException catch (e) {
      throw ServerException(_appwriteService.handleAppwriteError(e));
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
