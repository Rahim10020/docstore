import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      AppLogger.info('SharedPreferences initialisé avec succès');
    } catch (e) {
      AppLogger.error('Erreur initialisation SharedPreferences', e);
      rethrow;
    }
  }

  // === MÉTHODES STRING ===

  Future<bool> setString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e) {
      AppLogger.error('Erreur setString ($key)', e);
      return false;
    }
  }

  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      AppLogger.error('Erreur getString ($key)', e);
      return null;
    }
  }

  // === MÉTHODES INT ===

  Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e) {
      AppLogger.error('Erreur setInt ($key)', e);
      return false;
    }
  }

  int? getInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      AppLogger.error('Erreur getInt ($key)', e);
      return null;
    }
  }

  // === MÉTHODES BOOL ===

  Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e) {
      AppLogger.error('Erreur setBool ($key)', e);
      return false;
    }
  }

  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      AppLogger.error('Erreur getBool ($key)', e);
      return null;
    }
  }

  // === MÉTHODES DOUBLE ===

  Future<bool> setDouble(String key, double value) async {
    try {
      return await _prefs.setDouble(key, value);
    } catch (e) {
      AppLogger.error('Erreur setDouble ($key)', e);
      return false;
    }
  }

  double? getDouble(String key) {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      AppLogger.error('Erreur getDouble ($key)', e);
      return null;
    }
  }

  // === MÉTHODES LIST<STRING> ===

  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _prefs.setStringList(key, value);
    } catch (e) {
      AppLogger.error('Erreur setStringList ($key)', e);
      return false;
    }
  }

  List<String>? getStringList(String key) {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      AppLogger.error('Erreur getStringList ($key)', e);
      return null;
    }
  }

  // === MÉTHODES JSON ===

  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = json.encode(value);
      return await setString(key, jsonString);
    } catch (e) {
      AppLogger.error('Erreur setJson ($key)', e);
      return false;
    }
  }

  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      return json.decode(jsonString);
    } catch (e) {
      AppLogger.error('Erreur getJson ($key)', e);
      return null;
    }
  }

  // === MÉTHODES LIST JSON ===

  Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    try {
      final jsonString = json.encode(value);
      return await setString(key, jsonString);
    } catch (e) {
      AppLogger.error('Erreur setJsonList ($key)', e);
      return false;
    }
  }

  List<Map<String, dynamic>>? getJsonList(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      final decoded = json.decode(jsonString);
      return List<Map<String, dynamic>>.from(decoded);
    } catch (e) {
      AppLogger.error('Erreur getJsonList ($key)', e);
      return null;
    }
  }

  // === MÉTHODES UTILITAIRES ===

  Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      AppLogger.error('Erreur remove ($key)', e);
      return false;
    }
  }

  Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      AppLogger.error('Erreur clear', e);
      return false;
    }
  }

  bool containsKey(String key) {
    try {
      return _prefs.containsKey(key);
    } catch (e) {
      AppLogger.error('Erreur containsKey ($key)', e);
      return false;
    }
  }

  Set<String> getKeys() {
    try {
      return _prefs.getKeys();
    } catch (e) {
      AppLogger.error('Erreur getKeys', e);
      return {};
    }
  }

  Future<void> reload() async {
    try {
      await _prefs.reload();
      AppLogger.debug('Storage rechargé');
    } catch (e) {
      AppLogger.error('Erreur reload', e);
    }
  }
}
