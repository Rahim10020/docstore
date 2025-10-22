class ApiConstants {
  // Appwrite Configuration
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = '67efdbc8003bcb27bcaf';

  // Database & Collections
  static const String databaseId = '67efdc570033ac52dd43';
  static const String ecolesCollectionId = '67f727d60008a5965d9e';
  static const String filieresCollectionId = '67f728960028e33b576a';
  static const String uesCollectionId = '67f72a8f00239ccc2b36';
  static const String concoursCollectionId = '6893ba70001b392138f7';

  // Storage
  static const String bucketId = '67efdc26000acfe7e2ea';

  // Pagination
  static const int defaultLimit = 25;
  static const int maxLimit = 100;

  // Cache expiration (en heures)
  static const int cacheExpirationHours = 24;
  static const int concoursExpirationHours = 12; // Plus dynamique
}
