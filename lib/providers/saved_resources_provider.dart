import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/unified_resource_service.dart';

/// Provider pour gérer les ressources sauvegardées
final savedResourcesProvider =
    StateNotifierProvider<SavedResourcesNotifier, List<String>>((ref) {
      return SavedResourcesNotifier();
    });

class SavedResourcesNotifier extends StateNotifier<List<String>> {
  SavedResourcesNotifier() : super([]) {
    _loadSavedResources();
  }

  static const String _savedResourcesKey = 'saved_resources';

  Future<void> _loadSavedResources() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_savedResourcesKey) ?? [];
    state = saved;
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedResourcesKey, state);
  }

  /// Ajouter une ressource aux sauvegardées
  Future<void> saveResource(String resourceIdentifier) async {
    if (!state.contains(resourceIdentifier)) {
      state = [...state, resourceIdentifier];
      await _saveToPrefs();
    }
  }

  /// Retirer une ressource des sauvegardées
  Future<void> unsaveResource(String resourceIdentifier) async {
    state = state.where((id) => id != resourceIdentifier).toList();
    await _saveToPrefs();
  }

  /// Vérifier si une ressource est sauvegardée
  bool isResourceSaved(String resourceIdentifier) {
    return state.contains(resourceIdentifier);
  }

  /// Basculer l'état de sauvegarde d'une ressource
  Future<void> toggleSave(String resourceIdentifier) async {
    if (isResourceSaved(resourceIdentifier)) {
      await unsaveResource(resourceIdentifier);
    } else {
      await saveResource(resourceIdentifier);
    }
  }
}

/// Provider pour récupérer les ressources sauvegardées unifiées
final savedUnifiedResourcesProvider = FutureProvider<List<UnifiedResource>>((
  ref,
) async {
  final savedIds = ref.watch(savedResourcesProvider);
  final service = UnifiedResourceService();
  return await service.getResources(savedIds);
});
