import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme.dart';
import '../../data/models/ecole.dart';
import '../../data/models/filiere.dart';
import '../../providers/data_provider.dart';
import '../widgets/filiere_card.dart';
import '../widgets/rounded_search_input.dart';
import '../widgets/compact_concours_card.dart';
import 'ues_screen.dart';
import 'concours_detail_screen.dart';

class FilieresScreen extends ConsumerStatefulWidget {
  final Ecole ecole;

  const FilieresScreen({super.key, required this.ecole});

  @override
  ConsumerState<FilieresScreen> createState() => _FilieresScreenState();
}

class _FilieresScreenState extends ConsumerState<FilieresScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Filiere> _filterFilieres(List<Filiere> filieres) {
    if (_searchQuery.isEmpty) return filieres;

    return filieres.where((filiere) {
      return filiere.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          filiere.parcours.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (filiere.description?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filieresAsync = ref.watch(filieresByEcoleProvider(widget.ecole.id));
    final concoursAsync = ref.watch(concoursByEcoleProvider(widget.ecole.id));

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
                      SvgPicture.asset(
                        'assets/icons/more.svg',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 26,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.establishmentCardGradient,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ecole.nom,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (widget.ecole.description != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            widget.ecole.description!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Afficher le concours d'entree s'il existe
                  concoursAsync.when(
                    data: (concoursList) {
                      if (concoursList.isEmpty) return const SizedBox.shrink();
                      // On affiche le premier concours (s'il y en a plusieurs, on pourrait lister)
                      final concours = concoursList.first;
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          CompactConcoursCard(
                            title: 'Concours d\'entree a ${widget.ecole.nom}',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ConcoursDetailScreen(concours: concours),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                  RoundedSearchInput(
                    controller: _searchController,
                    hintText: 'Rechercher des filieres...',
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: filieresAsync.when(
                data: (filieres) {
                  final filteredFilieres = _filterFilieres(filieres);

                  if (filteredFilieres.isEmpty) {
                    return Center(
                      child: Text(
                        filieres.isEmpty
                            ? 'Aucune filiere disponible'
                            : 'Aucune filiere trouvee',
                        style: const TextStyle(
                          color: AppTheme.mutedText,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    itemCount: filteredFilieres.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final filiere = filteredFilieres[index];
                      return FiliereCard(
                        filiere: filiere,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UesScreen(
                                ecole: widget.ecole,
                                filiere: filiere,
                              ),
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
                        const Text(
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
                              filieresByEcoleProvider(widget.ecole.id),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reessayer'),
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
