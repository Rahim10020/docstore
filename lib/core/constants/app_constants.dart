class AppConstants {
  // App Info
  static const String appName = 'DocStore';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyLastSync = 'last_sync';
  static const String keyFavorites = 'favorites';
  static const String keyDownloads = 'downloads';

  // Download Path
  static const String downloadFolderName = 'DocStore';

  // Pagination
  static const int itemsPerPage = 20;
  static const int searchResultsLimit = 50;

  // File Extensions
  static const List<String> supportedExtensions = [
    'pdf',
    'doc',
    'docx',
    'ppt',
    'pptx',
  ];

  // Error Messages
  static const String errorNetwork = 'Pas de connexion internet';
  static const String errorGeneric = 'Une erreur est survenue';
  static const String errorNotFound = 'Ressource introuvable';
  static const String errorPermission = 'Permission refusée';
  static const String errorDownload = 'Échec du téléchargement';

  // Success Messages
  static const String successDownload = 'Téléchargement réussi';
  static const String successShare = 'Partagé avec succès';

  // URLs
  static const String supportEmail = 'support@docstore.tg';
  static const String websiteUrl = 'https://docstore.tg';
  static const String privacyPolicyUrl = 'https://docstore.tg/privacy';
  static const String termsUrl = 'https://docstore.tg/terms';
}
