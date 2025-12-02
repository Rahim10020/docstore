import 'package:logger/logger.dart';
import '../models/file_resource.dart';
import 'appwrite_service.dart';
import 'google_drive_service.dart';
import '../../config/app_constants.dart';

/// Service de gestion hybride des fichiers (Appwrite + Google Drive)
class FileService {
  final GoogleDriveService _driveService = GoogleDriveService();
  final Logger _logger = Logger();

  /// Détecte si une string est un ID Appwrite ou une URL Google Drive
  bool _isGoogleDriveUrl(String resource) {
    return _driveService.isGoogleDriveUrl(resource);
  }

  /// Convertit une liste de strings (IDs Appwrite ou URLs Google Drive) en FileResource
  Future<List<FileResource>> processResources(List<String> resources) async {
    final List<FileResource> fileResources = [];

    for (final resource in resources) {
      try {
        final fileResource = await _processResource(resource);
        if (fileResource != null) {
          fileResources.add(fileResource);
        }
      } catch (e) {
        _logger.e('Error processing resource $resource: $e');
      }
    }

    return fileResources;
  }

  /// Traite une ressource individuelle (ID Appwrite ou URL Google Drive)
  Future<FileResource?> _processResource(String resource) async {
    if (_isGoogleDriveUrl(resource)) {
      return await _processGoogleDriveResource(resource);
    } else {
      return await _processAppwriteResource(resource);
    }
  }

  /// Traite une ressource Google Drive
  Future<FileResource?> _processGoogleDriveResource(String driveUrl) async {
    try {
      final fileId = _driveService.extractFileId(driveUrl);
      if (fileId == null) {
        _logger.w('Could not extract file ID from: $driveUrl');
        return null;
      }

      // Récupérer les métadonnées (optionnel, peut échouer)
      final metadata = await _driveService.getFileMetadata(driveUrl);

      final fileName = metadata?['name'] ?? 'Document Google Drive';
      final mimeType = metadata?['mimeType'];
      final size = metadata?['size'] != null
          ? int.tryParse(metadata!['size'].toString())
          : null;

      return FileResource.fromGoogleDrive(
        fileId: fileId,
        fileName: fileName,
        previewUrl: _driveService.getPreviewUrl(fileId),
        downloadUrl: _driveService.getDownloadUrl(fileId),
        mimeType: mimeType,
        size: size,
      );
    } catch (e) {
      _logger.e('Error processing Google Drive resource: $e');
      return null;
    }
  }

  /// Traite une ressource Appwrite Storage
  Future<FileResource?> _processAppwriteResource(String fileId) async {
    try {
      // Récupérer les métadonnées du fichier depuis Appwrite
      final file = await AppwriteService.storage.getFile(
        bucketId: AppConstants.bucketId,
        fileId: fileId,
      );

      // Générer les URLs
      final viewUrl = AppwriteService.storage
          .getFileView(bucketId: AppConstants.bucketId, fileId: fileId)
          .toString();

      final downloadUrl = AppwriteService.storage
          .getFileDownload(bucketId: AppConstants.bucketId, fileId: fileId)
          .toString();

      return FileResource.fromAppwrite(
        fileId: file.$id,
        fileName: file.name,
        viewUrl: viewUrl,
        downloadUrl: downloadUrl,
        mimeType: file.mimeType,
        size: file.sizeOriginal,
      );
    } catch (e) {
      _logger.e('Error processing Appwrite resource $fileId: $e');
      return null;
    }
  }

  /// Récupère un seul fichier par son ID ou URL
  Future<FileResource?> getFile(String resourceIdOrUrl) async {
    return await _processResource(resourceIdOrUrl);
  }

  /// Vérifie si une ressource est un lien Google Drive
  bool isGoogleDriveUrl(String resource) {
    return _isGoogleDriveUrl(resource);
  }

  /// Récupère l'URL de prévisualisation pour n'importe quelle ressource
  Future<String?> getPreviewUrl(String resource) async {
    final fileResource = await _processResource(resource);
    return fileResource?.url;
  }

  /// Récupère l'URL de téléchargement pour n'importe quelle ressource
  Future<String?> getDownloadUrl(String resource) async {
    final fileResource = await _processResource(resource);
    return fileResource?.downloadUrl;
  }
}
