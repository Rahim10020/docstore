import 'package:logger/logger.dart';
import '../models/index.dart';
import '../services/appwrite_service.dart';
import '../../config/app_constants.dart';

class FiliereRepository {
  final AppwriteService _appwriteService;
  final Logger _logger = Logger();

  FiliereRepository(this._appwriteService);

  Future<List<Filiere>> getFilieres({
    int limit = AppConstants.itemsPerPage,
    int offset = 0,
  }) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.filieresCollection,
      );

      return response.documents
          .map((doc) => Filiere.fromJson(doc.data))
          .toList();
    } catch (e) {
      _logger.e('Error fetching filieres: $e');
      rethrow;
    }
  }

  Future<Filiere> getFiliereById(String id) async {
    try {
      final response = await _appwriteService.databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.filieresCollection,
        documentId: id,
      );

      return Filiere.fromJson(response.data);
    } catch (e) {
      _logger.e('Error fetching filiere $id: $e');
      rethrow;
    }
  }

  Future<List<Filiere>> getFilieresByParcours(String parcoursId) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.filieresCollection,
      );

      final allFilieres = response.documents
          .map((doc) => Filiere.fromJson(doc.data))
          .toList();

      return allFilieres.where((f) => f.parcoursId == parcoursId).toList();
    } catch (e) {
      _logger.e('Error fetching filieres for parcours: $e');
      rethrow;
    }
  }

  Future<Filiere> createFiliere(Filiere filiere) async {
    try {
      final response = await _appwriteService.databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.filieresCollection,
        documentId: 'unique()',
        data: filiere.toJson(),
      );

      return Filiere.fromJson(response.data);
    } catch (e) {
      _logger.e('Error creating filiere: $e');
      rethrow;
    }
  }

  Future<Filiere> updateFiliere(String id, Filiere filiere) async {
    try {
      final response = await _appwriteService.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.filieresCollection,
        documentId: id,
        data: filiere.toJson(),
      );

      return Filiere.fromJson(response.data);
    } catch (e) {
      _logger.e('Error updating filiere: $e');
      rethrow;
    }
  }

  Future<void> deleteFiliere(String id) async {
    try {
      await _appwriteService.databases.deleteDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.filieresCollection,
        documentId: id,
      );
    } catch (e) {
      _logger.e('Error deleting filiere: $e');
      rethrow;
    }
  }

  Future<List<Filiere>> searchFilieres(String query) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.filieresCollection,
      );

      final allFilieres = response.documents
          .map((doc) => Filiere.fromJson(doc.data))
          .toList();

      final lowerQuery = query.toLowerCase();
      return allFilieres
          .where(
            (f) =>
                f.nom.toLowerCase().contains(lowerQuery) ||
                f.description.toLowerCase().contains(lowerQuery),
          )
          .toList();
    } catch (e) {
      _logger.e('Error searching filieres: $e');
      rethrow;
    }
  }
}
