import 'package:logger/logger.dart';
import '../models/index.dart';
import '../services/appwrite_service.dart';
import '../../config/app_constants.dart';

class EcoleRepository {
  final AppwriteService _appwriteService;
  final Logger _logger = Logger();

  EcoleRepository(this._appwriteService);

  Future<List<Ecole>> getEcoles({
    int limit = AppConstants.itemsPerPage,
    int offset = 0,
  }) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.ecolesCollection,
      );

      return response.documents.map((doc) => Ecole.fromJson(doc.data)).toList();
    } catch (e) {
      _logger.e('Error fetching ecoles: $e');
      rethrow;
    }
  }

  Future<Ecole> getEcoleById(String id) async {
    try {
      final response = await _appwriteService.databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.ecolesCollection,
        documentId: id,
      );

      return Ecole.fromJson(response.data);
    } catch (e) {
      _logger.e('Error fetching ecole $id: $e');
      rethrow;
    }
  }

  Future<Ecole> createEcole(Ecole ecole) async {
    try {
      final response = await _appwriteService.databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.ecolesCollection,
        documentId: 'unique()',
        data: ecole.toJson(),
      );

      return Ecole.fromJson(response.data);
    } catch (e) {
      _logger.e('Error creating ecole: $e');
      rethrow;
    }
  }

  Future<Ecole> updateEcole(String id, Ecole ecole) async {
    try {
      final response = await _appwriteService.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.ecolesCollection,
        documentId: id,
        data: ecole.toJson(),
      );

      return Ecole.fromJson(response.data);
    } catch (e) {
      _logger.e('Error updating ecole: $e');
      rethrow;
    }
  }

  Future<void> deleteEcole(String id) async {
    try {
      await _appwriteService.databases.deleteDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.ecolesCollection,
        documentId: id,
      );
    } catch (e) {
      _logger.e('Error deleting ecole: $e');
      rethrow;
    }
  }

  Future<List<Ecole>> searchEcoles(String query) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.ecolesCollection,
      );

      final allEcoles = response.documents
          .map((doc) => Ecole.fromJson(doc.data))
          .toList();

      final lowerQuery = query.toLowerCase();
      return allEcoles
          .where(
            (ecole) =>
                ecole.nom.toLowerCase().contains(lowerQuery) ||
                ecole.lieu.toLowerCase().contains(lowerQuery),
          )
          .toList();
    } catch (e) {
      _logger.e('Error searching ecoles: $e');
      rethrow;
    }
  }
}
