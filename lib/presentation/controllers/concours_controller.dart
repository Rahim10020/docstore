import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/logger.dart';
import '../../core/enums/statut_concours.dart';
import '../../data/models/concours_model.dart';
import '../../data/repositories/concours_repository.dart';

class ConcoursController extends GetxController {
  final ConcoursRepository _repository = ConcoursRepository();

  // États observables
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final concours = <ConcoursModel>[].obs;
  final concoursEnCours = <ConcoursModel>[].obs;
  final concoursAVenir = <ConcoursModel>[].obs;
  final concoursTermines = <ConcoursModel>[].obs;
  final selectedConcours = Rxn<ConcoursModel>();
  final currentEcoleId = ''.obs;
  final errorMessage = ''.obs;

  /// Charge tous les concours
  Future<void> loadAllConcours({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        isRefreshing.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      // Charge tous les concours
      final allConcours = await _repository.getAllConcours(
        forceRefresh: forceRefresh,
      );
      concours.value = allConcours;

      // Sépare par statut
      concoursEnCours.value = allConcours
          .where((c) => c.statut == StatutConcours.enCours)
          .toList();
      concoursAVenir.value = allConcours
          .where((c) => c.statut == StatutConcours.aVenir)
          .toList();
      concoursTermines.value = allConcours
          .where((c) => c.statut == StatutConcours.termine)
          .toList();

      AppLogger.success('${allConcours.length} concours chargés');
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des concours';
      AppLogger.error('Erreur loadAllConcours', e);
      Get.snackbar(
        'Erreur',
        'Impossible de charger les concours',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// Charge les concours d'un établissement
  Future<void> loadConcoursByEcole(
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

      // Charge les concours
      concours.value = await _repository.getConcoursByEcole(
        idEcole,
        forceRefresh: forceRefresh,
      );

      // Sépare par statut
      concoursEnCours.value = concours
          .where((c) => c.statut == StatutConcours.enCours)
          .toList();
      concoursAVenir.value = concours
          .where((c) => c.statut == StatutConcours.aVenir)
          .toList();
      concoursTermines.value = concours
          .where((c) => c.statut == StatutConcours.termine)
          .toList();

      AppLogger.success(
        '${concours.length} concours chargés pour école: $idEcole',
      );
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des concours';
      AppLogger.error('Erreur loadConcoursByEcole', e);
      Get.snackbar(
        'Erreur',
        'Impossible de charger les concours',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// Charge les concours par statut
  Future<void> loadConcoursByStatut(
    StatutConcours statut, {
    bool forceRefresh = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _repository.getConcoursByStatut(
        statut,
        forceRefresh: forceRefresh,
      );

      switch (statut) {
        case StatutConcours.enCours:
          concoursEnCours.value = result;
          break;
        case StatutConcours.aVenir:
          concoursAVenir.value = result;
          break;
        case StatutConcours.termine:
          concoursTermines.value = result;
          break;
      }

      AppLogger.success('${result.length} concours ${statut.label} chargés');
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des concours';
      AppLogger.error('Erreur loadConcoursByStatut', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Sélectionne un concours
  void selectConcours(ConcoursModel concours) {
    selectedConcours.value = concours;
    AppLogger.info('Concours sélectionné: ${concours.nom}');
  }

  /// Désélectionne le concours
  void clearSelection() {
    selectedConcours.value = null;
  }

  /// Charge un concours par ID
  Future<ConcoursModel?> getConcoursById(
    String id, {
    bool forceRefresh = false,
  }) async {
    try {
      final concours = await _repository.getConcoursById(
        id,
        forceRefresh: forceRefresh,
      );
      if (concours != null) {
        selectedConcours.value = concours;
        currentEcoleId.value = concours.idEcole;
      }
      return concours;
    } catch (e) {
      AppLogger.error('Erreur getConcoursById', e);
      return null;
    }
  }

  /// Recherche de concours
  Future<List<ConcoursModel>> searchConcours(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }
      return await _repository.searchConcours(query);
    } catch (e) {
      AppLogger.error('Erreur searchConcours', e);
      return [];
    }
  }

  /// Récupère les concours ouverts (en cours et pas expirés)
  Future<List<ConcoursModel>> getConcoursOuverts() async {
    try {
      return await _repository.getConcoursOuverts();
    } catch (e) {
      AppLogger.error('Erreur getConcoursOuverts', e);
      return [];
    }
  }

  /// Filtre par statut
  List<ConcoursModel> filterByStatut(StatutConcours statut) {
    return concours.where((c) => c.statut == statut).toList();
  }

  /// Filtre par année
  List<ConcoursModel> filterByAnnee(String annee) {
    return concours.where((c) => c.annee == annee).toList();
  }

  /// Compte les concours par statut
  Future<Map<StatutConcours, int>> getCountByStatut() async {
    try {
      return await _repository.countByStatut();
    } catch (e) {
      AppLogger.error('Erreur getCountByStatut', e);
      return {
        StatutConcours.aVenir: 0,
        StatutConcours.enCours: 0,
        StatutConcours.termine: 0,
      };
    }
  }

  /// Groupe les concours par année
  Future<Map<String, List<ConcoursModel>>> groupByAnnee() async {
    try {
      return await _repository.groupConcoursByAnnee();
    } catch (e) {
      AppLogger.error('Erreur groupByAnnee', e);
      return {};
    }
  }

  /// Ouvre le lien d'inscription d'un concours
  Future<void> openInscriptionLink(ConcoursModel concours) async {
    if (concours.lienInscription == null || concours.lienInscription!.isEmpty) {
      Get.snackbar(
        'Lien indisponible',
        'Aucun lien d\'inscription pour ce concours',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final uri = Uri.parse(concours.lienInscription!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        AppLogger.info('Lien ouvert: ${concours.lienInscription}');
      } else {
        throw Exception('Impossible d\'ouvrir le lien');
      }
    } catch (e) {
      AppLogger.error('Erreur openInscriptionLink', e);
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir le lien d\'inscription',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Partage les informations d'un concours
  Future<void> shareConcours(ConcoursModel concours) async {
    try {
      final text =
          '''
${concours.nom}
${concours.statut.emoji} ${concours.statut.label}
${concours.dateDebut != null ? 'Début: ${concours.dateDebut}' : ''}
${concours.dateFin != null ? 'Fin: ${concours.dateFin}' : ''}
${concours.lienInscription != null ? 'Inscription: ${concours.lienInscription}' : ''}
''';

      // Utilise share_plus
      // await Share.share(text);

      AppLogger.info('Concours partagé: ${concours.nom}');
    } catch (e) {
      AppLogger.error('Erreur shareConcours', e);
      Get.snackbar(
        'Erreur',
        'Impossible de partager',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Rafraîchit les données
  Future<void> refresh() async {
    if (currentEcoleId.value.isNotEmpty) {
      await loadConcoursByEcole(currentEcoleId.value, forceRefresh: true);
    } else {
      await loadAllConcours(forceRefresh: true);
    }
  }

  /// Vide le cache
  Future<void> clearCache() async {
    if (currentEcoleId.value.isNotEmpty) {
      await _repository.clearCache(currentEcoleId.value);
      await loadConcoursByEcole(currentEcoleId.value, forceRefresh: true);
    } else {
      await _repository.clearAllCache();
      await loadAllConcours(forceRefresh: true);
    }
  }

  /// Réinitialise le controller
  void reset() {
    concours.clear();
    concoursEnCours.clear();
    concoursAVenir.clear();
    concoursTermines.clear();
    selectedConcours.value = null;
    currentEcoleId.value = '';
    errorMessage.value = '';
  }

  // Getters pratiques
  int get totalConcours => concours.length;
  int get totalEnCours => concoursEnCours.length;
  int get totalAVenir => concoursAVenir.length;
  int get totalTermines => concoursTermines.length;
  bool get hasData => totalConcours > 0;
  bool get hasError => errorMessage.value.isNotEmpty;
  bool get hasConcoursEnCours => totalEnCours > 0;
  bool get hasConcoursAVenir => totalAVenir > 0;
}
