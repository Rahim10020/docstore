import 'package:get/get.dart';
import '../../core/utils/logger.dart';
import 'ecole_controller.dart';
import 'concours_controller.dart';

class HomeController extends GetxController {
  final EcoleController ecoleController = Get.find();
  final ConcoursController concoursController = Get.find();

  // États observables
  final isLoading = false.obs;
  final currentTabIndex = 0.obs;
  final errorMessage = ''.obs;

  // Statistiques
  final stats = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  /// Charge toutes les données de l'accueil
  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Charge les établissements et concours en parallèle
      await Future.wait([
        ecoleController.loadEcoles(),
        concoursController.loadAllConcours(),
      ]);

      // Calcule les statistiques
      await updateStats();

      AppLogger.success('Données d\'accueil chargées');
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement';
      AppLogger.error('Erreur loadHomeData', e);
      Get.snackbar(
        'Erreur',
        'Impossible de charger les données',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Met à jour les statistiques
  Future<void> updateStats() async {
    try {
      stats.value = {
        'ecoles': ecoleController.totalEcoles,
        'facultes': ecoleController.totalFacultes,
        'instituts': ecoleController.totalInstituts,
        'total_etablissements': ecoleController.totalEtablissements,
        'concours_en_cours': concoursController.totalEnCours,
        'concours_a_venir': concoursController.totalAVenir,
        'total_concours': concoursController.totalConcours,
      };

      AppLogger.info('Statistiques mises à jour: $stats');
    } catch (e) {
      AppLogger.error('Erreur updateStats', e);
    }
  }

  /// Change l'onglet actif
  void changeTab(int index) {
    currentTabIndex.value = index;
    AppLogger.debug('Onglet changé: $index');
  }

  /// Rafraîchit toutes les données
  @override
  Future<void> refresh() async {
    try {
      isLoading.value = true;

      await Future.wait([
        ecoleController.refresh(),
        concoursController.refresh(),
      ]);

      await updateStats();

      Get.snackbar(
        'Actualisation réussie',
        'Les données ont été mises à jour',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      AppLogger.error('Erreur refresh', e);
      Get.snackbar(
        'Erreur',
        'Impossible d\'actualiser les données',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigation vers les écoles
  void goToEcoles() {
    // Navigation GetX - à implémenter avec les routes
    AppLogger.info('Navigation vers écoles');
  }

  /// Navigation vers les facultés
  void goToFacultes() {
    AppLogger.info('Navigation vers facultés');
  }

  /// Navigation vers les instituts
  void goToInstituts() {
    AppLogger.info('Navigation vers instituts');
  }

  /// Navigation vers les concours
  void goToConcours() {
    AppLogger.info('Navigation vers concours');
  }

  /// Navigation vers la recherche
  void goToSearch() {
    AppLogger.info('Navigation vers recherche');
  }

  /// Navigation vers les paramètres
  void goToSettings() {
    AppLogger.info('Navigation vers paramètres');
  }

  // Getters pratiques
  int get totalEcoles => stats['ecoles'] ?? 0;
  int get totalFacultes => stats['facultes'] ?? 0;
  int get totalInstituts => stats['instituts'] ?? 0;
  int get totalEtablissements => stats['total_etablissements'] ?? 0;
  int get totalConcoursEnCours => stats['concours_en_cours'] ?? 0;
  int get totalConcoursAVenir => stats['concours_a_venir'] ?? 0;
  int get totalConcours => stats['total_concours'] ?? 0;
  bool get hasData => totalEtablissements > 0;
  bool get hasError => errorMessage.value.isNotEmpty;
}
