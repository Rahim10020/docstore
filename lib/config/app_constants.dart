/// App constants
class AppConstants {
  // Appwrite Configuration
  static const String appwriteEndpoint = 'https://cloud.appwrite.io/v1';
  static const String appwriteProjectId = '67efdbc8003bcb27bcaf';

  // Database ID
  static const String databaseId = '67efdc570033ac52dd43';

  // Collection IDs (vrais IDs depuis Appwrite)
  static const String ecolesCollectionId = '67f727d60008a5965d9e';
  static const String filieresCollectionId = '67f728960028e33b576a';
  static const String uesCollectionId = '67f72a8f00239ccc2b36';
  static const String concoursCollectionId = '6893ba70001b392138f7';

  // Anciens noms pour compatibilité (à migrer progressivement)
  static const String ecolesCollection = 'ecoles';
  static const String filieresCollection = 'filieres';
  static const String parcoursCollection = 'parcours';
  static const String anneesCollection = 'annees';
  static const String semestresCollection = 'semestres';
  static const String coursCollection = 'cours';
  static const String ressourcesCollection = 'ressources';
  static const String concoursCollection = 'concours';

  // Storage Bucket ID
  static const String bucketId = '67efdc26000acfe7e2ea';

  // Search
  static const int minSearchLength = 2;
  static const int searchDebounceMs = 500;
  static const int maxSearchHistory = 10;

  // Cache
  static const int cacheValidityHours = 24;

  // Download
  static const int downloadConnectTimeoutMs = 30000;
  static const int downloadReceiveTimeoutMs = 120000;

  // Pagination
  static const int itemsPerPage = 20;

  // Padding & Spacing
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingDefault = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusDefault = 16.0;
  static const double radiusLarge = 24.0;

  // Animation Duration
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Font Sizes
  static const double fontSizeXSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeDefault = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeHeading = 28.0;
}
