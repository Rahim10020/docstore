import 'package:get/get.dart';
import '../bindings/home_binding.dart';
import '../bindings/ecole_binding.dart';
import '../bindings/filiere_binding.dart';
import '../bindings/ue_binding.dart';
import '../bindings/concours_binding.dart';
import '../bindings/settings_binding.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/ecoles/ecoles_facultes_screen.dart';
import '../../presentation/screens/filieres/filieres_list_screen.dart';
import '../../presentation/screens/ues/ues_list_screen.dart';
import '../../presentation/screens/ues/ue_detail_screen.dart';
import '../../presentation/screens/concours/concours_list_screen.dart';
import '../../presentation/screens/concours/concours_detail_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/pdf_viewer/pdf_viewer_screen.dart';
import 'app_routes.dart';

/// Configuration de toutes les pages et leurs bindings
class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    // Splash Screen
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),

    // Home
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),

    // Écoles/Facultés/Instituts
    GetPage(
      name: AppRoutes.ecoles,
      page: () => const EcolesFacultesScreen(),
      binding: EcoleBinding(),
      transition: Transition.cupertino,
    ),

    GetPage(
      name: AppRoutes.ecoleDetail,
      page: () => const EcolesFacultesScreen(), // Détail école (à créer)
      binding: EcoleBinding(),
      transition: Transition.cupertino,
    ),

    // Filières
    GetPage(
      name: AppRoutes.filieres,
      page: () => const FilieresListScreen(),
      binding: FiliereBinding(),
      transition: Transition.cupertino,
    ),

    GetPage(
      name: AppRoutes.filiereDetail,
      page: () => const FilieresListScreen(), // Détail filière (à créer)
      binding: FiliereBinding(),
      transition: Transition.cupertino,
    ),

    // UEs
    GetPage(
      name: AppRoutes.ues,
      page: () => const UesListScreen(),
      binding: UeBinding(),
      transition: Transition.cupertino,
    ),

    GetPage(
      name: AppRoutes.ueDetail,
      page: () => const UeDetailScreen(),
      binding: UeBinding(),
      transition: Transition.cupertino,
    ),

    // Concours
    GetPage(
      name: AppRoutes.concours,
      page: () => const ConcoursListScreen(),
      binding: ConcoursBinding(),
      transition: Transition.cupertino,
    ),

    GetPage(
      name: AppRoutes.concoursDetail,
      page: () => const ConcoursDetailScreen(),
      binding: ConcoursBinding(),
      transition: Transition.cupertino,
    ),

    GetPage(
      name: AppRoutes.concoursByEcole,
      page: () => const ConcoursListScreen(),
      binding: ConcoursBinding(),
      transition: Transition.cupertino,
    ),

    // PDF Viewer
    GetPage(
      name: AppRoutes.pdfViewer,
      page: () => const PdfViewerScreen(),
      transition: Transition.cupertino,
    ),

    // Recherche
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchScreen(),
      binding: HomeBinding(), // Utilise le même binding que Home
      transition: Transition.downToUp,
    ),

    // Paramètres
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
      transition: Transition.cupertino,
    ),
  ];
}
