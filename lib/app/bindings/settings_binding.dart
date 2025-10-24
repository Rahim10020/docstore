import 'package:docstore/presentation/controllers/settings_controller.dart';
import 'package:get/get.dart';

/// Binding pour l'écran des paramètres
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
