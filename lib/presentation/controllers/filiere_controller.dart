import 'package:get/get.dart';
import '../../core/utils/logger.dart';
import '../../data/models/filiere_model.dart';
import '../../data/repositories/filiere_repository.dart';

class FiliereController extends GetxController {
  final FiliereRepository _repository = FiliereRepository();

  // États observables
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final filieres = <FiliereModel>[].obs;
  final departements = <FiliereModel>[].obs;
  final parcours = <FiliereModel>[].obs;
  final selectedFiliere = Rxn<FiliereModel>();
  final currentEcoleId = ''.obs;
  final errorMessage = ''.obs;

  /// Charge les filières d'un établissement
  Future<void> loadFilieresByEcole(
    String idEcole, {
    bool forceRefresh = false,
  }) async {
    try {
      if (forceRefresh) {
        isRefreshing.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';
      currentEcoleId.value = idEcole;

      // Charge toutes les filières
      final allFilieres = await _repository.getFilieresByEcole(
        idEcole,
        forceRefresh: forceRefresh,
      );

      // Sépare par type
      filieres.value = allFilieres;
      departements.value = allFilieres
          .where((f) => f.typeFiliere == 'departement')
          .toList();
      parcours.value = allFilieres
          .where((f) => f.typeFiliere == 'parcours')
          .toList();

      AppLogger.success(
        '${allFilieres.length} filières chargées pour école: $idEcole',
      );
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des filières';
      AppLogger.error('Erreur loadFilieresByEcole', e);
      Get.snackbar(
        'Erreur',
        'Impossible de charger les filières',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// Charge uniquement les départements
  Future<void> loadDepartements(
    String idEcole, {
    bool forceRefresh = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      currentEcoleId.value = idEcole;

      departements.value = await _repository.getDepartementsByEcole(
        idEcole,
        forceRefresh: forceRefresh,
      );

      AppLogger.success('${departements.length} départements chargés');
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des départements';
      AppLogger.error('Erreur loadDepartements', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Charge uniquement les parcours
  Future<void> loadParcours(String idEcole, {bool forceRefresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      currentEcoleId.value = idEcole;

      parcours.value = await _repository.getParcoursByEcole(
        idEcole,
        forceRefresh: forceRefresh,
      );

      AppLogger.success('${parcours.length} parcours chargés');
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des parcours';
      AppLogger.error('Erreur loadParcours', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Sélectionne une filière
  void selectFiliere(FiliereModel filiere) {
    selectedFiliere.value = filiere;
    AppLogger.info('Filière sélectionnée: ${filiere.nom}');
  }

  /// Désélectionne la filière
  void clearSelection() {
    selectedFiliere.value = null;
  }

  /// Charge une filière par ID
  Future<FiliereModel?> getFiliereById(
    String id, {
    bool forceRefresh = false,
  }) async {
    try {
      final filiere = await _repository.getFiliereById(
        id,
        forceRefresh: forceRefresh,
      );
      if (filiere != null) {
        selectedFiliere.value = filiere;
        currentEcoleId.value = filiere.idEcole;
      }
      return filiere;
    } catch (e) {
      AppLogger.error('Erreur getFiliereById', e);
      return null;
    }
  }

  /// Recherche de filières
  Future<List<FiliereModel>> searchFilieres(String query) async {
    try {
      if (query.isEmpty || currentEcoleId.value.isEmpty) {
        return [];
      }
      return await _repository.searchFilieres(currentEcoleId.value, query);
    } catch (e) {
      AppLogger.error('Erreur searchFilieres', e);
      return [];
    }
  }

  /// Filtre par type de licence
  List<FiliereModel> filterByTypeLicence(String typeLicence) {
    return filieres.where((f) => f.typeLicence.label == typeLicence).toList();
  }

  /// Compte les filières par type
  Future<Map<String, int>> getCountByType() async {
    try {
      if (currentEcoleId.value.isEmpty) {
        return {'departement': 0, 'parcours': 0};
      }
      return await _repository.countByType(currentEcoleId.value);
    } catch (e) {
      AppLogger.error('Erreur getCountByType', e);
      return {'departement': 0, 'parcours': 0};
    }
  }

  /// Rafraîchit les données
  @override
  Future<void> refresh() async {
    if (currentEcoleId.value.isNotEmpty) {
      await loadFilieresByEcole(currentEcoleId.value, forceRefresh: true);
    }
  }

  /// Vide le cache
  Future<void> clearCache() async {
    if (currentEcoleId.value.isNotEmpty) {
      await _repository.clearCache(currentEcoleId.value);
      await loadFilieresByEcole(currentEcoleId.value, forceRefresh: true);
    }
  }

  /// Réinitialise le controller
  void reset() {
    filieres.clear();
    departements.clear();
    parcours.clear();
    selectedFiliere.value = null;
    currentEcoleId.value = '';
    errorMessage.value = '';
  }

  // Getters pratiques
  int get totalFilieres => filieres.length;
  int get totalDepartements => departements.length;
  int get totalParcours => parcours.length;
  bool get hasData => totalFilieres > 0;
  bool get hasError => errorMessage.value.isNotEmpty;
  bool get hasDepartements => totalDepartements > 0;
  bool get hasParcours => totalParcours > 0;
}
