import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import '../constants/appwrite_constants.dart';
import '../utils/logger.dart';

class AppwriteService extends GetxService {
  late Client _client;
  late Databases _databases;
  late Storage _storage;

  Client get client => _client;
  Databases get databases => _databases;
  Storage get storage => _storage;

  @override
  void onInit() {
    super.onInit();
    _initializeAppwrite();
  }

  void _initializeAppwrite() {
    try {
      _client = Client()
          .setEndpoint(AppwriteConstants.endpoint)
          .setProject(AppwriteConstants.projectId)
          .setSelfSigned(status: true); // Pour développement uniquement

      _databases = Databases(_client);
      _storage = Storage(_client);

      AppLogger.info('Appwrite initialisé avec succès');
    } catch (e) {
      AppLogger.error('Erreur initialisation Appwrite', e);
      rethrow;
    }
  }

  // === MÉTHODES DATABASES ===

  /// Liste des documents d'une collection avec filtres optionnels
  Future<List<Map<String, dynamic>>> listDocuments({
    required String collectionId,
    List<String>? queries,
    int? limit,
  }) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        queries: queries ?? [],
      );

      return response.documents.map((doc) => doc.data).toList();
    } catch (e) {
      AppLogger.error('Erreur listDocuments ($collectionId)', e);
      rethrow;
    }
  }

  /// Récupère un document par son ID
  Future<Map<String, dynamic>> getDocument({
    required String collectionId,
    required String documentId,
  }) async {
    try {
      final response = await _databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: documentId,
      );

      return response.data;
    } catch (e) {
      AppLogger.error('Erreur getDocument ($collectionId/$documentId)', e);
      rethrow;
    }
  }

  /// Crée un nouveau document
  Future<Map<String, dynamic>> createDocument({
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: documentId,
        data: data,
      );

      return response.data;
    } catch (e) {
      AppLogger.error('Erreur createDocument ($collectionId)', e);
      rethrow;
    }
  }

  /// Met à jour un document existant
  Future<Map<String, dynamic>> updateDocument({
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: documentId,
        data: data,
      );

      return response.data;
    } catch (e) {
      AppLogger.error('Erreur updateDocument ($collectionId/$documentId)', e);
      rethrow;
    }
  }

  /// Supprime un document
  Future<void> deleteDocument({
    required String collectionId,
    required String documentId,
  }) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: documentId,
      );
    } catch (e) {
      AppLogger.error('Erreur deleteDocument ($collectionId/$documentId)', e);
      rethrow;
    }
  }

  // === MÉTHODES STORAGE ===

  /// Récupère l'URL de prévisualisation d'un fichier
  String getFilePreview({
    required String bucketId,
    required String fileId,
    int? width,
    int? height,
  }) {
    return '${AppwriteConstants.endpoint}/storage/buckets/$bucketId/files/$fileId/preview?project=${AppwriteConstants.projectId}${width != null ? '&width=$width' : ''}${height != null ? '&height=$height' : ''}';
  }

  /// Récupère l'URL de téléchargement d'un fichier
  String getFileDownload({required String bucketId, required String fileId}) {
    return '${AppwriteConstants.endpoint}/storage/buckets/$bucketId/files/$fileId/download?project=${AppwriteConstants.projectId}';
  }

  /// Récupère l'URL de vue d'un fichier
  String getFileView({required String bucketId, required String fileId}) {
    return '${AppwriteConstants.endpoint}/storage/buckets/$bucketId/files/$fileId/view?project=${AppwriteConstants.projectId}';
  }

  /// Upload un fichier vers le storage
  Future<String> uploadFile({
    required String bucketId,
    required String fileId,
    required InputFile file,
  }) async {
    try {
      final response = await _storage.createFile(
        bucketId: bucketId,
        fileId: fileId,
        file: file,
      );

      return response.$id;
    } catch (e) {
      AppLogger.error('Erreur uploadFile ($bucketId)', e);
      rethrow;
    }
  }

  /// Supprime un fichier du storage
  Future<void> deleteFile({
    required String bucketId,
    required String fileId,
  }) async {
    try {
      await _storage.deleteFile(bucketId: bucketId, fileId: fileId);
    } catch (e) {
      AppLogger.error('Erreur deleteFile ($bucketId/$fileId)', e);
      rethrow;
    }
  }
}
