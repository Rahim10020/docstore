import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';
import 'connectivity_service.dart';

class DownloadService extends GetxService {
  final Dio _dio = Dio();
  final ConnectivityService _connectivityService = Get.find();

  // Map pour tracker les téléchargements en cours
  final RxMap<String, double> downloadProgress = <String, double>{}.obs;
  final RxMap<String, CancelToken> cancelTokens = <String, CancelToken>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _configureDio();
  }

  void _configureDio() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      followRedirects: true,
      validateStatus: (status) => status! < 500,
    );
  }

  /// Vérifie et demande les permissions de stockage
  Future<bool> checkStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        final androidVersion = await _getAndroidVersion();

        // Android 13+ (API 33+) n'a pas besoin de permission pour Downloads
        if (androidVersion >= 33) {
          return true;
        }

        // Android 10-12 (API 29-32)
        if (androidVersion >= 29) {
          return true; // Scoped storage activé par défaut
        }

        // Android < 10 (API < 29)
        final status = await Permission.storage.status;
        if (status.isGranted) return true;

        final result = await Permission.storage.request();
        return result.isGranted;
      }

      // iOS ne nécessite pas de permission spéciale pour Downloads
      return true;
    } catch (e) {
      AppLogger.error('Erreur vérification permissions', e);
      return false;
    }
  }

  Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;

    try {
      // Récupère la version Android SDK
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    } catch (e) {
      return 0;
    }
  }

  /// Récupère le dossier de téléchargement
  Future<Directory> getDownloadDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Sur Android, utilise le dossier Downloads public
        final directory = Directory(
          '/storage/emulated/0/Download/${AppConstants.downloadFolderName}',
        );
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        return directory;
      } else if (Platform.isIOS) {
        // Sur iOS, utilise le dossier Documents de l'app
        final directory = await getApplicationDocumentsDirectory();
        final downloadDir = Directory(
          '${directory.path}/${AppConstants.downloadFolderName}',
        );
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        return downloadDir;
      } else {
        // Fallback pour autres plateformes
        return await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      AppLogger.error('Erreur getDownloadDirectory', e);
      rethrow;
    }
  }

  /// Télécharge un fichier
  Future<String?> downloadFile({
    required String url,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    // Vérifie la connexion
    if (!_connectivityService.isConnected.value) {
      Get.snackbar(
        'Pas de connexion',
        'Veuillez vérifier votre connexion internet',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    // Vérifie les permissions
    final hasPermission = await checkStoragePermission();
    if (!hasPermission) {
      Get.snackbar(
        'Permission refusée',
        'Accordez la permission de stockage pour télécharger',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    try {
      final directory = await getDownloadDirectory();
      final filePath = '${directory.path}/$fileName';

      // Vérifie si le fichier existe déjà
      final file = File(filePath);
      if (await file.exists()) {
        AppLogger.info('Fichier déjà téléchargé: $fileName');
        return filePath;
      }

      // Crée un CancelToken pour pouvoir annuler le téléchargement
      final cancelToken = CancelToken();
      cancelTokens[fileName] = cancelToken;

      // Lance le téléchargement
      await _dio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            downloadProgress[fileName] = progress;
            onProgress?.call(progress);
          }
        },
      );

      // Nettoie
      downloadProgress.remove(fileName);
      cancelTokens.remove(fileName);

      AppLogger.info('Téléchargement réussi: $fileName');

      Get.snackbar(
        'Téléchargement terminé',
        fileName,
        snackPosition: SnackPosition.BOTTOM,
      );

      return filePath;
    } on DioException catch (e) {
      downloadProgress.remove(fileName);
      cancelTokens.remove(fileName);

      if (e.type == DioExceptionType.cancel) {
        AppLogger.info('Téléchargement annulé: $fileName');
        Get.snackbar(
          'Téléchargement annulé',
          fileName,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        AppLogger.error('Erreur téléchargement: $fileName', e);
        Get.snackbar(
          'Erreur de téléchargement',
          'Impossible de télécharger le fichier',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return null;
    } catch (e) {
      downloadProgress.remove(fileName);
      cancelTokens.remove(fileName);

      AppLogger.error('Erreur téléchargement: $fileName', e);
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  /// Annule un téléchargement en cours
  void cancelDownload(String fileName) {
    final cancelToken = cancelTokens[fileName];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('Annulé par l\'utilisateur');
      downloadProgress.remove(fileName);
      cancelTokens.remove(fileName);
      AppLogger.info('Téléchargement annulé: $fileName');
    }
  }

  /// Vérifie si un fichier est en cours de téléchargement
  bool isDownloading(String fileName) {
    return downloadProgress.containsKey(fileName);
  }

  /// Récupère le progrès d'un téléchargement
  double? getProgress(String fileName) {
    return downloadProgress[fileName];
  }

  /// Vérifie si un fichier existe déjà
  Future<bool> fileExists(String fileName) async {
    try {
      final directory = await getDownloadDirectory();
      final file = File('${directory.path}/$fileName');
      return await file.exists();
    } catch (e) {
      AppLogger.error('Erreur fileExists', e);
      return false;
    }
  }

  /// Récupère le chemin d'un fichier téléchargé
  Future<String?> getFilePath(String fileName) async {
    try {
      final directory = await getDownloadDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      AppLogger.error('Erreur getFilePath', e);
      return null;
    }
  }

  /// Supprime un fichier téléchargé
  Future<bool> deleteFile(String fileName) async {
    try {
      final directory = await getDownloadDirectory();
      final file = File('${directory.path}/$fileName');

      if (await file.exists()) {
        await file.delete();
        AppLogger.info('Fichier supprimé: $fileName');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Erreur deleteFile', e);
      return false;
    }
  }

  /// Récupère la taille d'un fichier
  Future<int?> getFileSize(String fileName) async {
    try {
      final directory = await getDownloadDirectory();
      final file = File('${directory.path}/$fileName');

      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      AppLogger.error('Erreur getFileSize', e);
      return null;
    }
  }

  /// Liste tous les fichiers téléchargés
  Future<List<FileSystemEntity>> listDownloadedFiles() async {
    try {
      final directory = await getDownloadDirectory();
      return directory.listSync();
    } catch (e) {
      AppLogger.error('Erreur listDownloadedFiles', e);
      return [];
    }
  }

  /// Calcule l'espace total utilisé par les téléchargements
  Future<int> getTotalDownloadSize() async {
    try {
      final files = await listDownloadedFiles();
      int totalSize = 0;

      for (final entity in files) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      AppLogger.error('Erreur getTotalDownloadSize', e);
      return 0;
    }
  }

  /// Supprime tous les fichiers téléchargés
  Future<bool> clearAllDownloads() async {
    try {
      final directory = await getDownloadDirectory();
      final files = directory.listSync();

      for (final file in files) {
        await file.delete();
      }

      AppLogger.info('Tous les téléchargements supprimés');
      return true;
    } catch (e) {
      AppLogger.error('Erreur clearAllDownloads', e);
      return false;
    }
  }
}
