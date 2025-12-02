import 'package:equatable/equatable.dart';

/// Énumération des types de source de fichier
enum FileSourceType { appwrite, googleDrive }

/// Modèle unifié pour représenter un fichier, qu'il provienne d'Appwrite ou Google Drive
class FileResource extends Equatable {
  final String id; // ID Appwrite ou ID Google Drive
  final String name;
  final String url; // URL de visualisation
  final String downloadUrl; // URL de téléchargement
  final FileSourceType sourceType;
  final String? mimeType;
  final int? size; // en octets
  final String? description;

  const FileResource({
    required this.id,
    required this.name,
    required this.url,
    required this.downloadUrl,
    required this.sourceType,
    this.mimeType,
    this.size,
    this.description,
  });

  /// Crée un FileResource depuis Appwrite Storage
  factory FileResource.fromAppwrite({
    required String fileId,
    required String fileName,
    required String viewUrl,
    required String downloadUrl,
    String? mimeType,
    int? size,
  }) {
    return FileResource(
      id: fileId,
      name: fileName,
      url: viewUrl,
      downloadUrl: downloadUrl,
      sourceType: FileSourceType.appwrite,
      mimeType: mimeType,
      size: size,
    );
  }

  /// Crée un FileResource depuis Google Drive
  factory FileResource.fromGoogleDrive({
    required String fileId,
    required String fileName,
    required String previewUrl,
    required String downloadUrl,
    String? mimeType,
    int? size,
  }) {
    return FileResource(
      id: fileId,
      name: fileName,
      url: previewUrl,
      downloadUrl: downloadUrl,
      sourceType: FileSourceType.googleDrive,
      mimeType: mimeType,
      size: size,
    );
  }

  /// Vérifie si le fichier est un PDF
  bool get isPdf =>
      mimeType?.contains('pdf') ?? name.toLowerCase().endsWith('.pdf');

  /// Vérifie si le fichier est une image
  bool get isImage => mimeType?.startsWith('image/') ?? false;

  /// Vérifie si le fichier est un document
  bool get isDocument {
    if (mimeType == null) return false;
    return mimeType!.contains('document') ||
        mimeType!.contains('word') ||
        mimeType!.contains('text');
  }

  /// Retourne une taille formatée (KB, MB, GB)
  String get formattedSize {
    if (size == null) return 'Taille inconnue';

    if (size! < 1024) {
      return '$size B';
    } else if (size! < 1024 * 1024) {
      return '${(size! / 1024).toStringAsFixed(2)} KB';
    } else if (size! < 1024 * 1024 * 1024) {
      return '${(size! / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(size! / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Retourne l'icône appropriée selon le type de fichier
  String get fileIcon {
    if (isPdf) return '📄';
    if (isImage) return '🖼️';
    if (isDocument) return '📝';
    return '📁';
  }

  @override
  List<Object?> get props => [id, name, sourceType];

  @override
  String toString() {
    return 'FileResource(id: $id, name: $name, sourceType: $sourceType)';
  }
}
