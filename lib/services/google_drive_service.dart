import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

/// Service pour interagir avec Google Drive via le backend
class GoogleDriveService {
  final Logger _logger = Logger();

  // URL du backend Vercel
  static const String backendUrl = 'https://docstore-api.vercel.app';

  // Timeout pour les requêtes
  static const Duration timeout = Duration(seconds: 10);

  /// Vérifie si une URL est une URL Google Drive
  bool isGoogleDriveUrl(String url) {
    return url.contains('drive.google.com') || url.contains('docs.google.com');
  }

  /// Extrait l'ID du fichier depuis une URL Google Drive
  String? extractFileIdFromUrl(String url) {
    // Patterns possibles:
    // https://drive.google.com/file/d/FILE_ID/view
    // https://drive.google.com/open?id=FILE_ID
    // https://docs.google.com/document/d/FILE_ID/edit

    final patterns = [
      RegExp(r'/file/d/([a-zA-Z0-9_-]+)'),
      RegExp(r'/folders/([a-zA-Z0-9_-]+)'),
      RegExp(r'/open\?id=([a-zA-Z0-9_-]+)'),
      RegExp(r'/document/d/([a-zA-Z0-9_-]+)'),
      RegExp(r'/spreadsheets/d/([a-zA-Z0-9_-]+)'),
      RegExp(r'/presentation/d/([a-zA-Z0-9_-]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }

    // Si aucun pattern ne correspond, peut-être que c'est déjà un ID
    if (url.length >= 25 && url.length <= 50 && !url.contains('/')) {
      return url;
    }

    return null;
  }

  /// Récupère les infos d'un fichier spécifique par ID
  /// Utilise l'endpoint /api/file/[id] pour une requête ciblée et rapide
  Future<Map<String, dynamic>?> getFileInfoFromId(String fileId) async {
    try {
      _logger.d('Récupération du fichier $fileId...');

      // Appel direct au fichier spécifique (beaucoup plus rapide !)
      final response = await http
          .get(Uri.parse('$backendUrl/api/file/$fileId'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['success'] == true && data['file'] != null) {
          final file = Map<String, dynamic>.from(data['file']);
          _logger.d('Fichier trouvé: ${file['name']}');
          return file;
        }
      } else if (response.statusCode == 404) {
        _logger.w('Fichier $fileId non trouvé (404)');
        return null;
      } else {
        _logger.e('Erreur HTTP ${response.statusCode}: ${response.body}');
        return null;
      }
    } on TimeoutException catch (e) {
      _logger.e('Timeout lors de la récupération du fichier $fileId', error: e);
      return null;
    } catch (e) {
      _logger.e('Erreur getFileInfoFromId pour $fileId', error: e);
      return null;
    }

    return null;
  }

  /// Récupère les informations d'un fichier depuis une URL
  Future<Map<String, dynamic>?> getFileInfoFromUrl(String url) async {
    final fileId = extractFileIdFromUrl(url);
    if (fileId == null) {
      _logger.w('Impossible d\'extraire l\'ID de l\'URL: $url');
      return null;
    }

    return getFileInfoFromId(fileId);
  }

  /// Liste tous les fichiers depuis le backend (utilisé uniquement si nécessaire)
  Future<List<Map<String, dynamic>>> listFiles() async {
    try {
      _logger.d('Récupération de tous les fichiers Google Drive...');

      final response = await http
          .get(Uri.parse('$backendUrl/api/files'))
          .timeout(Duration(seconds: 30)); // Timeout plus long pour cette requête

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['success'] == true) {
          final files = (data['files'] as List)
              .map((file) => Map<String, dynamic>.from(file))
              .toList();

          _logger.d('Fichiers récupérés: ${files.length}');
          return files;
        }
      }

      _logger.e('Erreur HTTP ${response.statusCode}');
      return [];
    } catch (e) {
      _logger.e('Erreur listFiles', error: e);
      return [];
    }
  }

  /// Obtient l'URL de prévisualisation directe
  String getPreviewUrlDirect(String fileId) {
    return 'https://drive.google.com/file/d/$fileId/preview';
  }

  /// Obtient l'URL de téléchargement
  String getDownloadUrl(String fileId) {
    return 'https://drive.google.com/uc?export=download&id=$fileId';
  }

  /// Obtient l'URL de visualisation
  String getViewUrl(String fileId) {
    return 'https://drive.google.com/file/d/$fileId/view';
  }
}