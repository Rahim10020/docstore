import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/unified_resource_service.dart';

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
    state = saved;
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
  final service = UnifiedResourceService();
  return await service.getResources(savedIds);
});
