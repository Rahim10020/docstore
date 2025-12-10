import 'package:docstore/services/appwrite_service.dart';
import 'package:docstore/services/google_drive_service.dart';

/// Type de source pour les ressources
enum ResourceSource { appwrite, googleDrive }

/// Modèle unifié pour une ressource (fichier)
class UnifiedResource {
  final String id;
  final String name;
  final ResourceSource source;
  final String viewUrl;
  final String downloadUrl;
  final String? mimeType;
  final int? size;
  final DateTime? createdTime;

  UnifiedResource({
    required this.id,
    required this.name,
    required this.source,
    required this.viewUrl,
    required this.downloadUrl,
    this.mimeType,
    this.size,
    this.createdTime,
  });

  /// Détermine si c'est un PDF
  bool get isPdf =>
      mimeType?.contains('pdf') == true || name.toLowerCase().endsWith('.pdf');

  /// Détermine si c'est une image
  bool get isImage =>
      mimeType?.contains('image') == true ||
      name.toLowerCase().endsWith('.png') ||
      name.toLowerCase().endsWith('.jpg') ||
      name.toLowerCase().endsWith('.jpeg');
}

/// Service unifié pour gérer les ressources de différentes sources
class UnifiedResourceService {
  // Singleton pattern
  static final UnifiedResourceService _instance =
      UnifiedResourceService._internal();
  factory UnifiedResourceService() => _instance;
  UnifiedResourceService._internal();

  final AppwriteService _appwriteService = AppwriteService();
  final GoogleDriveService _googleDriveService = GoogleDriveService();

  // ========== DÉTECTION DE LA SOURCE ==========

  /// Détecte la source d'une ressource depuis son identifiant
  ResourceSource detectSource(String resourceIdentifier) {
    if (_googleDriveService.isGoogleDriveUrl(resourceIdentifier)) {
      return ResourceSource.googleDrive;
    }
    return ResourceSource.appwrite;
  }

  // ========== RÉCUPÉRATION D'UNE RESSOURCE ==========

  /// Récupère les informations d'une ressource unifiée
  Future<UnifiedResource> getResource(String resourceIdentifier) async {
    final source = detectSource(resourceIdentifier);

    if (source == ResourceSource.googleDrive) {
      return _getGoogleDriveResource(resourceIdentifier);
    } else {
      return _getAppwriteResource(resourceIdentifier);
    }
  }

  /// Récupère une ressource depuis Google Drive
  Future<UnifiedResource> _getGoogleDriveResource(String url) async {
    final fileId = _googleDriveService.extractFileIdFromUrl(url);

    if (fileId == null) {
      throw Exception('ID de fichier Google Drive invalide');
    }

    // Essayer de récupérer les infos du fichier
    final fileInfo = await _googleDriveService.getFileInfoFromUrl(url);

    return UnifiedResource(
      id: fileId,
      name: fileInfo?['name'] ?? 'Document Google Drive',
      source: ResourceSource.googleDrive,
      viewUrl: _googleDriveService.getPreviewUrlDirect(fileId),
      downloadUrl: _googleDriveService.getDownloadUrl(fileId),
      mimeType: fileInfo?['mimeType'],
      size: fileInfo?['size'] != null
          ? int.tryParse(fileInfo!['size'].toString())
          : null,
      createdTime: fileInfo?['createdTime'] != null
          ? DateTime.tryParse(fileInfo!['createdTime'])
          : null,
    );
  }

  /// Récupère une ressource depuis Appwrite
  Future<UnifiedResource> _getAppwriteResource(String fileId) async {
    // Essayer de récupérer les infos du fichier depuis Appwrite
    // Note: Appwrite ne fournit pas directement les métadonnées via l'URL
    // On utilise donc les URLs générées par le service

    return UnifiedResource(
      id: fileId,
      name: 'Document', // Appwrite ne fournit pas le nom via l'URL
      source: ResourceSource.appwrite,
      viewUrl: _appwriteService.getFileView(fileId),
      downloadUrl: _appwriteService.getFileDownload(fileId),
      mimeType: null, // Non disponible sans appel API
      size: null,
      createdTime: null,
    );
  }

  // ========== RÉCUPÉRATION DE PLUSIEURS RESSOURCES ==========

  /// Récupère plusieurs ressources à partir d'une liste d'identifiants
  Future<List<UnifiedResource>> getResources(
    List<String> resourceIdentifiers,
  ) async {
    final List<UnifiedResource> resources = [];

    for (final identifier in resourceIdentifiers) {
      try {
        final resource = await getResource(identifier);
        resources.add(resource);
      } catch (e) {
        print('Erreur lors de la récupération de la ressource $identifier: $e');
        // On continue avec les autres ressources
      }
    }

    return resources;
  }

  // ========== HELPERS ==========

  /// Formate la taille du fichier
  String formatFileSize(int? bytes) {
    if (bytes == null) return 'Taille inconnue';

    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Obtient une icône appropriée selon le type de fichier
  String getFileIcon(UnifiedResource resource) {
    if (resource.isPdf) return '📄';
    if (resource.isImage) return '🖼️';
    return '📁';
  }
}
