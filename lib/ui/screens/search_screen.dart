import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../widgets/search_bar.dart';
import '../../providers/search_provider.dart';
import '../../providers/search_history_provider.dart';
import '../widgets/compact_concours_card.dart';
import 'filieres_screen.dart';
import 'concours_detail_screen.dart';
import 'ue_detail_screen.dart';
import '../widgets/search_suggestion_chip.dart';
import '../widgets/unified_resource_list_item.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupScroll();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      // trigger provider search
      ref.read(searchProvider.notifier).search(value.trim(), reset: true);
      // add to history when user stops typing and query non-empty
      if (value.trim().isNotEmpty) {
        ref.read(searchHistoryProvider.notifier).add(value.trim());
      }
    });
  }

  void _setupScroll() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 120) {
        // near bottom
        ref.read(searchProvider.notifier).loadMore();
      }
    });
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            '($count)',
            style: TextStyle(color: AppTheme.mutedText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: RoundedSearchBar(
            controller: _controller,
            hint: 'Rechercher écoles, concours, UEs, documents...',
            onChanged: _onSearchChanged,
          ),
        ),
        const SizedBox(height: 16),
        // Observer l'etat du provider
        Consumer(builder: (context, ref2, _) {
          final state = ref2.watch(searchProvider);
          if (state.isLoading) {
            return const LinearProgressIndicator();
          }
          if (state.error != null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(child: Text('Erreur: ${state.error}', style: const TextStyle(color: Colors.red))),
            );
          }
          return const SizedBox.shrink();
        }),
        Expanded(
          child: Consumer(builder: (context, ref2, _) {
            final state = ref2.watch(searchProvider);
            final history = ref2.watch(searchHistoryProvider);

            final isEmptyQuery = _controller.text.trim().isEmpty && state.query.isEmpty;
            if (isEmptyQuery) {
              // Show suggestions from history
              if (history.isEmpty) {
                return Center(child: Text('Commencez votre recherche', style: TextStyle(color: AppTheme.mutedText)));
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: history.map((h) => SearchSuggestionChip(
                        text: h,
                        onTap: () {
                          _controller.text = h;
                          ref.read(searchProvider.notifier).search(h, reset: true);
                        },
                      )).toList(),
                ),
              );
            }

            final results = state.results;
            final hasAny = results.ecoles.isNotEmpty || results.concours.isNotEmpty || results.ues.isNotEmpty;
            if (!state.isLoading && !hasAny) {
              return Center(child: Text('Aucun résultat', style: TextStyle(color: AppTheme.mutedText)));
            }

            // Build the combined list with badges/icons and partial display notice
            final children = <Widget>[];

            if (results.ecoles.isNotEmpty) {
              children.add(_buildSectionHeader('Écoles', results.ecoles.length));
              for (final e in results.ecoles) {
                children.add(Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: Icon(Icons.school, color: Colors.blue),
                    ),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    title: Text(e.nom),
                    subtitle: e.description != null ? Text(e.description!) : null,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FilieresScreen(ecole: e))),
                  ),
                ));
              }
            }

            if (results.concours.isNotEmpty) {
              children.add(_buildSectionHeader('Concours', results.concours.length));
              for (final c in results.concours) {
                children.add(Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: CompactConcoursCard(
                    title: c.nom ?? 'Concours',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ConcoursDetailScreen(concours: c))),
                  ),
                ));
              }
            }

            if (results.ues.isNotEmpty) {
              children.add(_buildSectionHeader('UEs', results.ues.length));
              for (final u in results.ues) {
                children.add(Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.shade50,
                      child: Icon(Icons.menu_book, color: Colors.purple),
                    ),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    title: Text(u.nom),
                    subtitle: u.description != null ? Text(u.description!) : null,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UeDetailScreen(ue: u))),
                  ),
                ));
              }
            }

            if (results.resources.isNotEmpty) {
              children.add(_buildSectionHeader('Documents', results.resources.length));
              for (final r in results.resources) {
                children.add(UnifiedResourceListItem(resource: r));
              }
            }

            // Partial results note
            if (state.hasMore) {
              children.add(Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text('Affichage partiel — chargez plus de résultats en descendant', style: TextStyle(color: AppTheme.mutedText)),
                ),
              ));
            }

            // Attach a ListView with scroll controller for lazy loading
            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              controller: _scrollController,
              children: children,
            );
          }),
        ),
      ],
    );
  }
}
