import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';
import '../widgets/concours_card.dart';
import 'concours_detail_screen.dart';
import '../widgets/search_bar.dart';

class ConcoursScreen extends ConsumerStatefulWidget {
  const ConcoursScreen({super.key});

  @override
  ConsumerState<ConcoursScreen> createState() => _ConcoursScreenState();
}

class _ConcoursScreenState extends ConsumerState<ConcoursScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final concoursAsync = ref.watch(concoursProvider);
    final selectedYear = ref.watch(selectedConcoursYearProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(concoursProvider),
      edgeOffset: 16,
      child: concoursAsync.when(
        data: (concours) {
          if (concours.isEmpty) {
            return ListView(
              padding: const EdgeInsets.only(top: 160),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: RoundedSearchBar(
                    controller: _searchController,
                    hint: 'Rechercher des concours...',
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                Icon(
                  Icons.emoji_events_outlined,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Aucun concours disponible',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            );
          }

          // Construire la liste des années disponibles à partir des concours
          final yearsSet = <String>{};
          for (final c in concours) {
            if (c.annee != null && c.annee!.trim().isNotEmpty) {
              yearsSet.add(c.annee!.trim());
            }
          }
          final years = ['Tous', ...yearsSet.toList()];
          // Trier les années numériques décroissantes si possible
          years.sort((a, b) {
            if (a == 'Tous') return -1;
            if (b == 'Tous') return 1;
            final ai = int.tryParse(a) ?? 0;
            final bi = int.tryParse(b) ?? 0;
            return bi.compareTo(ai);
          });

          // Filtrer côté client selon l'année sélectionnée
          final byYear = selectedYear == 'Tous'
              ? concours
              : concours.where((c) => c.annee == selectedYear).toList();

          // Filtrage selon la barre de recherche (nom, description, annee, idEcole)
          final query = _searchQuery.trim().toLowerCase();
          final filtered = query.isEmpty
              ? byYear
              : byYear.where((c) {
                  final nom = (c.nom ?? '').toLowerCase();
                  final desc = (c.description ?? '').toLowerCase();
                  final annee = (c.annee ?? '').toLowerCase();
                  final ecole = (c.idEcole ?? '').toLowerCase();
                  return nom.contains(query) ||
                      desc.contains(query) ||
                      annee.contains(query) ||
                      ecole.contains(query);
                }).toList();

          return Column(
            children: [
              // Header with selector + search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Search bar on the left taking ~3/4 of the space
                    Expanded(
                      flex: 3,
                      child: RoundedSearchBar(
                        controller: _searchController,
                        hint: 'Rechercher des concours...',
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Year selector on the right taking ~1/4 of the space
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedYear,
                              items: years
                                  .map(
                                    (y) => DropdownMenuItem(
                                      value: y,
                                      child: Text(y),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  ref.read(selectedConcoursYearProvider.notifier).state = v;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Liste des concours filtrés
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return ConcoursCard(
                      concours: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConcoursDetailScreen(concours: item),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(
          padding: const EdgeInsets.only(top: 140, left: 20, right: 20),
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: AppTheme.errorColor.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 12),
            const Text(
              'Erreur de chargement',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.mutedText),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(concoursProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Reessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
