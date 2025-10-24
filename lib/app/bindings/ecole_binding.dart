import 'package:docstore/presentation/controllers/ecole_controller.dart';
import 'package:docstore/presentation/controllers/filiere_controller.dart';
import 'package:get/get.dart';

/// Binding pour les écrans liés aux établissements
class EcoleBinding extends Bindings {
  @override
  void dependencies() {
    // EcoleController (peut déjà exister depuis HomeBinding)
    if (!Get.isRegistered<EcoleController>()) {
      Get.lazyPut<EcoleController>(() => EcoleController());
    }

    // FiliereController pour afficher les filières d'un établissement
    Get.lazyPut<FiliereController>(() => FiliereController());
  }
}
