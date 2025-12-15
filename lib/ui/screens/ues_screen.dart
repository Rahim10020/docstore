import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/models/ecole.dart';
import '../../data/models/filiere.dart';
import '../../data/models/ue.dart';
import '../../providers/data_provider.dart';
import '../widgets/rounded_search_input.dart';
import '../widgets/ue_card.dart';
import 'ue_detail_screen.dart';

class UesScreen extends ConsumerStatefulWidget {
  final Ecole ecole;
  final Filiere filiere;

  const UesScreen({super.key, required this.ecole, required this.filiere});

  @override
  ConsumerState<UesScreen> createState() => _UesScreenState();
}

class _UesScreenState extends ConsumerState<UesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper défensif pour convertir une valeur en lowercase de façon sûre
  String _safeLower(Object? v) => v == null ? '' : v.toString().toLowerCase();

  List<Ue> _filterUes(List<Ue> ues) {
    var result = ues;

    try {
      // Appliquer la recherche texte
      if (_searchQuery.isEmpty) return result;

      final q = _safeLower(_searchQuery);
      return result.where((ue) {
        final nom = _safeLower(ue.nom);
        final desc = _safeLower(ue.description);
        final matchesText = nom.contains(q) || desc.contains(q);
        final matchesAnnee = ue.anneeEnseignement.any((a) {
          final s = _safeLower(a);
          return s.contains(q);
        });
        return matchesText || matchesAnnee;
      }).toList();
    } catch (e) {
      debugPrint('Erreur lors du filtrage des UEs: $e');
      return ues;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uesAsync = ref.watch(uesByFiliereProvider(widget.filiere.id));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColorLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      ),
                      const Spacer(),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.establishmentCardGradient,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.filiere.nom,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.filiere.parcours,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  RoundedSearchInput(
                    controller: _searchController,
                    hintText: 'Rechercher des ues...',
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ],
              ),
            ),
            Expanded(
              child: uesAsync.when(
                data: (ues) {
                  final filteredUes = _filterUes(ues);

                  if (filteredUes.isEmpty) {
                    return Center(
                      child: Text(
                        ues.isEmpty
                            ? 'Aucune UE disponible'
                            : 'Aucune UE trouvee',
                        style: const TextStyle(color: AppTheme.mutedText),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    itemCount: filteredUes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final ue = filteredUes[index];
                      return UeCard(
                        ue: ue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UeDetailScreen(ue: ue),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur lors du chargement',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.invalidate(
                              uesByFiliereProvider(widget.filiere.id),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
