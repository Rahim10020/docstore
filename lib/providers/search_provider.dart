import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/appwrite_service.dart';
import '../services/unified_resource_service.dart';
import 'data_provider.dart';
import '../data/models/ecole.dart';
import '../data/models/concours.dart';
import '../data/models/ue.dart' as ue_model;

// Modèle simple pour contenir résultats agrégés
class SearchResults {
  final List<Ecole> ecoles;
  final List<Concours> concours;
  final List<ue_model.Ue> ues;
  final List<UnifiedResource> resources;

  const SearchResults({this.ecoles = const [], this.concours = const [], this.ues = const [], this.resources = const []});
}

class SearchState {
  final String query;
  final int page;
  final bool isLoading;
  final bool hasMore;
  final SearchResults results;
  final String? error;

  SearchState({
    this.query = '',
    this.page = 0,
    this.isLoading = false,
    this.hasMore = false,
    this.results = const SearchResults(),
    this.error,
  });

  SearchState copyWith({
    String? query,
    int? page,
    bool? isLoading,
    bool? hasMore,
    SearchResults? results,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      results: results ?? this.results,
      error: error,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref ref;
  final AppwriteService _service;
  final UnifiedResourceService _unifiedService;
  static const int pageSize = 20;

  SearchNotifier(this.ref)
      : _service = ref.read(appwriteServiceProvider),
        _unifiedService = UnifiedResourceService(),
        super(SearchState());

  Future<void> search(String query, {bool reset = true}) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(query: '', page: 0, isLoading: false, results: const SearchResults(), hasMore: false, error: null);
      return;
    }

    final nextPage = reset ? 1 : state.page + 1;
    state = state.copyWith(query: query, isLoading: true, error: null);

    try {
      // Requête paginée côté serveur
      final ecoles = await _service.searchEcoles(query, limit: pageSize, offset: (nextPage - 1) * pageSize);
      final concours = await _service.searchConcours(query, limit: pageSize, offset: (nextPage - 1) * pageSize);
      final ues = await _service.searchUEs(query, limit: pageSize, offset: (nextPage - 1) * pageSize);

      // Collecter identifiants de ressources depuis concours + ues (serveur fournit les listes dans les documents)
      final resourceIds = <String>{};
      for (final c in concours) {
        resourceIds.addAll(c.ressources);
        resourceIds.addAll(c.communiques);
      }
      for (final u in ues) {
        resourceIds.addAll(u.ressources);
      }

      // Limiter et récupérer métadonnées unifiées
      final limitedIds = resourceIds.take(40).toList();
      final fetchedResources = limitedIds.isNotEmpty ? await _unifiedService.getResources(limitedIds) : <UnifiedResource>[];

      // Aggrégation - si reset on remplace, sinon on concatène
      final aggregated = SearchResults(
        ecoles: reset ? ecoles : [...state.results.ecoles, ...ecoles],
        concours: reset ? concours : [...state.results.concours, ...concours],
        ues: reset ? ues : [...state.results.ues, ...ues],
        resources: reset ? fetchedResources : [...state.results.resources, ...fetchedResources],
      );

      // hasMore si l'une des listes a atteint la taille de pageSize
      final hasMoreFlag = ecoles.length == pageSize || concours.length == pageSize || ues.length == pageSize;

      state = state.copyWith(
        page: nextPage,
        isLoading: false,
        hasMore: hasMoreFlag,
        results: aggregated,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    await search(state.query, reset: false);
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});
