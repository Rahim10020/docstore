import 'package:appwrite/appwrite.dart';
import 'package:logger/logger.dart';
import '../models/index.dart';
import '../services/appwrite_service.dart';

class FiliereRepository {
  // ignore: unused_field
  final AppwriteService _appwriteService;
  final Logger _logger = Logger();

  FiliereRepository(this._appwriteService);

  Future<List<Filiere>> getFilieres({int limit = 25, int offset = 0}) async {
    try {
      final response = await AppwriteService.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.filieresCollectionId,
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
      final response = await AppwriteService.databases.getDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.filieresCollectionId,
        documentId: id,
      );

      return Filiere.fromJson(response.data);
    } catch (e) {
      _logger.e('Error fetching filiere $id: $e');
      rethrow;
    }
  }

  Future<List<Filiere>> getFilieresByEcole(String ecoleId) async {
    try {
      final response = await AppwriteService.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.filieresCollectionId,
        queries: [Query.equal('idEcole', ecoleId)],
      );

      return response.documents
          .map((doc) => Filiere.fromJson(doc.data))
          .toList();
    } catch (e) {
      _logger.e('Error fetching filieres for ecole: $e');
      rethrow;
    }
  }

  Future<Filiere> createFiliere(Filiere filiere) async {
    try {
      final response = await AppwriteService.databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.filieresCollectionId,
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
      final response = await AppwriteService.databases.updateDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.filieresCollectionId,
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
      await AppwriteService.databases.deleteDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.filieresCollectionId,
        documentId: id,
      );
    } catch (e) {
      _logger.e('Error deleting filiere: $e');
      rethrow;
    }
  }

  Future<List<Filiere>> searchFilieres(String query) async {
    try {
      final response = await AppwriteService.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.filieresCollectionId,
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
