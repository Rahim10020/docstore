import 'package:appwrite/appwrite.dart';
import 'package:logger/logger.dart';
import '../../config/app_constants.dart';
import '../models/index.dart';
import '../services/appwrite_service.dart';

class RessourceRepository {
  // ignore: unused_field
  final AppwriteService _appwriteService;
  final Logger _logger = Logger();

  RessourceRepository(this._appwriteService);

  Future<List<Ressource>> getRessourcesByFiliere(String filiereId) async {
    try {
      final response = await AppwriteService.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.ressourcesCollectionId,
        queries: [Query.equal('filiereId', filiereId)],
      );

      return response.documents
          .map((doc) => Ressource.fromJson(doc.data))
          .toList();
    } catch (e) {
      _logger.e('Error fetching ressources for filiere $filiereId: $e');
      rethrow;
    }
  }

  Future<List<Ressource>> getRessourcesByType(
    String filiereId,
    String type,
  ) async {
    try {
      final response = await AppwriteService.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.ressourcesCollectionId,
        queries: [
          Query.equal('filiereId', filiereId),
          Query.equal('type', type),
        ],
      );

      return response.documents
          .map((doc) => Ressource.fromJson(doc.data))
          .toList();
    } catch (e) {
      _logger.e('Error fetching ressources by type: $e');
      rethrow;
    }
  }

  Future<Ressource> getRessourceById(String id) async {
    try {
      final response = await AppwriteService.databases.getDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.ressourcesCollectionId,
        documentId: id,
      );

      return Ressource.fromJson(response.data);
    } catch (e) {
      _logger.e('Error fetching ressource $id: $e');
      rethrow;
    }
  }

  Future<List<Ressource>> searchRessources(
    String filiereId,
    String query,
  ) async {
    try {
      final ressources = await getRessourcesByFiliere(filiereId);
      final lowerQuery = query.toLowerCase();

      return ressources
          .where(
            (r) =>
                r.nom.toLowerCase().contains(lowerQuery) ||
                (r.description?.toLowerCase().contains(lowerQuery) ?? false),
          )
          .toList();
    } catch (e) {
      _logger.e('Error searching ressources: $e');
      rethrow;
    }
  }
}
