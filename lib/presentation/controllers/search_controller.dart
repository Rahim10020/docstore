import 'package:get/get.dart';
import '../../core/utils/logger.dart';
import '../../data/models/ecole_model.dart';
import '../../data/models/filiere_model.dart';
import '../../data/models/ue_model.dart';
import '../../data/models/concours_model.dart';
import 'ecole_controller.dart';
import 'filiere_controller.dart';
import 'ue_controller.dart';
import 'concours_controller.dart';

class SearchController extends GetxController {
  final EcoleController _ecoleController = Get.find();
  final FiliereController _filiereController = Get.find();
  final UeController _ueController = Get.find();
  final ConcoursController _concoursController = Get.find();

  // États observables
  final isSearching = false.obs;
  final searchQuery = ''.obs;
  final selectedCategory = 'Tout'.obs;

  // Résultats de recherche
  final ecoleResults = <EcoleModel>[].obs;
  final filiereResults = <FiliereModel>[].obs;
  final ueResults = <UeModel>[].obs;
  final concoursResults = <ConcoursModel>[].obs;

  // Historique de recherche
  final searchHistory = <String>[].obs;
  final maxHistorySize = 10;

  // Catégories disponibles
  final categories = ['Tout', 'Établissements', 'Filières', 'UEs', 'Concours'];

  @override
  void onInit() {
    super.onInit();
    loadSearchHistory();
  }

  /// Effectue une recherche globale
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      clearResults();
      return;
    }

    try {
      isSearching.value = true;
      searchQuery.value = query;

      // Ajoute à l'historique
      addToHistory(query);

      // Recherche selon la catégorie
      switch (selectedCategory.value) {
        case 'Tout':
          await searchAll(query);
          break;
        case 'Établissements':
          await searchEcoles(query);
          break;
        case 'Filières':
          await searchFilieres(query);
          break;
        case 'UEs':
          await searchUes(query);
          break;
        case 'Concours':
          await searchConcours(query);
          break;
      }

      AppLogger.info(
        'Recherche effectuée: "$query" (${selectedCategory.value})',
      );
    } catch (e) {
      AppLogger.error('Erreur search', e);
      Get.snackbar(
        'Erreur',
        'Erreur lors de la recherche',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSearching.value = false;
    }
  }

  /// Recherche dans toutes les catégories
  Future<void> searchAll(String query) async {
    await Future.wait([
      searchEcoles(query),
      searchFilieres(query),
      searchUes(query),
      searchConcours(query),
    ]);
  }

  /// Recherche d'établissements
  Future<void> searchEcoles(String query) async {
    try {
      ecoleResults.value = await _ecoleController.searchEcoles(query);
      AppLogger.debug('${ecoleResults.length} établissements trouvés');
    } catch (e) {
      AppLogger.error('Erreur searchEcoles', e);
      ecoleResults.clear();
    }
  }

  /// Recherche de filières
  Future<void> searchFilieres(String query) async {
    try {
      // Note: Nécessite un idEcole, donc recherche limitée
      if (_filiereController.currentEcoleId.value.isNotEmpty) {
        filiereResults.value = await _filiereController.searchFilieres(query);
        AppLogger.debug('${filiereResults.length} filières trouvées');
      } else {
        filiereResults.clear();
      }
    } catch (e) {
      AppLogger.error('Erreur searchFilieres', e);
      filiereResults.clear();
    }
  }

  /// Recherche d'UEs
  Future<void> searchUes(String query) async {
    try {
      // Note: Nécessite un idFiliere, donc recherche limitée
      if (_ueController.currentFiliereId.value.isNotEmpty) {
        ueResults.value = await _ueController.searchUes(query);
        AppLogger.debug('${ueResults.length} UEs trouvées');
      } else {
        ueResults.clear();
      }
    } catch (e) {
      AppLogger.error('Erreur searchUes', e);
      ueResults.clear();
    }
  }

  /// Recherche de concours
  Future<void> searchConcours(String query) async {
    try {
      concoursResults.value = await _concoursController.searchConcours(query);
      AppLogger.debug('${concoursResults.length} concours trouvés');
    } catch (e) {
      AppLogger.error('Erreur searchConcours', e);
      concoursResults.clear();
    }
  }

  /// Change la catégorie de recherche
  void changeCategory(String category) {
    selectedCategory.value = category;
    if (searchQuery.value.isNotEmpty) {
      search(searchQuery.value);
    }
    AppLogger.debug('Catégorie changée: $category');
  }

  /// Vide les résultats de recherche
  void clearResults() {
    ecoleResults.clear();
    filiereResults.clear();
    ueResults.clear();
    concoursResults.clear();
    searchQuery.value = '';
  }

  /// Ajoute une recherche à l'historique
  void addToHistory(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    // Supprime si déjà présent
    searchHistory.remove(trimmedQuery);

    // Ajoute au début
    searchHistory.insert(0, trimmedQuery);

    // Limite la taille
    if (searchHistory.length > maxHistorySize) {
      searchHistory.removeRange(maxHistorySize, searchHistory.length);
    }

    saveSearchHistory();
  }

  /// Supprime une entrée de l'historique
  void removeFromHistory(String query) {
    searchHistory.remove(query);
    saveSearchHistory();
  }

  /// Vide l'historique de recherche
  void clearHistory() {
    searchHistory.clear();
    saveSearchHistory();
    AppLogger.info('Historique de recherche vidé');
  }

  /// Charge l'historique de recherche depuis le storage
  Future<void> loadSearchHistory() async {
    try {
      // TODO: Charger depuis StorageService
      // final history = await storageService.getStringList('search_history');
      // if (history != null) {
      //   searchHistory.value = history;
      // }
      AppLogger.debug('Historique de recherche chargé');
    } catch (e) {
      AppLogger.error('Erreur loadSearchHistory', e);
    }
  }

  /// Sauvegarde l'historique de recherche
  Future<void> saveSearchHistory() async {
    try {
      // TODO: Sauvegarder dans StorageService
      // await storageService.setStringList('search_history', searchHistory);
      AppLogger.debug('Historique de recherche sauvegardé');
    } catch (e) {
      AppLogger.error('Erreur saveSearchHistory', e);
    }
  }

  // Getters pratiques
  int get totalResults {
    return ecoleResults.length +
        filiereResults.length +
        ueResults.length +
        concoursResults.length;
  }

  bool get hasResults => totalResults > 0;
  bool get hasEcoleResults => ecoleResults.isNotEmpty;
  bool get hasFiliereResults => filiereResults.isNotEmpty;
  bool get hasUeResults => ueResults.isNotEmpty;
  bool get hasConcoursResults => concoursResults.isNotEmpty;
  bool get hasHistory => searchHistory.isNotEmpty;
}
