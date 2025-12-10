import 'package:appwrite/appwrite.dart';
// Export des classes Appwrite pour faciliter l'utilisation
export 'package:appwrite/appwrite.dart' show ID, Query, Permission, Role;

/// Configuration client Appwrite pour Flutter
class AppwriteConfig {
  // Singleton pattern
  static final AppwriteConfig _instance = AppwriteConfig._internal();
  factory AppwriteConfig() => _instance;
  AppwriteConfig._internal();

  // Client Appwrite
  late final Client client;
  late final Databases databases;
  late final Storage storage;

  // IDs de configuration
  static const String projectId = '67efdbc8003bcb27bcaf';
  static const String databaseId = '67efdc570033ac52dd43';
  static const String ecolesCollectionId = '67f727d60008a5965d9e';
  static const String filieresCollectionId = '67f728960028e33b576a';
  static const String uesCollectionId = '67f72a8f00239ccc2b36';
  static const String concoursCollectionId = '6893ba70001b392138f7';
  static const String bucketId = '67efdc26000acfe7e2ea';

  // Endpoint par défaut (modifiez si vous utilisez un serveur self-hosted)
  static const String endpoint = 'https://cloud.appwrite.io/v1';

  /// Initialise le client Appwrite
  void init() {
    client = Client()
        .setEndpoint(endpoint)
        .setProject(projectId);

    databases = Databases(client);
    storage = Storage(client);
  }

  /// Retourne une instance de Query pour construire des requêtes
  static Query query() => Query as Query;
}


