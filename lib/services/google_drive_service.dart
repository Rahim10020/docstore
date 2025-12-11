import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

/// Service pour interagir avec Google Drive via le backend
class GoogleDriveService {
  // Singleton pattern
  static final GoogleDriveService _instance = GoogleDriveService._internal();
  factory GoogleDriveService() => _instance;
  GoogleDriveService._internal();

  // Logger
  final Logger _logger = Logger();

  // URL du backend Vercel
  static const String backendUrl = 'https://docstore-api.vercel.app';

  // Timeout par défaut
  static const Duration _timeout = Duration(seconds: 10);

  // ========== LISTER LES FICHIERS ==========

  /// Récupère la liste de tous les fichiers sur Google Drive
  Future<List<Map<String, dynamic>>> listFiles() async {
    try {
      final response = await http
          .get(Uri.parse('$backendUrl/api/files'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['files'] != null) {
          return List<Map<String, dynamic>>.from(data['files']);
        }
        return [];
      } else {
        throw Exception(
          'Erreur lors de la récupération des fichiers: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.e('Erreur listFiles', error: e);
      rethrow;
    }
  }

  // ========== EXTRAIRE L'ID DEPUIS L'URL ==========

  /// Extrait l'ID du fichier depuis une URL Google Drive
  /// Formats supportés:
  /// - https://drive.google.com/file/d/FILE_ID/...
  /// - https://drive.google.com/open?id=FILE_ID
  String? extractFileIdFromUrl(String url) {
    try {
      // Format: /file/d/FILE_ID/
      final regex1 = RegExp(r'/file/d/([a-zA-Z0-9_-]+)');
      final match1 = regex1.firstMatch(url);
      if (match1 != null) {
        return match1.group(1);
      }

      // Format: ?id=FILE_ID
      final regex2 = RegExp(r'[?&]id=([a-zA-Z0-9_-]+)');
      final match2 = regex2.firstMatch(url);
      if (match2 != null) {
        return match2.group(1);
      }

      return null;
    } catch (e) {
      _logger.e('Erreur extractFileIdFromUrl', error: e);
      return null;
    }
  }

  // ========== PRÉVISUALISATION ==========

  /// Récupère l'URL de prévisualisation d'un fichier
  Future<String?> getPreviewUrl(String fileId) async {
    try {
      final response = await http
          .get(Uri.parse('$backendUrl/api/preview?id=$fileId'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['url'] != null) {
          return data['url'];
        }
      }
      return null;
    } catch (e) {
      _logger.e('Erreur getPreviewUrl', error: e);
      return null;
    }
  }

  /// Génère l'URL de prévisualisation directement (sans appel API)
  String getPreviewUrlDirect(String fileId) {
    return 'https://drive.google.com/file/d/$fileId/preview';
  }

  // ========== TÉLÉCHARGEMENT ==========

  /// Récupère l'URL de téléchargement d'un fichier
  String getDownloadUrl(String fileId) {
    return '$backendUrl/api/download?id=$fileId';
  }

  // ========== UPLOAD ==========

  /// Upload un fichier vers Google Drive
  Future<Map<String, dynamic>?> uploadFile({
    required String name,
    required String mimeType,
    required String base64Data,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$backendUrl/api/upload'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'mimeType': mimeType,
              'data': base64Data,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['file'] != null) {
          return data['file'];
        }
      }
      return null;
    } catch (e) {
      _logger.e('Erreur uploadFile', error: e);
      rethrow;
    }
  }

  // ========== SUPPRESSION ==========

  /// Supprime un fichier de Google Drive
  Future<bool> deleteFile(String fileId) async {
    try {
      final response = await http
          .delete(Uri.parse('$backendUrl/api/delete?id=$fileId'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      _logger.e('Erreur deleteFile', error: e);
      return false;
    }
  }

  // ========== HELPERS ==========

  /// Vérifie si une URL est une URL Google Drive
  bool isGoogleDriveUrl(String url) {
    return url.contains('drive.google.com');
  }

  /// Obtient les informations d'un fichier depuis son URL
  Future<Map<String, dynamic>?> getFileInfoFromUrl(String url) async {
    final fileId = extractFileIdFromUrl(url);
    if (fileId == null) return null;

    try {
      final files = await listFiles();
      try {
        return files.firstWhere((file) => file['id'] == fileId);
      } catch (e) {
        // Aucun fichier trouvé
        return null;
      }
    } catch (e) {
      _logger.e('Erreur getFileInfoFromUrl', error: e);
      return null;
    }
  }
}
