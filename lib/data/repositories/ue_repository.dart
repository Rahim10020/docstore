import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import '../models/index.dart';
import '../services/file_service.dart';
import '../../config/app_constants.dart';

/// Repository pour gérer les opérations CRUD sur les UEs (Unités d'Enseignement)
class UERepository {
  final TablesDB _tables;
  final FileService _fileService = FileService();

  UERepository(this._tables);

  /// Récupère toutes les UEs
  Future<List<UE>> getAllUEs() async {
    try {
      final response = await _tables.listRows(
        databaseId: AppConstants.databaseId,
        tableId: AppConstants.uesCollectionId,
      );

      return response.rows.map((doc) => UE.fromJson(doc.data)).toList();
    } catch (e) {
      log('Erreur lors de la récupération des UEs', error: e);
      return [];
    }
  }

  /// Récupère une UE par son ID
  Future<UE?> getUEById(String id) async {
    try {
      final response = await _tables.getRow(
        databaseId: AppConstants.databaseId,
        tableId: AppConstants.uesCollectionId,
        rowId: id,
      );

      return UE.fromJson(response.data);
    } catch (e) {
      log('Erreur lors de la récupération de l\'UE $id', error: e);
      return null;
    }
  }

  /// Récupère toutes les UEs d'une filière
  Future<List<UE>> getUEsByFiliere(String filiereId) async {
    try {
      final response = await _tables.listRows(
        databaseId: AppConstants.databaseId,
        tableId: AppConstants.uesCollectionId,
        queries: [Query.equal('idFiliere', filiereId)],
      );

      return response.rows.map((doc) => UE.fromJson(doc.data)).toList();
    } catch (e) {
      log(
        'Erreur lors de la récupération des UEs pour la filière $filiereId',
        error: e,
      );
      return [];
    }
  }

  /// Crée une nouvelle UE
  Future<UE?> createUE(UE ue) async {
    try {
      final response = await _tables.createRow(
        databaseId: AppConstants.databaseId,
        tableId: AppConstants.uesCollectionId,
        rowId: ID.unique(),
        data: ue.toJson(),
      );

      return UE.fromJson(response.data);
    } catch (e) {
      log('Erreur lors de la création de l\'UE', error: e);
      return null;
    }
  }

  /// Met à jour une UE
  Future<UE?> updateUE(String id, UE ue) async {
    try {
      final response = await _tables.updateRow(
        databaseId: AppConstants.databaseId,
        tableId: AppConstants.uesCollectionId,
        rowId: id,
        data: ue.toJson(),
      );

      return UE.fromJson(response.data);
    } catch (e) {
      log('Erreur lors de la mise à jour de l\'UE $id', error: e);
      return null;
    }
  }

  /// Supprime une UE
  Future<bool> deleteUE(String id) async {
    try {
      await _tables.deleteRow(
        databaseId: AppConstants.databaseId,
        tableId: AppConstants.uesCollectionId,
        rowId: id,
      );
      return true;
    } catch (e) {
      log('Erreur lors de la suppression de l\'UE $id', error: e);
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
      log('Erreur lors de la recherche d\'UEs', error: e);
      return [];
    }
  }

  /// Récupère les UEs d'une filière avec leurs ressources résolues
  Future<List<UE>> getUEsByFiliereWithResources(String filiereId) async {
    try {
      final ues = await getUEsByFiliere(filiereId);
      final uesWithFiles = <UE>[];

      for (final ue in ues) {
        // Résoudre les ressources de chaque UE
        final files = await _fileService.processResources(ue.ressources);
        uesWithFiles.add(ue.copyWith(files: files));
      }

      return uesWithFiles;
    } catch (e) {
      log(
        'Erreur lors de la récupération des UEs avec ressources pour la filière $filiereId',
        error: e,
      );
      return [];
    }
  }

  /// Recherche des UEs avec leurs ressources résolues
  Future<List<UE>> searchUEsWithResources(
    String filiereId,
    String query,
  ) async {
    try {
      final ues = await getUEsByFiliere(filiereId);
      final lowerQuery = query.toLowerCase();

      // Filtrer par recherche
      final filteredUEs = ues.where((u) {
        return u.nom.toLowerCase().contains(lowerQuery) ||
            u.description.toLowerCase().contains(lowerQuery);
      }).toList();

      // Résoudre les ressources pour chaque UE filtrée
      final uesWithFiles = <UE>[];
      for (final ue in filteredUEs) {
        final files = await _fileService.processResources(ue.ressources);
        uesWithFiles.add(ue.copyWith(files: files));
      }

      return uesWithFiles;
    } catch (e) {
      log('Erreur lors de la recherche d\'UEs avec ressources', error: e);
      return [];
    }
  }
}
