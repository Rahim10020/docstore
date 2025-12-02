import 'package:appwrite/appwrite.dart';
import 'package:logger/logger.dart';

class AppwriteService {
  // Singleton pattern
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  // Client Appwrite
  static final Client client = Client()
    ..setEndpoint('https://cloud.appwrite.io/v1')
    ..setProject('67efdbc8003bcb27bcaf');

  static final Databases databases = Databases(client);
  static final Storage storage = Storage(client);

  final Logger _logger = Logger();

  // IDs de configuration
  static const String databaseId = '67efdc570033ac52dd43';
  static const String ecolesCollectionId = '67f727d60008a5965d9e';
  static const String filieresCollectionId = '67f728960028e33b576a';
  static const String uesCollectionId = '67f72a8f00239ccc2b36';
  static const String concoursCollectionId = '6893ba70001b392138f7';
  static const String bucketId = '67efdc26000acfe7e2ea';

  // Getters pour accès aux services
  Databases get db => databases;
  Storage get stor => storage;
  Logger get logger => _logger;

  /// Récupère l'URL de visualisation d'un fichier
  String getFileView(String fileId) {
    return storage.getFileView(bucketId: bucketId, fileId: fileId).toString();
  }

  /// Récupère l'URL de téléchargement d'un fichier
  String getFileDownload(String fileId) {
    return storage
        .getFileDownload(bucketId: bucketId, fileId: fileId)
        .toString();
  }

  Future<void> testConnection() async {
    try {
      _logger.i('Testing Appwrite connection...');
      // Test de connexion en récupérant les écoles
      await databases.listDocuments(
        databaseId: databaseId,
        collectionId: ecolesCollectionId,
        queries: [Query.limit(1)],
      );
      _logger.i('Appwrite connection successful');
    } catch (e) {
      _logger.e('Appwrite connection failed: $e');
      rethrow;
    }
  }
}
