import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/unified_resource_service.dart';
import '../services/google_drive_service.dart';

/// Classe pour représenter le résultat d'une action de sauvegarde
class SaveActionResult {
  final String message;
  final bool wasSaved; // true si ajouté, false si retiré
  final String resourceId;

  SaveActionResult({
    required this.message,
    required this.wasSaved,
    required this.resourceId,
  });
}

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
  SaveActionResult? _lastAction; // Pour permettre l'annulation

  Future<void> _loadSavedResources() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_savedResourcesKey) ?? [];

    // Normalize saved identifiers: convert Drive URLs to file IDs
    final gd = GoogleDriveService();
    final List<String> normalized = [];
    for (final entry in saved) {
      final fileId = gd.extractFileIdFromUrl(entry);
      final value = fileId ?? entry;
      if (!normalized.contains(value)) normalized.add(value);
    }

    // Debug: afficher ce qui est chargé et la version normalisée
    try {
      // ignore: avoid_print
      print('SAVED_LOAD: loaded saved ids = $saved');
      // ignore: avoid_print
      print('SAVED_LOAD: normalized saved ids = $normalized');
    } catch (_) {}

    // If normalization changed the list, persist it
    if (normalized.length != saved.length ||
        !_listEquals(normalized, saved)) {
      await prefs.setStringList(_savedResourcesKey, normalized);
      // Debug: print persistence
      try {
        // ignore: avoid_print
        print('SAVED_LOAD: persisted normalized saved ids');
      } catch (_) {}
    }

    state = normalized;
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedResourcesKey, state);
  }

  /// Ajouter une ressource aux sauvegardées
  Future<SaveActionResult?> saveResource(String resourceIdentifier) async {
    if (!state.contains(resourceIdentifier)) {
      state = [...state, resourceIdentifier];
      await _saveToPrefs();
      _lastAction = SaveActionResult(
        message: 'Document ajouté à vos sauvegardes',
        wasSaved: true,
        resourceId: resourceIdentifier,
      );
      return _lastAction;
    }
    return null; // Déjà sauvegardé
  }

  /// Retirer une ressource des sauvegardées
  Future<SaveActionResult?> unsaveResource(String resourceIdentifier) async {
    if (state.contains(resourceIdentifier)) {
      state = state.where((id) => id != resourceIdentifier).toList();
      await _saveToPrefs();
      _lastAction = SaveActionResult(
        message: 'Document retiré de vos sauvegardes',
        wasSaved: false,
        resourceId: resourceIdentifier,
      );
      return _lastAction;
    }
    return null; // Pas sauvegardé
  }

  /// Annuler la dernière action
  Future<void> undoLastAction() async {
    if (_lastAction != null) {
      if (_lastAction!.wasSaved) {
        // Annuler l'ajout = retirer
        state = state.where((id) => id != _lastAction!.resourceId).toList();
      } else {
        // Annuler le retrait = ajouter
        state = [...state, _lastAction!.resourceId];
      }
      await _saveToPrefs();
      _lastAction = null; // Reset après annulation
    }
  }

  /// Vérifier si une ressource est sauvegardée
  bool isResourceSaved(String resourceIdentifier) {
    return state.contains(resourceIdentifier);
  }

  /// Basculer l'état de sauvegarde d'une ressource
  Future<SaveActionResult?> toggleSave(String resourceIdentifier) async {
    if (isResourceSaved(resourceIdentifier)) {
      return await unsaveResource(resourceIdentifier);
    } else {
      return await saveResource(resourceIdentifier);
    }
  }
}

/// Provider pour récupérer les ressources sauvegardées unifiées
final savedUnifiedResourcesProvider = FutureProvider<List<UnifiedResource>>((
  ref,
) async {
  final savedIds = ref.watch(savedResourcesProvider);
  // Debug: afficher IDs passés au service
  try {
    // ignore: avoid_print
    print('SAVED_PROVIDER: fetching unified resources for ids = $savedIds');
  } catch (_) {}
  final service = UnifiedResourceService();
  return await service.getResources(savedIds);
});
