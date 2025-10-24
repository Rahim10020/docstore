import 'package:docstore/presentation/controllers/theme_controller.dart';
import 'package:get/get.dart';
import '../../core/services/appwrite_service.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/download_service.dart';
import '../../core/utils/logger.dart';

/// Binding initial qui initialise tous les services globaux
/// Ce binding est chargé au démarrage de l'application
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    AppLogger.info('Initialisation des services globaux...');

    // Services core (Lazy singleton - créés quand ils sont utilisés)
    Get.lazyPut<StorageService>(() => StorageService(), fenix: true);
    Get.lazyPut<CacheService>(() => CacheService(), fenix: true);
    Get.lazyPut<AppwriteService>(() => AppwriteService(), fenix: true);
    Get.lazyPut<ConnectivityService>(() => ConnectivityService(), fenix: true);
    Get.lazyPut<DownloadService>(() => DownloadService(), fenix: true);

    // Controller global du thème
    Get.lazyPut<ThemeController>(() => ThemeController(), fenix: true);

    AppLogger.success('Services globaux initialisés');
  }
}
