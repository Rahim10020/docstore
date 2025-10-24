import 'package:get/get.dart';
import '../../core/utils/logger.dart';
import '../../data/models/ecole_model.dart';
import '../../data/repositories/ecole_repository.dart';

class EcoleController extends GetxController {
  final EcoleRepository _repository = EcoleRepository();

  // États observables
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final ecoles = <EcoleModel>[].obs;
  final facultes = <EcoleModel>[].obs;
  final instituts = <EcoleModel>[].obs;
  final selectedEcole = Rxn<EcoleModel>();
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadEcoles();
  }

  /// Charge tous les établissements
  Future<void> loadEcoles({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        isRefreshing.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      // Charge tous les établissements
      final allEcoles = await _repository.getAllEcoles(
        forceRefresh: forceRefresh,
      );

      // Sépare par type
      ecoles.value = allEcoles.where((e) => e.type.name == 'ecole').toList();
      facultes.value = allEcoles
          .where((e) => e.type.name == 'faculte')
          .toList();
      instituts.value = allEcoles
          .where((e) => e.type.name == 'institut')
          .toList();

      AppLogger.success('${allEcoles.length} établissements chargés');
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des établissements';
      AppLogger.error('Erreur loadEcoles', e);
      Get.snackbar(
        'Erreur',
        'Impossible de charger les établissements',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// Charge les écoles uniquement
  Future<void> loadOnlyEcoles({bool forceRefresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      ecoles.value = await _repository.getEcoles(forceRefresh: forceRefresh);

      AppLogger.success('${ecoles.length} écoles chargées');
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des écoles';
      AppLogger.error('Erreur loadOnlyEcoles', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Charge les facultés uniquement
  Future<void> loadOnlyFacultes({bool forceRefresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      facultes.value = await _repository.getFacultes(
        forceRefresh: forceRefresh,
      );

      AppLogger.success('${facultes.length} facultés chargées');
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des facultés';
      AppLogger.error('Erreur loadOnlyFacultes', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Charge les instituts uniquement
  Future<void> loadOnlyInstituts({bool forceRefresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      instituts.value = await _repository.getInstituts(
        forceRefresh: forceRefresh,
      );

      AppLogger.success('${instituts.length} instituts chargés');
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des instituts';
      AppLogger.error('Erreur loadOnlyInstituts', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Sélectionne un établissement
  void selectEcole(EcoleModel ecole) {
    selectedEcole.value = ecole;
    AppLogger.info('École sélectionnée: ${ecole.nom}');
  }

  /// Désélectionne l'établissement
  void clearSelection() {
    selectedEcole.value = null;
  }

  /// Charge un établissement par ID
  Future<EcoleModel?> getEcoleById(
    String id, {
    bool forceRefresh = false,
  }) async {
    try {
      final ecole = await _repository.getEcoleById(
        id,
        forceRefresh: forceRefresh,
      );
      if (ecole != null) {
        selectedEcole.value = ecole;
      }
      return ecole;
    } catch (e) {
      AppLogger.error('Erreur getEcoleById', e);
      return null;
    }
  }

  /// Recherche d'établissements
  Future<List<EcoleModel>> searchEcoles(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }
      return await _repository.searchEcoles(query);
    } catch (e) {
      AppLogger.error('Erreur searchEcoles', e);
      return [];
    }
  }

  /// Récupère les établissements avec concours
  Future<List<EcoleModel>> getEcolesAvecConcours() async {
    try {
      return await _repository.getEcolesAvecConcours();
    } catch (e) {
      AppLogger.error('Erreur getEcolesAvecConcours', e);
      return [];
    }
  }

  /// Compte les établissements par type
  Future<Map<String, int>> getCountByType() async {
    try {
      return await _repository.countByType();
    } catch (e) {
      AppLogger.error('Erreur getCountByType', e);
      return {'ecole': 0, 'faculte': 0, 'institut': 0};
    }
  }

  /// Rafraîchit les données
  @override
  Future<void> refresh() async {
    await loadEcoles(forceRefresh: true);
  }

  /// Vide le cache
  Future<void> clearCache() async {
    await _repository.clearCache();
    await loadEcoles(forceRefresh: true);
  }

  // Getters pratiques
  int get totalEcoles => ecoles.length;
  int get totalFacultes => facultes.length;
  int get totalInstituts => instituts.length;
  int get totalEtablissements => totalEcoles + totalFacultes + totalInstituts;
  bool get hasData => totalEtablissements > 0;
  bool get hasError => errorMessage.value.isNotEmpty;
}
