import 'dart:convert';
import '../config/appwrite_config.dart';
import '../data/models/ecole.dart';
import '../data/models/filiere.dart';
import '../data/models/ue.dart';
import '../data/models/concours.dart';
  final Client client = Client();
  late final Functions functions;
  final AppwriteConfig _config = AppwriteConfig();
  late final Databases _databases;
  late final Storage _storage;
        .setEndpoint(AppConstants.appwriteEndpoint)
        .setProject(AppConstants.appwriteProjectId);
    _config.init();
    _databases = _config.databases;
    _storage = _config.storage;
  }

  // ========== ECOLES ==========

  /// Récupère toutes les écoles
  Future<List<Ecole>> getEcoles() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ecolesCollectionId,
      );
      return response.documents.map((doc) => Ecole.fromMap(doc.data)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des écoles: $e');
      rethrow;
    }
        return filesList.map((e) => DriveFile.fromJson(e)).toList();
      } else {
  /// Récupère une école par ID
  Future<Ecole> getEcole(String ecoleId) async {
    } catch (e) {
      final response = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ecolesCollectionId,
        documentId: ecoleId,
}
      return Ecole.fromMap(response.data);

      print('Erreur lors de la récupération de l\'école: $e');
