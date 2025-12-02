import 'package:logger/logger.dart';
import '../models/index.dart';
import '../services/appwrite_service.dart';

class EcoleRepository {
  // ignore: unused_field
  final AppwriteService _appwriteService;
  final Logger _logger = Logger();

  EcoleRepository(this._appwriteService);

  Future<List<Ecole>> getEcoles({int limit = 25, int offset = 0}) async {
    try {
      final response = await AppwriteService.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.ecolesCollectionId,
      );

      return response.documents.map((doc) => Ecole.fromJson(doc.data)).toList();
    } catch (e) {
      _logger.e('Error fetching ecoles: $e');
      rethrow;
    }
  }

  Future<Ecole> getEcoleById(String id) async {
    try {
      final response = await AppwriteService.databases.getDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.ecolesCollectionId,
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
      final response = await AppwriteService.databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.ecolesCollectionId,
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
      final response = await AppwriteService.databases.updateDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.ecolesCollectionId,
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
      await AppwriteService.databases.deleteDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.ecolesCollectionId,
        documentId: id,
      );
    } catch (e) {
      _logger.e('Error deleting ecole: $e');
      rethrow;
    }
  }

  Future<List<Ecole>> searchEcoles(String query) async {
    try {
      final response = await AppwriteService.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.ecolesCollectionId,
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
