import 'package:docstore/presentation/controllers/concours_controller.dart';
import 'package:docstore/presentation/controllers/ecole_controller.dart';
import 'package:docstore/presentation/controllers/home_controller.dart';
import 'package:docstore/presentation/controllers/search_controller.dart';
import 'package:get/get.dart';

/// Binding pour l'écran d'accueil
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Controllers nécessaires pour l'accueil
    Get.lazyPut<EcoleController>(() => EcoleController());
    Get.lazyPut<ConcoursController>(() => ConcoursController());
    Get.lazyPut<SearchController>(() => SearchController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
