import 'package:docstore/core/constants/app_constants.dart';
import 'package:docstore/core/utils/helpers.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  late Box _ecolesBox;
  late Box _filieresBox;
  late Box _uesBox;
  late Box _concoursBox;
  late Box _filesBox;
  late Box _preferencesBox;

  Future<StorageService> init() async {
    await Hive.initFlutter();

    // Ouvrir toutes les boxes
    _ecolesBox = await Hive.openBox(AppConstants.ecolesBox);
    _filieresBox = await Hive.openBox(AppConstants.filieresBox);
    _uesBox = await Hive.openBox(AppConstants.uesBox);
    _concoursBox = await Hive.openBox(AppConstants.concoursBox);
    _filesBox = await Hive.openBox(AppConstants.filesBox);
    _preferencesBox = await Hive.openBox(AppConstants.preferencesBox);

    return this;
  }

  // ========== Écoles ==========
  Future<void> saveEcoles(List<Map<String, dynamic>> ecoles) async {
    await _ecolesBox.clear();
    for (var ecole in ecoles) {
      await _ecolesBox.put(ecole['id'], ecole);
    }
    await _saveLastSync('ecoles');
  }

  List<Map<String, dynamic>> getEcoles() {
    return _ecolesBox.values.cast<Map<String, dynamic>>().toList();
  }

  Map<String, dynamic>? getEcoleById(String id) {
    return _ecolesBox.get(id);
  }

  // ========== Filières ==========
  Future<void> saveFilieres(
    String ecoleId,
    List<Map<String, dynamic>> filieres,
  ) async {
    await _filieresBox.put(ecoleId, filieres);
    await _saveLastSync('filieres_$ecoleId');
  }

  List<Map<String, dynamic>>? getFilieresByEcole(String ecoleId) {
    final data = _filieresBox.get(ecoleId);
    return data != null ? List<Map<String, dynamic>>.from(data) : null;
  }

  // ========== UEs ==========
  Future<void> saveUEs(String filiereId, List<Map<String, dynamic>> ues) async {
    await _uesBox.put(filiereId, ues);
    await _saveLastSync('ues_$filiereId');
  }

  List<Map<String, dynamic>>? getUEsByFiliere(String filiereId) {
    final data = _uesBox.get(filiereId);
    return data != null ? List<Map<String, dynamic>>.from(data) : null;
  }

  // ========== Concours ==========
  Future<void> saveConcours(List<Map<String, dynamic>> concours) async {
    await _concoursBox.clear();
    for (var c in concours) {
      await _concoursBox.put(c['id'], c);
    }
    await _saveLastSync('concours');
  }

  List<Map<String, dynamic>> getConcours() {
    return _concoursBox.values.cast<Map<String, dynamic>>().toList();
  }

  // ========== Files Metadata ==========
  Future<void> saveFileMetadata(
    String fileId,
    Map<String, dynamic> metadata,
  ) async {
    await _filesBox.put(fileId, metadata);
  }

  Map<String, dynamic>? getFileMetadata(String fileId) {
    return _filesBox.get(fileId);
  }

  // ========== Preferences ==========
  Future<void> setPreference(String key, dynamic value) async {
    await _preferencesBox.put(key, value);
  }

  T? getPreference<T>(String key) {
    return _preferencesBox.get(key);
  }

  Future<void> setFavoriteEcole(String ecoleId) async {
    await setPreference(AppConstants.favoriteEcoleKey, ecoleId);
  }

  String? getFavoriteEcole() {
    return getPreference<String>(AppConstants.favoriteEcoleKey);
  }

  Future<void> addFavoriteFiliere(String filiereId) async {
    List<String> favorites =
        getPreference<List>(AppConstants.favoriteFilieresKey)?.cast<String>() ??
        [];
    if (!favorites.contains(filiereId)) {
      favorites.add(filiereId);
      await setPreference(AppConstants.favoriteFilieresKey, favorites);
    }
  }

  // ========== Cache Management ==========
  Future<void> _saveLastSync(String key) async {
    await _preferencesBox.put(
      '${AppConstants.lastSyncKey}$key',
      DateTime.now().toIso8601String(),
    );
  }

  DateTime? getLastSync(String key) {
    final value = _preferencesBox.get('${AppConstants.lastSyncKey}$key');
    return value != null ? DateTime.parse(value) : null;
  }

  bool isCacheExpired(String key, int expirationHours) {
    final lastSync = getLastSync(key);
    return Helpers.isCacheExpired(lastSync, expirationHours);
  }

  // Vider tout le cache
  Future<void> clearAllCache() async {
    await _ecolesBox.clear();
    await _filieresBox.clear();
    await _uesBox.clear();
    await _concoursBox.clear();
    await _filesBox.clear();
  }
}
