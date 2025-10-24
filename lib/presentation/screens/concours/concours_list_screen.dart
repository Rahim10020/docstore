import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/concours_controller.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/header_card.dart';
import '../../widgets/custom_search_bar.dart';
import 'widgets/competition_card.dart';
import '../../../app/routes/app_routes.dart';

class ConcoursListScreen extends StatefulWidget {
  const ConcoursListScreen({super.key});

  @override
  State<ConcoursListScreen> createState() => _ConcoursListScreenState();
}

class _ConcoursListScreenState extends State<ConcoursListScreen> {
  final controller = Get.find<ConcoursController>();
  final searchController = TextEditingController();
  String selectedFilter = 'Tous';

  @override
  void initState() {
    super.initState();
    if (!controller.hasData) {
      controller.loadAllConcours();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'DocStore',
        showSettings: true,
        onSettingsTap: () => Get.toNamed(AppRoutes.settings),
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

        final filteredConcours = _getFilteredConcours();

        return RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: Column(
            children: [
              // Header
              const HeaderCard(
                title: 'Concours',
                subtitle:
                    'Consultez les différents concours disponibles\net accédez aux épreuves passées.',
                color: Colors.red,
              ),

              // Filtres
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip('Tous', controller.totalConcours),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'En cours',
                      controller.totalEnCours,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'À venir',
                      controller.totalAVenir,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Terminés',
                      controller.totalTermines,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),

              // Barre de recherche
              CustomSearchBar(
                hintText: 'Rechercher des concours...',
                controller: searchController,
                onChanged: (value) => setState(() {}),
              ),

              // Liste des concours
              Expanded(
                child: filteredConcours.isEmpty
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
                              'Aucun concours trouvé',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: filteredConcours.length,
                        itemBuilder: (context, index) {
                          final concours = filteredConcours[index];
                          return CompetitionCard(
                            title: concours.nom,
                            year: concours.annee,
                            schoolName: concours.typeEtablissement.label,
                            onTap: () => Get.toNamed(
                              AppRoutes.concoursDetail,
                              parameters: {'concoursId': concours.id},
                              arguments: concours,
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

  Widget _buildFilterChip(String label, int count, {Color? color}) {
    final isSelected = selectedFilter == label;
    final chipColor = color ?? Colors.red;

    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedFilter = label;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: chipColor.withOpacity(0.2),
      labelStyle: GoogleFonts.plusJakartaSans(
        color: isSelected ? chipColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: chipColor,
    );
  }

  List<dynamic> _getFilteredConcours() {
    var concours = controller.concours.toList();

    // Filtre par statut
    switch (selectedFilter) {
      case 'En cours':
        concours = controller.concoursEnCours.toList();
        break;
      case 'À venir':
        concours = controller.concoursAVenir.toList();
        break;
      case 'Terminés':
        concours = controller.concoursTermines.toList();
        break;
    }

    // Filtre par recherche
    final query = searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      concours = concours
          .where((c) => c.nom.toLowerCase().contains(query))
          .toList();
    }

    return concours;
  }
}
