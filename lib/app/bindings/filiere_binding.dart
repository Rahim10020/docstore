import 'package:docstore/presentation/controllers/filiere_controller.dart';
import 'package:docstore/presentation/controllers/ue_controller.dart';
import 'package:get/get.dart';

/// Binding pour les écrans liés aux filières
class FiliereBinding extends Bindings {
  @override
  void dependencies() {
    // FiliereController (peut déjà exister depuis EcoleBinding)
    if (!Get.isRegistered<FiliereController>()) {
      Get.lazyPut<FiliereController>(() => FiliereController());
    }

    // UeController pour afficher les UEs d'une filière
    Get.lazyPut<UeController>(() => UeController());
  }
}
