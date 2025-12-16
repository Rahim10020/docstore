import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider pour gérer l'historique des recherches (dernieres N requetes)
final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>(
  (ref) => SearchHistoryNotifier(),
);

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  static const _key = 'search_history_v1';
  static const _maxItems = 10;

  SearchHistoryNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_key) ?? [];
    state = items;
  }

  Future<void> add(String query) async {
    query = query.trim();
    if (query.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_key) ?? [];
    // retirer si existe deja
    items.removeWhere((e) => e.toLowerCase() == query.toLowerCase());
    items.insert(0, query);
    if (items.length > _maxItems) items.removeRange(_maxItems, items.length);
    await prefs.setStringList(_key, items);
    state = List.unmodifiable(items);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = [];
  }
}

