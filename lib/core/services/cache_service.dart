import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/logger.dart';

class CacheService extends GetxService {
  static const String _boxName = 'docstore_cache';
  late Box _box;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox(_boxName);
      AppLogger.info('Hive initialisé avec succès');
    } catch (e) {
      AppLogger.error('Erreur initialisation Hive', e);
      rethrow;
    }
  }

  // === MÉTHODES CACHE ===

  /// Sauvegarde une donnée dans le cache avec expiration
  Future<void> put({
    required String key,
    required dynamic value,
    Duration? expiration,
  }) async {
    try {
      final data = {
        'value': value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiration': expiration?.inMilliseconds,
      };
      await _box.put(key, json.encode(data));
      AppLogger.debug('Cache mis à jour: $key');
    } catch (e) {
      AppLogger.error('Erreur cache put ($key)', e);
    }
  }

  /// Récupère une donnée du cache si elle n'est pas expirée
  dynamic get(String key) {
    try {
      final data = _box.get(key);
      if (data == null) return null;

      final decoded = json.decode(data);
      final timestamp = decoded['timestamp'] as int;
      final expiration = decoded['expiration'] as int?;

      // Vérifie l'expiration
      if (expiration != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - timestamp > expiration) {
          delete(key); // Supprime les données expirées
          return null;
        }
      }

      return decoded['value'];
    } catch (e) {
      AppLogger.error('Erreur cache get ($key)', e);
      return null;
    }
  }

  /// Vérifie si une clé existe et n'est pas expirée
  bool has(String key) {
    return get(key) != null;
  }

  /// Supprime une entrée du cache
  Future<void> delete(String key) async {
    try {
      await _box.delete(key);
      AppLogger.debug('Cache supprimé: $key');
    } catch (e) {
      AppLogger.error('Erreur cache delete ($key)', e);
    }
  }

  /// Supprime toutes les entrées correspondant à un préfixe
  Future<void> deleteByPrefix(String prefix) async {
    try {
      final keys = _box.keys.where((key) => key.toString().startsWith(prefix));
      for (final key in keys) {
        await _box.delete(key);
      }
      AppLogger.debug('Cache supprimé avec préfixe: $prefix');
    } catch (e) {
      AppLogger.error('Erreur cache deleteByPrefix ($prefix)', e);
    }
  }

  /// Vide tout le cache
  Future<void> clear() async {
    try {
      await _box.clear();
      AppLogger.info('Cache vidé complètement');
    } catch (e) {
      AppLogger.error('Erreur cache clear', e);
    }
  }

  /// Récupère la taille du cache en bytes
  int get cacheSize {
    try {
      int size = 0;
      for (final key in _box.keys) {
        final value = _box.get(key);
        if (value is String) {
          size += value.length;
        }
      }
      return size;
    } catch (e) {
      AppLogger.error('Erreur calcul cacheSize', e);
      return 0;
    }
  }

  /// Récupère le nombre d'entrées dans le cache
  int get entryCount => _box.length;

  /// Sauvegarde une liste d'objets JSON
  Future<void> putList({
    required String key,
    required List<Map<String, dynamic>> list,
    Duration? expiration,
  }) async {
    await put(key: key, value: list, expiration: expiration);
  }

  /// Récupère une liste d'objets JSON
  List<Map<String, dynamic>>? getList(String key) {
    final data = get(key);
    if (data == null) return null;

    try {
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      AppLogger.error('Erreur cache getList ($key)', e);
      return null;
    }
  }

  /// Récupère toutes les clés du cache
  Iterable<dynamic> get allKeys => _box.keys;

  /// Ferme le cache (à appeler à la fermeture de l'app)
  Future<void> close() async {
    try {
      await _box.close();
      AppLogger.info('Cache fermé');
    } catch (e) {
      AppLogger.error('Erreur fermeture cache', e);
    }
  }
}
