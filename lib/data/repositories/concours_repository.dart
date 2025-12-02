import 'package:appwrite/appwrite.dart';
import 'package:logger/logger.dart';
import '../models/index.dart';
import '../services/appwrite_service.dart';

class ConcoursRepository {
  // ignore: unused_field
  final AppwriteService _appwriteService;
  final Logger _logger = Logger();

  ConcoursRepository(this._appwriteService);

  Future<List<Concours>> getConcours({int limit = 25, int offset = 0}) async {
    try {
      final response = await AppwriteService.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.concoursCollectionId,
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
      final response = await AppwriteService.databases.getDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.concoursCollectionId,
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
      final response = await AppwriteService.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.concoursCollectionId,
        queries: [Query.equal('idEcole', ecoleId)],
      );

      return response.documents
          .map((doc) => Concours.fromJson(doc.data))
          .toList();
    } catch (e) {
      _logger.e('Error fetching concours for ecole: $e');
      rethrow;
    }
  }

  Future<List<Concours>> getConcourssByYear(int year) async {
    try {
      final response = await AppwriteService.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.concoursCollectionId,
        queries: [Query.equal('annee', year)],
      );

      return response.documents
          .map((doc) => Concours.fromJson(doc.data))
          .toList();
    } catch (e) {
      _logger.e('Error fetching concours by year: $e');
      rethrow;
    }
  }

  Future<Concours> createConcours(Concours concours) async {
    try {
      final response = await AppwriteService.databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.concoursCollectionId,
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
      final response = await AppwriteService.databases.updateDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.concoursCollectionId,
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
      await AppwriteService.databases.deleteDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.concoursCollectionId,
        documentId: id,
      );
    } catch (e) {
      _logger.e('Error deleting concours: $e');
      rethrow;
    }
  }

  Future<List<Concours>> searchConcours(String query) async {
    try {
      final response = await AppwriteService.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.concoursCollectionId,
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
