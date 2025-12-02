/// App constants
class AppConstants {
  // Appwrite Configuration
  static const String appwriteEndpoint = 'YOUR_APPWRITE_ENDPOINT';
  static const String appwriteProjectId = 'YOUR_PROJECT_ID';
  static const String appwriteApiKey = 'YOUR_API_KEY';

  // Collection IDs
  static const String ecolesCollection = 'ecoles';
  static const String filieresCollection = 'filieres';
  static const String parcoursCollection = 'parcours';
  static const String anneesCollection = 'annees';
  static const String semestresCollection = 'semestres';
  static const String coursCollection = 'cours';
  static const String ressourcesCollection = 'ressources';
  static const String concoursCollection = 'concours';

  // Database ID
  static const String databaseId = 'main_db';

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
