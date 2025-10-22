import 'package:docstore/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

class Helpers {
  // Vérifier si c'est un lien Google Drive
  static bool isGoogleDriveLink(String url) {
    return url.contains(AppConstants.driveUrlPattern);
  }

  // Extraire l'ID du fichier Google Drive
  static String? extractDriveFileId(String url) {
    if (!isGoogleDriveLink(url)) return null;

    final regex = RegExp(r'/file/d/([a-zA-Z0-9_-]+)');
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  // Créer URL de téléchargement Google Drive
  static String getDriveDownloadUrl(String fileId) {
    return 'https://drive.google.com/uc?export=download&id=$fileId';
  }

  // Créer URL de preview Google Drive
  static String getDrivePreviewUrl(String fileId) {
    return 'https://drive.google.com/file/d/$fileId/preview';
  }

  // Formater la date
  static String formatDate(DateTime? date, {String format = 'dd/MM/yyyy'}) {
    if (date == null) return 'N/A';
    return DateFormat(format).format(date);
  }

  // Formater la taille du fichier
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Vérifier si le cache est expiré
  static bool isCacheExpired(DateTime? lastSync, int expirationHours) {
    if (lastSync == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    return difference.inHours >= expirationHours;
  }

  // Obtenir l'extension du fichier
  static String getFileExtension(String filename) {
    final parts = filename.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  // Vérifier si l'extension est supportée
  static bool isSupportedFileType(String filename) {
    final extension = getFileExtension(filename);
    return AppConstants.supportedFileExtensions.contains(extension);
  }
}
