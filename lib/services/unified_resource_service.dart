import 'package:docstore/services/appwrite_service.dart';
import 'package:docstore/services/google_drive_service.dart';
import 'package:logger/logger.dart';

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
  final Logger _logger = Logger();

  // Cache pour les ressources
  final Map<String, UnifiedResource> _cache = {};

  // 🆕 NOUVEAU: Cache pour tous les fichiers Google Drive
  List<Map<String, dynamic>>? _allGoogleDriveFiles;

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
    // Vérifier le cache
    if (_cache.containsKey(resourceIdentifier)) {
      return _cache[resourceIdentifier]!;
    }

    final source = detectSource(resourceIdentifier);

    final resource = source == ResourceSource.googleDrive
        ? await _getGoogleDriveResource(resourceIdentifier)
        : await _getAppwriteResource(resourceIdentifier);

    // Mettre en cache
    _cache[resourceIdentifier] = resource;
    return resource;
  }

  /// Précharge tous les fichiers Google Drive en cache
  Future<void> preloadGoogleDriveFiles() async {
    if (_allGoogleDriveFiles != null) return; // Déjà chargé

    try {
      _logger.d('📥 Préchargement de tous les fichiers Google Drive...');
      _allGoogleDriveFiles = await _googleDriveService.listFiles();
      _logger.d('✅ ${_allGoogleDriveFiles!.length} fichiers Google Drive préchargés');
    } catch (e) {
      _logger.e('❌ Erreur lors du préchargement Google Drive', error: e);
      _allGoogleDriveFiles = [];
    }
  }

  /// Récupère une ressource depuis Google Drive
  /// Utilise le cache préchargé
  Future<UnifiedResource> _getGoogleDriveResource(String url) async {
    final fileId = _googleDriveService.extractFileIdFromUrl(url);

    if (fileId == null) {
      throw Exception('ID de fichier Google Drive invalide: $url');
    }

    // Précharger les fichiers si ce n'est pas déjà fait
    await preloadGoogleDriveFiles();

    // Rechercher dans le cache préchargé
    Map<String, dynamic>? fileInfo;

    if (_allGoogleDriveFiles != null) {
      for (final file in _allGoogleDriveFiles!) {
        if (file['id'] == fileId) {
          fileInfo = file;
          break;
        }
      }
    }

    // Si trouvé dans le cache, utiliser les vraies données
    if (fileInfo != null) {
      _logger.d('✅ Fichier trouvé dans le cache: ${fileInfo['name']}');

      return UnifiedResource(
        id: fileId,
        name: fileInfo['name'] ?? 'Document Google Drive',
        source: ResourceSource.googleDrive,
        viewUrl: _googleDriveService.getPreviewUrlDirect(fileId),
        downloadUrl: _googleDriveService.getDownloadUrl(fileId),
        mimeType: fileInfo['mimeType'],
        size: fileInfo['size'] != null
            ? int.tryParse(fileInfo['size'].toString())
            : null,
        createdTime: fileInfo['createdTime'] != null
            ? DateTime.tryParse(fileInfo['createdTime'])
            : null,
      );
    }

    // Si pas trouvé, utiliser un fallback avec l'ID
    _logger.w('Fichier $fileId non trouvé dans le cache, utilisation du fallback');

    return UnifiedResource(
      id: fileId,
      name: 'Document $fileId', // Utiliser l'ID comme nom
      source: ResourceSource.googleDrive,
      viewUrl: _googleDriveService.getPreviewUrlDirect(fileId),
      downloadUrl: _googleDriveService.getDownloadUrl(fileId),
    );
  }

  /// Récupère une ressource depuis Appwrite
  Future<UnifiedResource> _getAppwriteResource(String fileId) async {
    // Essayer de récupérer les infos du fichier depuis Appwrite
    final fileInfo = await _appwriteService.getFileInfo(fileId);

    final name = fileInfo?['name'] ?? 'Fichier Appwrite';
    final mimeType = fileInfo?['mimeType'];
    final size = fileInfo?['size'] is int
        ? fileInfo!['size'] as int
        : (fileInfo?['size'] != null
        ? int.tryParse(fileInfo!['size'].toString())
        : null);
    final created = fileInfo?['createdAt'] != null
        ? DateTime.tryParse(fileInfo!['createdAt'].toString())
        : null;

    return UnifiedResource(
      id: fileId,
      name: name,
      source: ResourceSource.appwrite,
      viewUrl: _appwriteService.getFileView(fileId),
      downloadUrl: _appwriteService.getFileDownload(fileId),
      mimeType: mimeType,
      size: size,
      createdTime: created,
    );
  }

  // ========== RÉCUPÉRATION DE PLUSIEURS RESSOURCES ==========

  /// Récupère plusieurs ressources à partir d'une liste d'identifiants
  /// Précharge Google Drive avant de traiter les ressources
  Future<List<UnifiedResource>> getResources(
      List<String> resourceIdentifiers,
      ) async {
    // Précharger Google Drive une seule fois pour tous les fichiers
    final hasGoogleDrive = resourceIdentifiers.any(
          (id) => _googleDriveService.isGoogleDriveUrl(id),
    );

    if (hasGoogleDrive) {
      await preloadGoogleDriveFiles();
    }

    final List<UnifiedResource> resources = [];

    for (final identifier in resourceIdentifiers) {
      try {
        final resource = await getResource(identifier);
        resources.add(resource);
      } catch (e) {
        _logger.w(
          'Erreur lors de la récupération de la ressource $identifier',
          error: e,
        );
        // On continue avec les autres ressources
      }
    }

    return resources;
  }

  // ========== CACHE ==========

  /// Vide le cache
  void clearCache() {
    _cache.clear();
    _allGoogleDriveFiles = null; // 🆕 Vider aussi le cache Google Drive
  }

  /// 🆕 NOUVEAU: Rafraîchir le cache Google Drive
  Future<void> refreshGoogleDriveCache() async {
    _allGoogleDriveFiles = null;
    await preloadGoogleDriveFiles();
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