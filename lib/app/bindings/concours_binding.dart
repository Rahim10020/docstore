import 'package:docstore/presentation/controllers/concours_controller.dart';
import 'package:get/get.dart';

/// Binding pour les écrans liés aux concours
class ConcoursBinding extends Bindings {
  @override
  void dependencies() {
    // ConcoursController (peut déjà exister depuis HomeBinding)
    if (!Get.isRegistered<ConcoursController>()) {
      Get.lazyPut<ConcoursController>(() => ConcoursController());
    }
  }
}
