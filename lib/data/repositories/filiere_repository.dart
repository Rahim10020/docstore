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
      final response = await AppwriteService.tables.listRows(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.filieresCollectionId,
      );

      return response.rows.map((doc) => Filiere.fromJson(doc.data)).toList();
    } catch (e) {
      _logger.e('Error fetching filieres: $e');
      rethrow;
    }
  }

  Future<Filiere> getFiliereById(String id) async {
    try {
      final response = await AppwriteService.tables.getRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.filieresCollectionId,
        rowId: id,
      );

      return Filiere.fromJson(response.data);
    } catch (e) {
      _logger.e('Error fetching filiere $id: $e');
      rethrow;
    }
  }

  Future<List<Filiere>> getFilieresByEcole(String ecoleId) async {
    try {
      final response = await AppwriteService.tables.listRows(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.filieresCollectionId,
        queries: [Query.equal('idEcole', ecoleId)],
      );

      return response.rows.map((doc) => Filiere.fromJson(doc.data)).toList();
    } catch (e) {
      _logger.e('Error fetching filieres for ecole: $e');
      rethrow;
    }
  }

  Future<Filiere> createFiliere(Filiere filiere) async {
    try {
      final response = await AppwriteService.tables.createRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.filieresCollectionId,
        rowId: 'unique()',
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
      final response = await AppwriteService.tables.updateRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.filieresCollectionId,
        rowId: id,
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
      await AppwriteService.tables.deleteRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.filieresCollectionId,
        rowId: id,
      );
    } catch (e) {
      _logger.e('Error deleting filiere: $e');
      rethrow;
    }
  }

  Future<List<Filiere>> searchFilieres(String query) async {
    try {
      final response = await AppwriteService.tables.listRows(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.filieresCollectionId,
      );

      final allFilieres = response.rows
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
