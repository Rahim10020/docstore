import 'package:appwrite/appwrite.dart';
import 'package:logger/logger.dart';
import '../../config/app_constants.dart';

class AppwriteService {
  // Singleton pattern
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  // Client Appwrite
  static final Client client = Client()
    ..setEndpoint(AppConstants.appwriteEndpoint)
    ..setProject(AppConstants.appwriteProjectId);

  static final Databases databases = Databases(client);
  static final TablesDB tables = TablesDB(client);
  static final Storage storage = Storage(client);

  final Logger _logger = Logger();

  // IDs de configuration (utilise AppConstants)
  static String get databaseId => AppConstants.databaseId;
  static String get ecolesCollectionId => AppConstants.ecolesCollectionId;
  static String get filieresCollectionId => AppConstants.filieresCollectionId;
  static String get coursCollectionId => AppConstants.coursCollectionId;
  static String get concoursCollectionId => AppConstants.concoursCollectionId;
  static String get bucketId => AppConstants.bucketId;

  // Getters pour accès aux services
  Databases get db => databases;
  TablesDB get tbl => tables;
  Storage get stor => storage;
  Logger get logger => _logger;

  /// Récupère l'URL de visualisation d'un fichier
  String getFileView(String fileId) {
    return storage
        .getFileView(bucketId: AppConstants.bucketId, fileId: fileId)
        .toString();
  }

  /// Récupère l'URL de téléchargement d'un fichier
  String getFileDownload(String fileId) {
    return storage
        .getFileDownload(bucketId: AppConstants.bucketId, fileId: fileId)
        .toString();
  }

  Future<void> testConnection() async {
    try {
      _logger.i('Testing Appwrite connection...');
      // Test de connexion en récupérant les écoles
      await tables.listRows(
        databaseId: databaseId,
        tableId: ecolesCollectionId,
        queries: [Query.limit(1)],
      );
      _logger.i('Appwrite connection successful');
    } catch (e) {
      _logger.e('Appwrite connection failed: $e');
      rethrow;
    }
  }
}
