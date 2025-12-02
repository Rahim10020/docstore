import 'package:logger/logger.dart';
import '../models/index.dart';
import '../services/appwrite_service.dart';
import '../../config/app_constants.dart';

class ParcoursRepository {
  final AppwriteService _appwriteService;
  final Logger _logger = Logger();

  ParcoursRepository(this._appwriteService);

  Future<List<Parcours>> getParcours({
    int limit = AppConstants.itemsPerPage,
    int offset = 0,
  }) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.parcoursCollection,
      );

      return response.documents
          .map((doc) => Parcours.fromJson(doc.data))
          .toList();
    } catch (e) {
      _logger.e('Error fetching parcours: $e');
      rethrow;
    }
  }

  Future<Parcours> getParcoursById(String id) async {
    try {
      final response = await _appwriteService.databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.parcoursCollection,
        documentId: id,
      );

      return Parcours.fromJson(response.data);
    } catch (e) {
      _logger.e('Error fetching parcours $id: $e');
      rethrow;
    }
  }

  Future<Parcours> createParcours(Parcours parcours) async {
    try {
      final response = await _appwriteService.databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.parcoursCollection,
        documentId: 'unique()',
        data: parcours.toJson(),
      );

      return Parcours.fromJson(response.data);
    } catch (e) {
      _logger.e('Error creating parcours: $e');
      rethrow;
    }
  }

  Future<Parcours> updateParcours(String id, Parcours parcours) async {
    try {
      final response = await _appwriteService.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.parcoursCollection,
        documentId: id,
        data: parcours.toJson(),
      );

      return Parcours.fromJson(response.data);
    } catch (e) {
      _logger.e('Error updating parcours: $e');
      rethrow;
    }
  }

  Future<void> deleteParcours(String id) async {
    try {
      await _appwriteService.databases.deleteDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.parcoursCollection,
        documentId: id,
      );
    } catch (e) {
      _logger.e('Error deleting parcours: $e');
      rethrow;
    }
  }

  Future<List<Parcours>> searchParcours(String query) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.parcoursCollection,
      );

      final allParcours = response.documents
          .map((doc) => Parcours.fromJson(doc.data))
          .toList();

      final lowerQuery = query.toLowerCase();
      return allParcours
          .where((p) => p.nom.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      _logger.e('Error searching parcours: $e');
      rethrow;
    }
  }
}
