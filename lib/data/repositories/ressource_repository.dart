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
  /// Note: Cette méthode nécessite une implémentation basée sur la structure réelle de votre BD
  Future<List<FileResource>> searchRessources(
    String filiereId,
    String query,
  ) async {
    try {
      _logger.i('Searching resources in filiere $filiereId with query: $query');
      // TODO: Implémenter la recherche basée sur la structure réelle de votre base de données
      // Pour l'instant, retourne une liste vide car getRessourcesByFiliere a été supprimé
      _logger.w(
        'searchRessources not implemented - collections annee/semestre do not exist',
      );
      return [];
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
}
