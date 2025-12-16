import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/data_provider.dart';
import '../../core/theme.dart';
import 'filieres_screen.dart';
import '../widgets/establishment_card.dart';
import '../widgets/search_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ecolesAsync = ref.watch(ecolesProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(ecolesProvider),
      edgeOffset: 16,
      child: ecolesAsync.when(
        data: (ecoles) {
          // Filtrage local selon la query
          final query = _searchQuery.trim().toLowerCase();
          final filtered = query.isEmpty
              ? ecoles
              : ecoles.where((e) {
                  final name = e.nom.toLowerCase();
                  final desc = (e.description ?? '').toLowerCase();
                  return name.contains(query) || desc.contains(query);
                }).toList();

          // Construire une ListView avec header (search) + résultats
          if (filtered.isEmpty) {
            return ListView(
              padding: const EdgeInsets.only(top: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: RoundedSearchBar(
                    controller: _searchController,
                    hint: 'Rechercher des écoles...',
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(height: 40),
                Icon(
                  Icons.school_outlined,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Aucune école disponible',
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

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: filtered.length + 1, // +1 pour l'entête (search)
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: RoundedSearchBar(
                    controller: _searchController,
                    hint: 'Rechercher des écoles...',
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                );
              }

              final ecole = filtered[index - 1];
              return EstablishmentCard(
                ecole: ecole,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FilieresScreen(ecole: ecole),
                    ),
                  );
                },
              );
            },
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
              onPressed: () => ref.invalidate(ecolesProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Reessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
