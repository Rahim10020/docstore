import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/models/ecole.dart';
import '../../data/models/filiere.dart';
import '../../providers/data_provider.dart';
import 'ues_screen.dart';

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
          (filiere.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filieresAsync = ref.watch(filieresByEcoleProvider(widget.ecole.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.ecole.nom,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Column(
          children: [
            // Barre de recherche
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher une filière...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primaryIndigo),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // Liste des filières
            Expanded(
              child: filieresAsync.when(
                data: (filieres) {
                  final filteredFilieres = _filterFilieres(filieres);

                  if (filieres.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_off,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune filière disponible',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (filteredFilieres.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune filière trouvée',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Essayez avec d\'autres mots-clés',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredFilieres.length,
                    itemBuilder: (context, index) {
                      final filiere = filteredFilieres[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UesScreen(ecole: widget.ecole, filiere: filiere),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryIndigo.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.business_center,
                                    color: AppTheme.primaryIndigo,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        filiere.nom,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryIndigo.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          filiere.parcours,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primaryIndigo,
                                          ),
                                        ),
                                      ),
                                      if (filiere.description != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          filiere.description!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: AppTheme.primaryIndigo,
                                ),
                              ],
                            ),
                          ),
                        ),
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
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.invalidate(filieresByEcoleProvider(widget.ecole.id));
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
