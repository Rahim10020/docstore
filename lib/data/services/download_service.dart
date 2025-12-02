import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../models/file_resource.dart';

class DownloadService {
  final Dio _dio = Dio();
  final Logger _logger = Logger();

  /// Télécharge un fichier depuis une URL ou un FileResource
  Future<String?> downloadFile({
    required String url,
    required String fileName,
    required Function(int, int) onProgress,
  }) async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        _logger.w('Storage permission denied');
        return null;
      }

      // Get downloads directory
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/docstore/downloads/$fileName';
      final file = File(filePath);

      // Create directory if not exists
      await file.parent.create(recursive: true);

      // Download file
      await _dio.download(url, filePath, onReceiveProgress: onProgress);

      _logger.i('File downloaded successfully: $filePath');
      return filePath;
    } catch (e) {
      _logger.e('Download error: $e');
      return null;
    }
  }

  /// Télécharge un fichier depuis un FileResource (Appwrite ou Google Drive)
  Future<String?> downloadFileResource({
    required FileResource fileResource,
    required Function(int, int) onProgress,
  }) async {
    try {
      // Utiliser l'URL de téléchargement appropriée
      final downloadUrl = fileResource.downloadUrl;
      final fileName = fileResource.name;

      _logger.i('Downloading ${fileResource.sourceType.name} file: $fileName');

      return await downloadFile(
        url: downloadUrl,
        fileName: fileName,
        onProgress: onProgress,
      );
    } catch (e) {
      _logger.e('Download error for FileResource: $e');
      return null;
    }
  }

  Future<bool> fileExists(String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/docstore/downloads/$fileName';
      return File(filePath).existsSync();
    } catch (e) {
      _logger.e('Error checking file: $e');
      return false;
    }
  }

  Future<String?> getLocalFilePath(String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/docstore/downloads/$fileName';
      final file = File(filePath);

      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      _logger.e('Error getting local file path: $e');
      return null;
    }
  }

  Future<void> deleteFile(String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/docstore/downloads/$fileName';
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        _logger.i('File deleted: $filePath');
      }
    } catch (e) {
      _logger.e('Error deleting file: $e');
    }
  }
}
