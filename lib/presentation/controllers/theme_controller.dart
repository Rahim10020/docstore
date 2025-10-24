import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/logger.dart';

class ThemeController extends GetxController {
  final StorageService _storageService = Get.find();

  // États observables
  final isDarkMode = false.obs;
  final themeMode = ThemeMode.light.obs;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  /// Charge le thème sauvegardé
  Future<void> loadTheme() async {
    try {
      final savedTheme = _storageService.getString('theme_mode');

      if (savedTheme != null) {
        switch (savedTheme) {
          case 'dark':
            setDarkMode();
            break;
          case 'light':
            setLightMode();
            break;
          case 'system':
            setSystemMode();
            break;
          default:
            setLightMode();
        }
      } else {
        setLightMode();
      }

      AppLogger.info('Thème chargé: ${themeMode.value}');
    } catch (e) {
      AppLogger.error('Erreur loadTheme', e);
      setLightMode();
    }
  }

  /// Active le mode sombre
  Future<void> setDarkMode() async {
    try {
      isDarkMode.value = true;
      themeMode.value = ThemeMode.dark;
      Get.changeThemeMode(ThemeMode.dark);
      await _storageService.setString('theme_mode', 'dark');
      AppLogger.info('Mode sombre activé');
    } catch (e) {
      AppLogger.error('Erreur setDarkMode', e);
    }
  }

  /// Active le mode clair
  Future<void> setLightMode() async {
    try {
      isDarkMode.value = false;
      themeMode.value = ThemeMode.light;
      Get.changeThemeMode(ThemeMode.light);
      await _storageService.setString('theme_mode', 'light');
      AppLogger.info('Mode clair activé');
    } catch (e) {
      AppLogger.error('Erreur setLightMode', e);
    }
  }

  /// Active le mode système
  Future<void> setSystemMode() async {
    try {
      themeMode.value = ThemeMode.system;
      Get.changeThemeMode(ThemeMode.system);

      // Détermine si le système est en mode sombre
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      isDarkMode.value = brightness == Brightness.dark;

      await _storageService.setString('theme_mode', 'system');
      AppLogger.info('Mode système activé');
    } catch (e) {
      AppLogger.error('Erreur setSystemMode', e);
    }
  }

  /// Bascule entre mode clair et sombre
  Future<void> toggleTheme() async {
    if (isDarkMode.value) {
      await setLightMode();
    } else {
      await setDarkMode();
    }
  }

  /// Vérifie si le thème actuel est sombre
  bool get isCurrentlyDark {
    if (themeMode.value == ThemeMode.system) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return isDarkMode.value;
  }

  /// Récupère la couleur primaire selon le thème
  Color get primaryColor {
    return isCurrentlyDark ? Colors.blue.shade300 : Colors.blue.shade700;
  }

  /// Récupère la couleur de fond selon le thème
  Color get backgroundColor {
    return isCurrentlyDark ? Colors.grey.shade900 : Colors.white;
  }

  /// Récupère la couleur du texte selon le thème
  Color get textColor {
    return isCurrentlyDark ? Colors.white : Colors.black;
  }

  /// Récupère la couleur secondaire du texte selon le thème
  Color get secondaryTextColor {
    return isCurrentlyDark ? Colors.grey.shade400 : Colors.grey.shade600;
  }

  /// Récupère la couleur des cartes selon le thème
  Color get cardColor {
    return isCurrentlyDark ? Colors.grey.shade800 : Colors.white;
  }

  /// Récupère la couleur de la surface selon le thème
  Color get surfaceColor {
    return isCurrentlyDark ? Colors.grey.shade800 : Colors.grey.shade50;
  }

  /// Récupère la couleur de divider selon le thème
  Color get dividerColor {
    return isCurrentlyDark ? Colors.grey.shade700 : Colors.grey.shade300;
  }
}
