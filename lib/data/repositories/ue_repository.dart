import 'package:appwrite/appwrite.dart';
import '../models/index.dart';
import '../../config/app_constants.dart';

/// Repository pour gérer les opérations CRUD sur les UEs (Unités d'Enseignement)
class UERepository {
  final Databases _databases;

  UERepository(this._databases);

  /// Récupère toutes les UEs
  Future<List<UE>> getAllUEs() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.uesCollectionId,
      );

      return response.documents.map((doc) => UE.fromJson(doc.data)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des UEs: $e');
      return [];
    }
  }

  /// Récupère une UE par son ID
  Future<UE?> getUEById(String id) async {
    try {
      final response = await _databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.uesCollectionId,
        documentId: id,
      );

      return UE.fromJson(response.data);
    } catch (e) {
      print('Erreur lors de la récupération de l\'UE $id: $e');
      return null;
    }
  }

  /// Récupère toutes les UEs d'une filière
  Future<List<UE>> getUEsByFiliere(String filiereId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.uesCollectionId,
        queries: [Query.equal('idFiliere', filiereId)],
      );

      return response.documents.map((doc) => UE.fromJson(doc.data)).toList();
    } catch (e) {
      print(
        'Erreur lors de la récupération des UEs pour la filière $filiereId: $e',
      );
      return [];
    }
  }

  /// Crée une nouvelle UE
  Future<UE?> createUE(UE ue) async {
    try {
      final response = await _databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.uesCollectionId,
        documentId: ID.unique(),
        data: ue.toJson(),
      );

      return UE.fromJson(response.data);
    } catch (e) {
      print('Erreur lors de la création de l\'UE: $e');
      return null;
    }
  }

  /// Met à jour une UE
  Future<UE?> updateUE(String id, UE ue) async {
    try {
      final response = await _databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.uesCollectionId,
        documentId: id,
        data: ue.toJson(),
      );

      return UE.fromJson(response.data);
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'UE $id: $e');
      return null;
    }
  }

  /// Supprime une UE
  Future<bool> deleteUE(String id) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.uesCollectionId,
        documentId: id,
      );
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de l\'UE $id: $e');
      return false;
    }
  }

  /// Recherche des UEs
  Future<List<UE>> searchUEs(String query) async {
    if (query.isEmpty) {
      return getAllUEs();
    }

    try {
      final allUEs = await getAllUEs();
      final lowerQuery = query.toLowerCase();

      return allUEs.where((u) {
        return u.nom.toLowerCase().contains(lowerQuery) ||
            u.description.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      print('Erreur lors de la recherche d\'UEs: $e');
      return [];
    }
  }
}
