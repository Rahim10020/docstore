import 'package:logger/logger.dart';
import '../models/index.dart';
import '../services/appwrite_service.dart';
import '../../config/app_constants.dart';

class ConcoursRepository {
  final AppwriteService _appwriteService;
  final Logger _logger = Logger();

  ConcoursRepository(this._appwriteService);

  Future<List<Concours>> getConcours({
    int limit = AppConstants.itemsPerPage,
    int offset = 0,
  }) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.concoursCollection,
      );

      return response.documents
          .map((doc) => Concours.fromJson(doc.data))
          .toList();
    } catch (e) {
      _logger.e('Error fetching concours: $e');
      rethrow;
    }
  }

  Future<Concours> getConcoursById(String id) async {
    try {
      final response = await _appwriteService.databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.concoursCollection,
        documentId: id,
      );

      return Concours.fromJson(response.data);
    } catch (e) {
      _logger.e('Error fetching concours $id: $e');
      rethrow;
    }
  }

  Future<List<Concours>> getConcoursByEcoleId(String ecoleId) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.concoursCollection,
      );

      final allConcours = response.documents
          .map((doc) => Concours.fromJson(doc.data))
          .toList();

      return allConcours.where((c) => c.ecoleId == ecoleId).toList();
    } catch (e) {
      _logger.e('Error fetching concours for ecole: $e');
      rethrow;
    }
  }

  Future<List<Concours>> getConcourssByYear(int year) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.concoursCollection,
      );

      final allConcours = response.documents
          .map((doc) => Concours.fromJson(doc.data))
          .toList();

      return allConcours.where((c) => c.annee == year).toList();
    } catch (e) {
      _logger.e('Error fetching concours by year: $e');
      rethrow;
    }
  }

  Future<Concours> createConcours(Concours concours) async {
    try {
      final response = await _appwriteService.databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.concoursCollection,
        documentId: 'unique()',
        data: concours.toJson(),
      );

      return Concours.fromJson(response.data);
    } catch (e) {
      _logger.e('Error creating concours: $e');
      rethrow;
    }
  }

  Future<Concours> updateConcours(String id, Concours concours) async {
    try {
      final response = await _appwriteService.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.concoursCollection,
        documentId: id,
        data: concours.toJson(),
      );

      return Concours.fromJson(response.data);
    } catch (e) {
      _logger.e('Error updating concours: $e');
      rethrow;
    }
  }

  Future<void> deleteConcours(String id) async {
    try {
      await _appwriteService.databases.deleteDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.concoursCollection,
        documentId: id,
      );
    } catch (e) {
      _logger.e('Error deleting concours: $e');
      rethrow;
    }
  }

  Future<List<Concours>> searchConcours(String query) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.concoursCollection,
      );

      final allConcours = response.documents
          .map((doc) => Concours.fromJson(doc.data))
          .toList();

      final lowerQuery = query.toLowerCase();
      return allConcours
          .where(
            (c) =>
                c.nom.toLowerCase().contains(lowerQuery) ||
                c.description.toLowerCase().contains(lowerQuery),
          )
          .toList();
    } catch (e) {
      _logger.e('Error searching concours: $e');
      rethrow;
    }
  }
}
