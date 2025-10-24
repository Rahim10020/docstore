import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ue_controller.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_search_bar.dart';
import 'widgets/ue_card.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/filiere_model.dart';
import '../../../core/enums/annee_enum.dart';

class UesListScreen extends StatefulWidget {
  const UesListScreen({super.key});

  @override
  State<UesListScreen> createState() => _UesListScreenState();
}

class _UesListScreenState extends State<UesListScreen> {
  final controller = Get.find<UeController>();
  final searchController = TextEditingController();
  AnneeEnum? selectedAnnee;

  @override
  void initState() {
    super.initState();
    final filiereId = Get.parameters['filiereId'];

    if (filiereId != null) {
      controller.loadUesByFiliere(filiereId);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filiere = Get.arguments as FiliereModel?;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(title: filiere?.nom ?? 'UEs', showBackButton: true),
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

        final filteredUes = _getFilteredUes();

        return RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: Column(
            children: [
              // Header
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.book_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            filiere?.nom ?? 'Filière',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            filiere?.typeLicence.label ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Filtres par année
              if (controller.availableAnnees.isNotEmpty) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildAnneeChip(null, 'Toutes'),
                      ...controller.availableAnnees.map(
                        (annee) => _buildAnneeChip(annee, annee.label),
                      ),
                    ],
                  ),
                ),
              ],

              // Barre de recherche
              CustomSearchBar(
                hintText: 'Rechercher des ues...',
                controller: searchController,
                onChanged: (value) => setState(() {}),
              ),

              // Liste des UEs
              Expanded(
                child: filteredUes.isEmpty
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
                              'Aucune UE trouvée',
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
                        itemCount: filteredUes.length,
                        itemBuilder: (context, index) {
                          final ue = filteredUes[index];
                          return UECard(
                            code: ue.code,
                            name: ue.nom,
                            year: ue.annee.label,
                            onTap: () => Get.toNamed(
                              AppRoutes.ueDetail,
                              parameters: {'ueId': ue.id},
                              arguments: ue,
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

  Widget _buildAnneeChip(AnneeEnum? annee, String label) {
    final isSelected = selectedAnnee == annee;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedAnnee = annee;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        checkmarkColor: const Color(0xFF8B5CF6),
      ),
    );
  }

  List<dynamic> _getFilteredUes() {
    var ues = controller.ues.toList();

    // Filtre par année
    if (selectedAnnee != null) {
      ues = ues.where((ue) => ue.annee == selectedAnnee).toList();
    }

    // Filtre par recherche
    final query = searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      ues = ues
          .where(
            (ue) =>
                ue.code.toLowerCase().contains(query) ||
                ue.nom.toLowerCase().contains(query),
          )
          .toList();
    }

    return ues;
  }
}
