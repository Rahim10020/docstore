import 'package:logger/logger.dart';
import '../models/index.dart';
import '../services/appwrite_service.dart';
import '../services/file_service.dart';
import '../../config/app_constants.dart';

class CoursRepository {
  // ignore: unused_field
  final AppwriteService _appwriteService;
  final FileService _fileService = FileService();
  final Logger _logger = Logger();

  CoursRepository(this._appwriteService);

  Future<List<Cours>> getCours({int limit = 25, int offset = 0}) async {
    try {
      final response = await AppwriteService.tables.listRows(
        databaseId: AppwriteService.databaseId,
        tableId: AppConstants.coursCollectionId,
      );

      return response.rows.map((doc) => Cours.fromJson(doc.data)).toList();
    } catch (e) {
      _logger.e('Error fetching cours: $e');
      rethrow;
    }
  }

  Future<Cours> getCoursById(String id) async {
    try {
      final response = await AppwriteService.tables.getRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppConstants.coursCollectionId,
        rowId: id,
      );

      return Cours.fromJson(response.data);
    } catch (e) {
      _logger.e('Error fetching cours $id: $e');
      rethrow;
    }
  }

  Future<List<Cours>> getCoursBySemestre(String semestreId) async {
    try {
      final response = await AppwriteService.tables.listRows(
        databaseId: AppwriteService.databaseId,
        tableId: AppConstants.coursCollectionId,
      );

      final allCours = response.rows
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
      final response = await AppwriteService.tables.createRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppConstants.coursCollectionId,
        rowId: 'unique()',
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
      final response = await AppwriteService.tables.updateRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppConstants.coursCollectionId,
        rowId: id,
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
      await AppwriteService.tables.deleteRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppConstants.coursCollectionId,
        rowId: id,
      );
    } catch (e) {
      _logger.e('Error deleting cours: $e');
      rethrow;
    }
  }

  Future<List<Cours>> searchCours(String query) async {
    try {
      final response = await AppwriteService.tables.listRows(
        databaseId: AppwriteService.databaseId,
        tableId: AppConstants.coursCollectionId,
      );

      final allCours = response.rows
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

  /// Récupère les ressources d'un cours (Appwrite + Google Drive)
  Future<List<FileResource>> getCoursResources(String coursId) async {
    try {
      final cours = await getCoursById(coursId);
      return await _fileService.processResources(cours.ressources);
    } catch (e) {
      _logger.e('Error fetching cours resources: $e');
      rethrow;
    }
  }

  /// Récupère les ressources à partir d'un objet Cours
  Future<List<FileResource>> getResourcesFromCours(Cours cours) async {
    try {
      return await _fileService.processResources(cours.ressources);
    } catch (e) {
      _logger.e('Error processing cours resources: $e');
      return [];
    }
  }
}
