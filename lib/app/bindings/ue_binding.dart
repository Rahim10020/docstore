import 'package:docstore/presentation/controllers/ue_controller.dart';
import 'package:get/get.dart';

/// Binding pour les écrans liés aux UEs
class UeBinding extends Bindings {
  @override
  void dependencies() {
    // UeController (peut déjà exister depuis FiliereBinding)
    if (!Get.isRegistered<UeController>()) {
      Get.lazyPut<UeController>(() => UeController());
    }
  }
}
