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
  static const Duration timeout = Duration(seconds: 20);

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

  /// Liste tous les fichiers depuis le backend
  Future<List<Map<String, dynamic>>> listFiles() async {
    try {
      _logger.d('🔍 Récupération de tous les fichiers Google Drive...');

      final response = await http
          .get(Uri.parse('$backendUrl/api/files'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['success'] == true) {
          final files = (data['files'] as List)
              .map((file) => Map<String, dynamic>.from(file))
              .toList();

          _logger.d('🐛 Fichiers récupérés: ${files.length}');

          // Logs de debug pour voir les fichiers
          for (final file in files) {
            _logger.d('🐛 Fichier: ${file['name']} (ID: ${file['id']})');
          }

          return files;
        }
      }

      _logger.e('❌ Erreur HTTP ${response.statusCode}: ${response.body}');
      return [];
    } on TimeoutException catch (e) {
      _logger.e('⛔ Timeout lors de la récupération des fichiers', error: e);
      return [];
    } catch (e) {
      _logger.e('⛔ Erreur listFiles', error: e);
      return [];
    }
  }

  /// 🆕 NOUVELLE MÉTHODE: Récupère les infos d'un fichier spécifique par ID
  /// Cette méthode interroge le backend pour obtenir les métadonnées
  Future<Map<String, dynamic>?> getFileInfoFromId(String fileId) async {
    try {
      _logger.d('🔍 Recherche du fichier $fileId dans le backend...');

      // Appeler le backend pour récupérer TOUS les fichiers
      final response = await http
          .get(Uri.parse('$backendUrl/api/files'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['success'] == true) {
          final files = data['files'] as List;

          // Chercher le fichier par ID
          for (final file in files) {
            if (file is Map && file['id'] == fileId) {
              _logger.d('✅ Fichier trouvé: ${file['name']}');
              return Map<String, dynamic>.from(file);
            }
          }

          _logger.w('Fichier $fileId non trouvé dans les ${files.length} fichiers retournés');
        }
      }

      return null;
    } on TimeoutException catch (e) {
      _logger.e('⛔ Timeout lors de la recherche du fichier $fileId', error: e);
      return null;
    } catch (e) {
      _logger.e('⛔ Erreur getFileInfoFromId pour $fileId', error: e);
      return null;
    }
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