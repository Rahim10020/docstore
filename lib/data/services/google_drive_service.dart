import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class GoogleDriveService {
  final Logger _logger = Logger();
  static const String _apiEndpoint =
      'https://biblio-epl.vercel.app/api/google-drive';

  /// Vérifie si une URL est un lien Google Drive
  bool isGoogleDriveUrl(String url) {
    return url.contains('drive.google.com') || url.contains('docs.google.com');
  }

  /// Extrait l'ID d'un fichier Google Drive depuis son URL
  /// Format: https://drive.google.com/file/d/{FILE_ID}/view
  String? extractFileId(String url) {
    try {
      if (!isGoogleDriveUrl(url)) {
        return null;
      }

      // Pattern: /d/{ID}/ ou /d/{ID}?
      final regex = RegExp(r'/d/([a-zA-Z0-9_-]+)');
      final match = regex.firstMatch(url);

      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }

      return null;
    } catch (e) {
      _logger.e('Error extracting file ID: $e');
      return null;
    }
  }

  /// Génère l'URL de prévisualisation Google Drive
  String getPreviewUrl(String fileId) {
    return 'https://drive.google.com/file/d/$fileId/preview';
  }

  /// Génère l'URL de téléchargement Google Drive
  String getDownloadUrl(String fileId) {
    return 'https://drive.google.com/uc?export=download&id=$fileId';
  }

  /// Récupère les métadonnées d'un fichier Google Drive via l'API backend
  /// Retourne un Map avec les informations du fichier ou null en cas d'erreur
  /// Includes retry logic and fallback for timeout scenarios
  Future<Map<String, dynamic>?> getFileMetadata(String driveUrl) async {
    const maxRetries = 2;
    const timeoutDuration = Duration(seconds: 15);

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final encodedUrl = Uri.encodeComponent(driveUrl);
        final apiUrl = '$_apiEndpoint?url=$encodedUrl';

        _logger.d(
          'Fetching metadata (attempt ${attempt + 1}/$maxRetries) for: $driveUrl',
        );

        final response = await http
            .get(Uri.parse(apiUrl), headers: {'Accept': 'application/json'})
            .timeout(timeoutDuration);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['success'] == true && data['fileInfo'] != null) {
            _logger.i('Successfully fetched metadata from API');
            return data['fileInfo'] as Map<String, dynamic>;
          } else if (data['error'] != null) {
            _logger.w('API error: ${data['error']}');
            return {
              'name': data['name'] ?? 'Document Google Drive',
              'id': extractFileId(driveUrl),
            };
          }
        }

        _logger.w('Failed to fetch metadata: ${response.statusCode}');
        return null;
      } on TimeoutException catch (e) {
        _logger.w('Timeout on attempt ${attempt + 1}/$maxRetries: $e');
        if (attempt == maxRetries - 1) {
          // Last attempt failed, return minimal metadata as fallback
          _logger.e('All metadata fetch attempts timed out. Using fallback.');
          return _getFallbackMetadata(driveUrl);
        }
        // Wait before retrying
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        _logger.e('Error fetching file metadata (attempt ${attempt + 1}): $e');
        if (attempt == maxRetries - 1) {
          // Return minimal metadata as fallback
          return _getFallbackMetadata(driveUrl);
        }
      }
    }

    return null;
  }

  /// Returns minimal metadata when API fetch fails
  Map<String, dynamic> _getFallbackMetadata(String driveUrl) {
    final fileId = extractFileId(driveUrl);
    return {'name': 'Document Google Drive', 'id': fileId, 'fallback': true};
  }

  /// Récupère le nom d'un fichier Google Drive
  /// Utilise l'API si disponible, sinon retourne un nom par défaut
  Future<String> getFileName(String driveUrl) async {
    final metadata = await getFileMetadata(driveUrl);
    if (metadata != null && metadata['name'] != null) {
      return metadata['name'] as String;
    }

    final fileId = extractFileId(driveUrl);
    return 'Document Google Drive ${fileId ?? ''}';
  }

  /// Récupère la taille d'un fichier Google Drive en octets
  Future<int?> getFileSize(String driveUrl) async {
    final metadata = await getFileMetadata(driveUrl);
    if (metadata != null && metadata['size'] != null) {
      return int.tryParse(metadata['size'].toString());
    }
    return null;
  }

  /// Récupère le type MIME d'un fichier Google Drive
  Future<String?> getMimeType(String driveUrl) async {
    final metadata = await getFileMetadata(driveUrl);
    if (metadata != null && metadata['mimeType'] != null) {
      return metadata['mimeType'] as String;
    }
    return null;
  }
}
