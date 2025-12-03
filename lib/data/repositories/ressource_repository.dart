import 'package:appwrite/appwrite.dart';
import 'package:logger/logger.dart';
import '../models/index.dart';
import '../services/appwrite_service.dart';
import '../services/file_service.dart';
import '../../config/app_constants.dart';

class RessourceRepository {
  // ignore: unused_field
  final AppwriteService _appwriteService;
  final FileService _fileService = FileService();
  final Logger _logger = Logger();

  // Cache pour éviter les appels API répétés
  final Map<String, List<FileResource>> _resourcesCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  RessourceRepository(this._appwriteService);

  /// Récupère les ressources d'une filière en suivant le flux:
  /// Filière -> Année -> Semestre -> Cours (UE) -> Ressources (Google Drive + Appwrite Storage)
  Future<List<FileResource>> getRessourcesByFiliere(String filiereId) async {
    try {
      _logger.i('Fetching resources for filiere: $filiereId');

      // Vérifier le cache
      if (_isCacheValid(filiereId)) {
        _logger.i('Returning cached resources for filiere: $filiereId');
        return _resourcesCache[filiereId]!;
      }

      // 1. Récupérer tous les années de la filière
      final anneeResponse = await AppwriteService.tables.listRows(
        databaseId: AppwriteService.databaseId,
        tableId: AppConstants.anneeCollectionId,
        queries: [Query.equal('filiereId', filiereId)],
      );

      final anneeList = anneeResponse.rows.isNotEmpty
          ? anneeResponse.rows.map((doc) => doc.$id).toList()
          : [];

      _logger.i('Found ${anneeList.length} annees for filiere $filiereId');

      // 2. Récupérer tous les semestres pour chaque année
      final List<String> semestreIds = [];
      for (final anneeId in anneeList) {
        final semestreResponse = await AppwriteService.tables.listRows(
          databaseId: AppwriteService.databaseId,
          tableId: AppConstants.semestreCollectionId,
          queries: [Query.equal('anneeId', anneeId)],
        );

        semestreIds.addAll(semestreResponse.rows.map((doc) => doc.$id));
      }

      _logger.i('Found ${semestreIds.length} semestres for filiere $filiereId');

      // 3. Récupérer tous les cours pour chaque semestre
      final List<FileResource> allResources = [];
      for (final semestreId in semestreIds) {
        final coursResponse = await AppwriteService.tables.listRows(
          databaseId: AppwriteService.databaseId,
          tableId: AppConstants.coursCollectionId,
          queries: [Query.equal('semesterId', semestreId)],
        );

        final coursList = coursResponse.rows
            .map((doc) => Cours.fromJson(doc.data))
            .toList();

        _logger.i('Found ${coursList.length} cours for semestre $semestreId');

        // 4. Récupérer les ressources de chaque cours
        for (final cours in coursList) {
          if (cours.ressources.isNotEmpty) {
            _logger.i(
              'Processing ${cours.ressources.length} resources for cours: ${cours.titre}',
            );

            final resources = await _fileService.processResources(
              cours.ressources,
            );
            allResources.addAll(resources);
          }
        }
      }

      _logger.i('Total resources found: ${allResources.length}');

      // Mettre en cache
      _resourcesCache[filiereId] = allResources;
      _cacheTimestamps[filiereId] = DateTime.now();

      return allResources;
    } catch (e) {
      _logger.e('Error fetching ressources for filiere $filiereId: $e');
      rethrow;
    }
  }

  /// Récupère les ressources d'un cours spécifique par type
  Future<List<FileResource>> getRessourcesByType(
    String coursId,
    String type,
  ) async {
    try {
      _logger.i('Fetching resources for cours: $coursId, type: $type');

      // Récupérer le cours
      final coursResponse = await AppwriteService.tables.getRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppConstants.coursCollectionId,
        rowId: coursId,
      );

      final cours = Cours.fromJson(coursResponse.data);

      // Traiter les ressources
      final resources = await _fileService.processResources(cours.ressources);

      // Filtrer par type si nécessaire
      // Note: Le filtrage par type peut nécessiter des métadonnées additionnelles
      return resources;
    } catch (e) {
      _logger.e('Error fetching ressources by type: $e');
      rethrow;
    }
  }

  /// Récupère les ressources d'un cours spécifique
  Future<List<FileResource>> getRessourcesByCours(String coursId) async {
    try {
      _logger.i('Fetching resources for cours: $coursId');

      // Vérifier le cache
      final cacheKey = 'cours_$coursId';
      if (_isCacheValid(cacheKey)) {
        _logger.i('Returning cached resources for cours: $coursId');
        return _resourcesCache[cacheKey]!;
      }

      // Récupérer le cours
      final coursResponse = await AppwriteService.tables.getRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppConstants.coursCollectionId,
        rowId: coursId,
      );

      final cours = Cours.fromJson(coursResponse.data);

      // Traiter les ressources
      final resources = await _fileService.processResources(cours.ressources);

      _logger.i('Found ${resources.length} resources for cours $coursId');

      // Mettre en cache
      _resourcesCache[cacheKey] = resources;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return resources;
    } catch (e) {
      _logger.e('Error fetching ressources for cours $coursId: $e');
      rethrow;
    }
  }

  /// Récupère une ressource par son ID ou URL
  Future<FileResource?> getRessourceById(String resourceIdOrUrl) async {
    try {
      _logger.i('Fetching resource: $resourceIdOrUrl');
      return await _fileService.getFile(resourceIdOrUrl);
    } catch (e) {
      _logger.e('Error fetching ressource $resourceIdOrUrl: $e');
      rethrow;
    }
  }

  /// Recherche de ressources dans une filière
  Future<List<FileResource>> searchRessources(
    String filiereId,
    String query,
  ) async {
    try {
      _logger.i('Searching resources in filiere $filiereId with query: $query');

      final ressources = await getRessourcesByFiliere(filiereId);
      final lowerQuery = query.toLowerCase();

      return ressources
          .where(
            (r) =>
                r.name.toLowerCase().contains(lowerQuery) ||
                (r.description?.toLowerCase().contains(lowerQuery) ?? false),
          )
          .toList();
    } catch (e) {
      _logger.e('Error searching ressources: $e');
      rethrow;
    }
  }

  /// Vérifie si le cache est valide (24 heures)
  bool _isCacheValid(String key) {
    if (!_resourcesCache.containsKey(key) ||
        !_cacheTimestamps.containsKey(key)) {
      return false;
    }

    final cacheAge = DateTime.now().difference(_cacheTimestamps[key]!);
    return cacheAge.inHours < AppConstants.cacheValidityHours;
  }

  /// Vide le cache pour une clé spécifique
  void clearCache([String? key]) {
    if (key != null) {
      _resourcesCache.remove(key);
      _cacheTimestamps.remove(key);
      _logger.i('Cache cleared for key: $key');
    } else {
      _resourcesCache.clear();
      _cacheTimestamps.clear();
      _logger.i('All cache cleared');
    }
  }

  /// Récupère tous les cours d'une filière avec leurs ressources
  Future<Map<Cours, List<FileResource>>> getCoursWithRessources(
    String filiereId,
  ) async {
    try {
      _logger.i('Fetching cours with resources for filiere: $filiereId');

      // Récupérer tous les années de la filière
      final anneeResponse = await AppwriteService.tables.listRows(
        databaseId: AppwriteService.databaseId,
        tableId: AppConstants.anneeCollectionId,
        queries: [Query.equal('filiereId', filiereId)],
      );

      final anneeList = anneeResponse.rows.isNotEmpty
          ? anneeResponse.rows.map((doc) => doc.$id).toList()
          : [];

      // Récupérer tous les semestres pour chaque année
      final List<String> semestreIds = [];
      for (final anneeId in anneeList) {
        final semestreResponse = await AppwriteService.tables.listRows(
          databaseId: AppwriteService.databaseId,
          tableId: AppConstants.semestreCollectionId,
          queries: [Query.equal('anneeId', anneeId)],
        );

        semestreIds.addAll(semestreResponse.rows.map((doc) => doc.$id));
      }

      // Récupérer tous les cours pour chaque semestre
      final Map<Cours, List<FileResource>> coursResources = {};

      for (final semestreId in semestreIds) {
        final coursResponse = await AppwriteService.tables.listRows(
          databaseId: AppwriteService.databaseId,
          tableId: AppConstants.coursCollectionId,
          queries: [Query.equal('semesterId', semestreId)],
        );

        final coursList = coursResponse.rows
            .map((doc) => Cours.fromJson(doc.data))
            .toList();

        for (final cours in coursList) {
          if (cours.ressources.isNotEmpty) {
            final resources = await _fileService.processResources(
              cours.ressources,
            );
            coursResources[cours] = resources;
          } else {
            coursResources[cours] = [];
          }
        }
      }

      return coursResources;
    } catch (e) {
      _logger.e('Error fetching cours with resources: $e');
      rethrow;
    }
  }
}
