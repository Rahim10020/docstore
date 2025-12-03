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
      final response = await AppwriteService.tables.listRows(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.ecolesCollectionId,
      );

      return response.rows.map((doc) => Ecole.fromJson(doc.data)).toList();
    } catch (e) {
      _logger.e('Error fetching ecoles: $e');
      rethrow;
    }
  }

  Future<Ecole> getEcoleById(String id) async {
    try {
      final response = await AppwriteService.tables.getRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.ecolesCollectionId,
        rowId: id,
      );

      return Ecole.fromJson(response.data);
    } catch (e) {
      _logger.e('Error fetching ecole $id: $e');
      rethrow;
    }
  }

  Future<Ecole> createEcole(Ecole ecole) async {
    try {
      final response = await AppwriteService.tables.createRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.ecolesCollectionId,
        rowId: 'unique()',
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
      final response = await AppwriteService.tables.updateRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.ecolesCollectionId,
        rowId: id,
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
      await AppwriteService.tables.deleteRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.ecolesCollectionId,
        rowId: id,
      );
    } catch (e) {
      _logger.e('Error deleting ecole: $e');
      rethrow;
    }
  }

  Future<List<Ecole>> searchEcoles(String query) async {
    try {
      final response = await AppwriteService.tables.listRows(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.ecolesCollectionId,
      );

      final allEcoles = response.rows
          .map((doc) => Ecole.fromJson(doc.data))
          .toList();

      final lowerQuery = query.toLowerCase();
      return allEcoles
          .where(
            (ecole) =>
                ecole.title.toLowerCase().contains(lowerQuery) ||
                ecole.description.toLowerCase().contains(lowerQuery),
          )
          .toList();
    } catch (e) {
      _logger.e('Error searching ecoles: $e');
      rethrow;
    }
  }
}
