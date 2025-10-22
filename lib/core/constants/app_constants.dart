class AppConstants {
  // App Info
  static const String appName = 'DocStore Mobile';
  static const String appVersion = '1.0.0';

  // Hive Boxes
  static const String ecolesBox = 'ecoles_box';
  static const String filieresBox = 'filieres_box';
  static const String uesBox = 'ues_box';
  static const String concoursBox = 'concours_box';
  static const String filesBox = 'files_box';
  static const String preferencesBox = 'preferences_box';

  // Preference Keys
  static const String lastSyncKey = 'last_sync_';
  static const String favoriteEcoleKey = 'favorite_ecole';
  static const String favoriteFilieresKey = 'favorite_filieres';

  // File types
  static const List<String> supportedFileExtensions = [
    'pdf',
    'doc',
    'docx',
    'zip',
    'ppt',
    'pptx',
  ];

  // Google Drive detection
  static const String driveUrlPattern = 'drive.google.com';
  static const String driveFilePattern = '/file/d/';

  // Downloads
  static const String downloadsFolderName = 'DocStore';
}
