import 'package:get/get.dart';
import '../../core/utils/logger.dart';
import '../../core/enums/annee_enum.dart';
import '../../core/enums/semestre_enum.dart';
import '../../data/models/ue_model.dart';
import '../../data/repositories/ue_repository.dart';

class UeController extends GetxController {
  final UeRepository _repository = UeRepository();

  // États observables
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final ues = <UeModel>[].obs;
  final groupedByAnnee = <AnneeEnum, List<UeModel>>{}.obs;
  final selectedUe = Rxn<UeModel>();
  final currentFiliereId = ''.obs;
  final selectedAnnee = Rxn<AnneeEnum>();
  final selectedSemestre = Rxn<SemestreEnum>();
  final errorMessage = ''.obs;

  /// Charge les UEs d'une filière
  Future<void> loadUesByFiliere(
    String idFiliere, {
    bool forceRefresh = false,
  }) async {
    try {
      if (forceRefresh) {
        isRefreshing.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';
      currentFiliereId.value = idFiliere;

      // Charge toutes les UEs
      ues.value = await _repository.getUesByFiliere(
        idFiliere,
        forceRefresh: forceRefresh,
      );

      // Groupe par année
      groupedByAnnee.value = await _repository.groupUesByAnnee(
        idFiliere,
        forceRefresh: forceRefresh,
      );

      AppLogger.success('${ues.length} UEs chargées pour filière: $idFiliere');
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des UEs';
      AppLogger.error('Erreur loadUesByFiliere', e);
      Get.snackbar(
        'Erreur',
        'Impossible de charger les UEs',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// Charge les UEs d'une année spécifique
  Future<void> loadUesByAnnee(
    String idFiliere,
    AnneeEnum annee, {
    bool forceRefresh = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      currentFiliereId.value = idFiliere;
      selectedAnnee.value = annee;

      ues.value = await _repository.getUesByAnnee(
        idFiliere,
        annee,
        forceRefresh: forceRefresh,
      );

      AppLogger.success('${ues.length} UEs chargées pour ${annee.label}');
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des UEs';
      AppLogger.error('Erreur loadUesByAnnee', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Charge les UEs d'un semestre spécifique
  Future<void> loadUesBySemestre(
    String idFiliere,
    SemestreEnum semestre, {
    bool forceRefresh = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      currentFiliereId.value = idFiliere;
      selectedSemestre.value = semestre;

      ues.value = await _repository.getUesBySemestre(
        idFiliere,
        semestre,
        forceRefresh: forceRefresh,
      );

      AppLogger.success('${ues.length} UEs chargées pour ${semestre.label}');
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des UEs';
      AppLogger.error('Erreur loadUesBySemestre', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Charge les UEs par année et semestre
  Future<void> loadUesByAnneeAndSemestre(
    String idFiliere,
    AnneeEnum annee,
    SemestreEnum? semestre, {
    bool forceRefresh = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      currentFiliereId.value = idFiliere;
      selectedAnnee.value = annee;
      selectedSemestre.value = semestre;

      ues.value = await _repository.getUesByAnneeAndSemestre(
        idFiliere,
        annee,
        semestre,
        forceRefresh: forceRefresh,
      );

      AppLogger.success('${ues.length} UEs chargées');
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des UEs';
      AppLogger.error('Erreur loadUesByAnneeAndSemestre', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Sélectionne une UE
  void selectUe(UeModel ue) {
    selectedUe.value = ue;
    AppLogger.info('UE sélectionnée: ${ue.code} - ${ue.nom}');
  }

  /// Désélectionne l'UE
  void clearSelection() {
    selectedUe.value = null;
  }

  /// Charge une UE par ID
  Future<UeModel?> getUeById(String id, {bool forceRefresh = false}) async {
    try {
      final ue = await _repository.getUeById(id, forceRefresh: forceRefresh);
      if (ue != null) {
        selectedUe.value = ue;
        currentFiliereId.value = ue.idFiliere;
      }
      return ue;
    } catch (e) {
      AppLogger.error('Erreur getUeById', e);
      return null;
    }
  }

  /// Recherche d'UEs
  Future<List<UeModel>> searchUes(String query) async {
    try {
      if (query.isEmpty || currentFiliereId.value.isEmpty) {
        return [];
      }
      return await _repository.searchUes(currentFiliereId.value, query);
    } catch (e) {
      AppLogger.error('Erreur searchUes', e);
      return [];
    }
  }

  /// Filtre les UEs par année
  List<UeModel> filterByAnnee(AnneeEnum annee) {
    return ues.where((ue) => ue.annee == annee).toList();
  }

  /// Filtre les UEs par semestre
  List<UeModel> filterBySemestre(SemestreEnum semestre) {
    return ues.where((ue) => ue.semestre == semestre).toList();
  }

  /// Récupère les UEs d'une année depuis le groupement
  List<UeModel> getUesForAnnee(AnneeEnum annee) {
    return groupedByAnnee[annee] ?? [];
  }

  /// Calcule le total de crédits pour une année
  Future<int> getTotalCredits(AnneeEnum annee) async {
    try {
      if (currentFiliereId.value.isEmpty) return 0;
      return await _repository.getTotalCredits(currentFiliereId.value, annee);
    } catch (e) {
      AppLogger.error('Erreur getTotalCredits', e);
      return 0;
    }
  }

  /// Compte les UEs par année
  Future<Map<AnneeEnum, int>> getCountByAnnee() async {
    try {
      if (currentFiliereId.value.isEmpty) return {};
      return await _repository.countByAnnee(currentFiliereId.value);
    } catch (e) {
      AppLogger.error('Erreur getCountByAnnee', e);
      return {};
    }
  }

  /// Rafraîchit les données
  @override
  Future<void> refresh() async {
    if (currentFiliereId.value.isNotEmpty) {
      await loadUesByFiliere(currentFiliereId.value, forceRefresh: true);
    }
  }

  /// Vide le cache
  Future<void> clearCache() async {
    if (currentFiliereId.value.isNotEmpty) {
      await _repository.clearCache(currentFiliereId.value);
      await loadUesByFiliere(currentFiliereId.value, forceRefresh: true);
    }
  }

  /// Réinitialise le controller
  void reset() {
    ues.clear();
    groupedByAnnee.clear();
    selectedUe.value = null;
    currentFiliereId.value = '';
    selectedAnnee.value = null;
    selectedSemestre.value = null;
    errorMessage.value = '';
  }

  // Getters pratiques
  int get totalUes => ues.length;
  bool get hasData => totalUes > 0;
  bool get hasError => errorMessage.value.isNotEmpty;
  List<AnneeEnum> get availableAnnees => groupedByAnnee.keys.toList();
  int get numberOfAnnees => groupedByAnnee.length;
}
