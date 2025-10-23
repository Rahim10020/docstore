class AppwriteConstants {
  // Appwrite Configuration
  static const String projectId = '67efdc570033ac52dd43';
  static const String endpoint = 'https://cloud.appwrite.io/v1';

  // Database ID
  static const String databaseId = '67efdc570033ac52dd43';

  // Collections IDs
  static const String ecolesCollectionId = '67f727d60008a5965d9e';
  static const String filieresCollectionId = '67f728960028e33b576a';
  static const String uesCollectionId = '67f72a8f00239ccc2b36';
  static const String concoursCollectionId = '6893ba70001b392138f7';
  static const String fichiersCollectionId =
      'TO_BE_CREATED'; // À remplacer après création

  // Storage Bucket IDs (si nécessaire)
  static const String documentsBucketId = 'documents';

  // API Limits
  static const int defaultLimit = 100;
  static const int maxLimit = 500;

  // Cache Keys
  static const String cacheKeyEcoles = 'cache_ecoles';
  static const String cacheKeyFilieres = 'cache_filieres_';
  static const String cacheKeyUes = 'cache_ues_';
  static const String cacheKeyConcours = 'cache_concours_';
  static const String cacheKeyFichiers = 'cache_fichiers_';

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 24);
  static const Duration shortCacheDuration = Duration(hours: 1);
}
