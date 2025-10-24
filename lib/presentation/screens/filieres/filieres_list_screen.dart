import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/filiere_controller.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_search_bar.dart';
import 'widgets/filiere_card.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/ecole_model.dart';

class FilieresListScreen extends StatefulWidget {
  const FilieresListScreen({super.key});

  @override
  State<FilieresListScreen> createState() => _FilieresListScreenState();
}

class _FilieresListScreenState extends State<FilieresListScreen> {
  final controller = Get.find<FiliereController>();
  final searchController = TextEditingController();
  String selectedFilter = 'Tous';

  @override
  void initState() {
    super.initState();
    final ecoleId = Get.parameters['ecoleId'];

    if (ecoleId != null) {
      controller.loadFilieresByEcole(ecoleId);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ecole = Get.arguments as EcoleModel?;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: ecole?.nom ?? 'Filières',
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && !controller.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.refresh(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        final filieres = _getFilteredFilieres();

        return RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: Column(
            children: [
              // Header avec infos école
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ecole?.nom ?? 'École',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ecole?.nomComplet ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Filtres
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip('Tous', controller.totalFilieres),
                    const SizedBox(width: 8),
                    if (controller.hasDepartements)
                      _buildFilterChip(
                        'Départements',
                        controller.totalDepartements,
                      ),
                    const SizedBox(width: 8),
                    if (controller.hasParcours)
                      _buildFilterChip('Parcours', controller.totalParcours),
                  ],
                ),
              ),

              // Barre de recherche
              CustomSearchBar(
                hintText: 'Rechercher des filières...',
                controller: searchController,
                onChanged: (value) => setState(() {}),
              ),

              // Liste des filières
              Expanded(
                child: filieres.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune filière trouvée',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: filieres.length,
                        itemBuilder: (context, index) {
                          final filiere = filieres[index];
                          return FiliereCard(
                            name: filiere.nom,
                            licenseType: filiere.typeLicence.label,
                            onTap: () => Get.toNamed(
                              AppRoutes.ues,
                              parameters: {'filiereId': filiere.id},
                              arguments: filiere,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = selectedFilter == label;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedFilter = label;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF8B5CF6).withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: const Color(0xFF8B5CF6),
    );
  }

  List<dynamic> _getFilteredFilieres() {
    var filieres = controller.filieres.toList();

    // Filtre par catégorie
    if (selectedFilter == 'Départements') {
      filieres = controller.departements.toList();
    } else if (selectedFilter == 'Parcours') {
      filieres = controller.parcours.toList();
    }

    // Filtre par recherche
    final query = searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filieres = filieres
          .where((f) => f.nom.toLowerCase().contains(query))
          .toList();
    }

    return filieres;
  }
}
