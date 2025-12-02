import 'package:logger/logger.dart';
import '../models/index.dart';
import '../services/appwrite_service.dart';
import '../../config/app_constants.dart';

class CoursRepository {
  final AppwriteService _appwriteService;
  final Logger _logger = Logger();

  CoursRepository(this._appwriteService);

  Future<List<Cours>> getCours({
    int limit = AppConstants.itemsPerPage,
    int offset = 0,
  }) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.coursCollection,
      );

      return response.documents.map((doc) => Cours.fromJson(doc.data)).toList();
    } catch (e) {
      _logger.e('Error fetching cours: $e');
      rethrow;
    }
  }

  Future<Cours> getCoursById(String id) async {
    try {
      final response = await _appwriteService.databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.coursCollection,
        documentId: id,
      );

      return Cours.fromJson(response.data);
    } catch (e) {
      _logger.e('Error fetching cours $id: $e');
      rethrow;
    }
  }

  Future<List<Cours>> getCoursBySemestre(String semestreId) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.coursCollection,
      );

      final allCours = response.documents
          .map((doc) => Cours.fromJson(doc.data))
          .toList();

      return allCours.where((c) => c.semesterId == semestreId).toList();
    } catch (e) {
      _logger.e('Error fetching cours for semestre: $e');
      rethrow;
    }
  }

  Future<Cours> createCours(Cours cours) async {
    try {
      final response = await _appwriteService.databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.coursCollection,
        documentId: 'unique()',
        data: cours.toJson(),
      );

      return Cours.fromJson(response.data);
    } catch (e) {
      _logger.e('Error creating cours: $e');
      rethrow;
    }
  }

  Future<Cours> updateCours(String id, Cours cours) async {
    try {
      final response = await _appwriteService.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.coursCollection,
        documentId: id,
        data: cours.toJson(),
      );

      return Cours.fromJson(response.data);
    } catch (e) {
      _logger.e('Error updating cours: $e');
      rethrow;
    }
  }

  Future<void> deleteCours(String id) async {
    try {
      await _appwriteService.databases.deleteDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.coursCollection,
        documentId: id,
      );
    } catch (e) {
      _logger.e('Error deleting cours: $e');
      rethrow;
    }
  }

  Future<List<Cours>> searchCours(String query) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.coursCollection,
      );

      final allCours = response.documents
          .map((doc) => Cours.fromJson(doc.data))
          .toList();

      final lowerQuery = query.toLowerCase();
      return allCours
          .where(
            (c) =>
                c.titre.toLowerCase().contains(lowerQuery) ||
                c.description.toLowerCase().contains(lowerQuery),
          )
          .toList();
    } catch (e) {
      _logger.e('Error searching cours: $e');
      rethrow;
    }
  }
}
