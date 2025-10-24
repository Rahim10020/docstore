import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/download_service.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/ecole_repository.dart';
import '../../data/repositories/filiere_repository.dart';
import '../../data/repositories/ue_repository.dart';
import '../../data/repositories/concours_repository.dart';
import '../../data/repositories/file_repository.dart';

class SettingsController extends GetxController {
  final CacheService _cacheService = Get.find();
  final StorageService _storageService = Get.find();
  final DownloadService _downloadService = Get.find();

  // Repositories
  final EcoleRepository _ecoleRepo = EcoleRepository();
  final FiliereRepository _filiereRepo = FiliereRepository();
  final UeRepository _ueRepo = UeRepository();
  final ConcoursRepository _concoursRepo = ConcoursRepository();
  final FileRepository _fileRepo = FileRepository();

  // États observables
  final isLoading = false.obs;
  final cacheSize = 0.obs;
  final downloadSize = 0.obs;
  final numberOfCachedItems = 0.obs;
  final numberOfDownloads = 0.obs;

  // Préférences
  final autoDownloadOnWifi = true.obs;
  final notificationsEnabled = true.obs;
  final darkModeEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    calculateSizes();
  }

  /// Charge les paramètres sauvegardés
  Future<void> loadSettings() async {
    try {
      autoDownloadOnWifi.value =
          _storageService.getBool('auto_download_wifi') ?? true;
      notificationsEnabled.value =
          _storageService.getBool('notifications_enabled') ?? true;
      darkModeEnabled.value = _storageService.getBool('dark_mode') ?? false;

      AppLogger.info('Paramètres chargés');
    } catch (e) {
      AppLogger.error('Erreur loadSettings', e);
    }
  }

  /// Calcule les tailles du cache et des téléchargements
  Future<void> calculateSizes() async {
    try {
      // Taille du cache
      cacheSize.value = _cacheService.cacheSize;
      numberOfCachedItems.value = _cacheService.entryCount;

      // Taille des téléchargements
      downloadSize.value = await _downloadService.getTotalDownloadSize();
      final files = await _downloadService.listDownloadedFiles();
      numberOfDownloads.value = files.length;

      AppLogger.info(
        'Cache: ${_formatBytes(cacheSize.value)}, Téléchargements: ${_formatBytes(downloadSize.value)}',
      );
    } catch (e) {
      AppLogger.error('Erreur calculateSizes', e);
    }
  }

  /// Active/désactive le téléchargement auto sur WiFi
  Future<void> toggleAutoDownloadOnWifi(bool value) async {
    try {
      autoDownloadOnWifi.value = value;
      await _storageService.setBool('auto_download_wifi', value);
      AppLogger.info('Auto download WiFi: $value');
    } catch (e) {
      AppLogger.error('Erreur toggleAutoDownloadOnWifi', e);
    }
  }

  /// Active/désactive les notifications
  Future<void> toggleNotifications(bool value) async {
    try {
      notificationsEnabled.value = value;
      await _storageService.setBool('notifications_enabled', value);
      AppLogger.info('Notifications: $value');
    } catch (e) {
      AppLogger.error('Erreur toggleNotifications', e);
    }
  }

  /// Active/désactive le mode sombre
  Future<void> toggleDarkMode(bool value) async {
    try {
      darkModeEnabled.value = value;
      await _storageService.setBool('dark_mode', value);

      // Change le thème de l'app
      Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);

      AppLogger.info('Mode sombre: $value');
    } catch (e) {
      AppLogger.error('Erreur toggleDarkMode', e);
    }
  }

  /// Vide le cache
  Future<void> clearCache() async {
    try {
      isLoading.value = true;

      // Vide le cache de tous les repositories
      await Future.wait([
        _ecoleRepo.clearCache(),
        _filiereRepo.clearAllCache(),
        _ueRepo.clearAllCache(),
        _concoursRepo.clearAllCache(),
        _fileRepo.clearAllCache(),
      ]);

      // Vide le cache service
      await _cacheService.clear();

      // Recalcule les tailles
      await calculateSizes();

      Get.snackbar(
        'Cache vidé',
        'Le cache a été vidé avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );

      AppLogger.success('Cache vidé');
    } catch (e) {
      AppLogger.error('Erreur clearCache', e);
      Get.snackbar(
        'Erreur',
        'Impossible de vider le cache',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Supprime tous les téléchargements
  Future<void> clearDownloads() async {
    try {
      isLoading.value = true;

      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Supprimer les téléchargements'),
          content: const Text(
            'Voulez-vous vraiment supprimer tous les fichiers téléchargés ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Supprimer'),
            ),
          ],
        ),
      );

      if (result == true) {
        await _downloadService.clearAllDownloads();
        await calculateSizes();

        Get.snackbar(
          'Téléchargements supprimés',
          'Tous les fichiers ont été supprimés',
          snackPosition: SnackPosition.BOTTOM,
        );

        AppLogger.success('Téléchargements supprimés');
      }
    } catch (e) {
      AppLogger.error('Erreur clearDownloads', e);
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer les téléchargements',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Ouvre l'email de support
  Future<void> contactSupport() async {
    try {
      final uri = Uri(
        scheme: 'mailto',
        path: AppConstants.supportEmail,
        query: 'subject=Support DocStore',
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        AppLogger.info('Email de support ouvert');
      } else {
        throw Exception('Impossible d\'ouvrir l\'email');
      }
    } catch (e) {
      AppLogger.error('Erreur contactSupport', e);
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir l\'application email',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Ouvre le site web
  Future<void> openWebsite() async {
    await _openUrl(AppConstants.websiteUrl);
  }

  /// Ouvre la politique de confidentialité
  Future<void> openPrivacyPolicy() async {
    await _openUrl(AppConstants.privacyPolicyUrl);
  }

  /// Ouvre les conditions d'utilisation
  Future<void> openTerms() async {
    await _openUrl(AppConstants.termsUrl);
  }

  /// Ouvre une URL dans le navigateur
  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        AppLogger.info('URL ouverte: $url');
      } else {
        throw Exception('Impossible d\'ouvrir l\'URL');
      }
    } catch (e) {
      AppLogger.error('Erreur _openUrl', e);
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir le lien',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Partage l'application
  Future<void> shareApp() async {
    try {
      final text =
          '''
Découvrez DocStore - L'application pour accéder aux ressources académiques !

📚 Cours, devoirs, épreuves de concours
🎓 Toutes les facultés et écoles
🔍 Recherche rapide

Téléchargez maintenant: ${AppConstants.websiteUrl}
''';

      await Share.share(text);

      AppLogger.info('Application partagée');
    } catch (e) {
      AppLogger.error('Erreur shareApp', e);
      Get.snackbar(
        'Erreur',
        'Impossible de partager',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Affiche les informations de l'application
  void showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text(AppConstants.appName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: ${AppConstants.appVersion}'),
            const SizedBox(height: 16),
            const Text(
              'DocStore est une application mobile pour accéder facilement aux ressources académiques des établissements d\'enseignement supérieur du Togo.',
            ),
            const SizedBox(height: 16),
            const Text('© 2024 DocStore. Tous droits réservés.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Fermer')),
        ],
      ),
    );
  }

  /// Réinitialise tous les paramètres
  Future<void> resetAllSettings() async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Réinitialiser'),
          content: const Text(
            'Voulez-vous vraiment réinitialiser tous les paramètres ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Réinitialiser'),
            ),
          ],
        ),
      );

      if (result == true) {
        isLoading.value = true;

        // Réinitialise les préférences
        await toggleAutoDownloadOnWifi(true);
        await toggleNotifications(true);
        await toggleDarkMode(false);

        // Vide le cache et les téléchargements
        await clearCache();

        Get.snackbar(
          'Réinitialisé',
          'Tous les paramètres ont été réinitialisés',
          snackPosition: SnackPosition.BOTTOM,
        );

        AppLogger.success('Paramètres réinitialisés');
      }
    } catch (e) {
      AppLogger.error('Erreur resetAllSettings', e);
      Get.snackbar(
        'Erreur',
        'Impossible de réinitialiser',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Formate les bytes en format lisible
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Getters pratiques
  String get cacheSizeFormatted => _formatBytes(cacheSize.value);
  String get downloadSizeFormatted => _formatBytes(downloadSize.value);
  String get totalSizeFormatted =>
      _formatBytes(cacheSize.value + downloadSize.value);
}
