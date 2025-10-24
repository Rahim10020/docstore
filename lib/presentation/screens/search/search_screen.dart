import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/search_controller.dart';
import '../../widgets/custom_app_bar.dart';
import '../../../app/routes/app_routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = Get.find<SearchController>();
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(title: 'Recherche'),
      body: Column(
        children: [
          // Header violet
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF8B5CF6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recherche',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rechercher les Écoles, Concours, et ues',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),

                // Barre de recherche
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) => controller.search(value),
                          decoration: InputDecoration(
                            hintText: 'Rechercher tous...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if (searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            searchController.clear();
                            controller.clearResults();
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filtres de catégorie
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(
                () => Row(
                  children: controller.categories.map((category) {
                    final isSelected =
                        controller.selectedCategory.value == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          controller.changeCategory(category);
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF8B5CF6).withOpacity(0.2),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          color: isSelected
                              ? const Color(0xFF8B5CF6)
                              : Colors.grey[700],
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        checkmarkColor: const Color(0xFF8B5CF6),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Résultats
          Expanded(
            child: Obx(() {
              if (controller.isSearching.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.searchQuery.value.isEmpty) {
                return _buildEmptyState();
              }

              if (!controller.hasResults) {
                return _buildNoResults();
              }

              return _buildResults();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Commencez votre recherche',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Recherchez des écoles, concours ou UEs',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat trouvé',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez avec d\'autres mots-clés',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Résultats Établissements
        if (controller.hasEcoleResults) ...[
          _buildSectionTitle('Établissements', controller.ecoleResults.length),
          ...controller.ecoleResults.map((ecole) => _buildEcoleItem(ecole)),
          const SizedBox(height: 16),
        ],

        // Résultats Concours
        if (controller.hasConcoursResults) ...[
          _buildSectionTitle('Concours', controller.concoursResults.length),
          ...controller.concoursResults.map(
            (concours) => _buildConcoursItem(concours),
          ),
          const SizedBox(height: 16),
        ],

        // Résultats UEs
        if (controller.hasUeResults) ...[
          _buildSectionTitle('UEs', controller.ueResults.length),
          ...controller.ueResults.map((ue) => _buildUeItem(ue)),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoleItem(dynamic ecole) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.school, color: Color(0xFF8B5CF6)),
        ),
        title: Text(
          ecole.nom,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          ecole.nomComplet,
          style: GoogleFonts.plusJakartaSans(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Get.toNamed(
          AppRoutes.filieres,
          parameters: {'ecoleId': ecole.id},
          arguments: ecole,
        ),
      ),
    );
  }

  Widget _buildConcoursItem(dynamic concours) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.emoji_events, color: Colors.red),
        ),
        title: Text(
          concours.nom,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${concours.annee} • ${concours.statut.label}',
          style: GoogleFonts.plusJakartaSans(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Get.toNamed(
          AppRoutes.concoursDetail,
          parameters: {'concoursId': concours.id},
          arguments: concours,
        ),
      ),
    );
  }

  Widget _buildUeItem(dynamic ue) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.book, color: Colors.green),
        ),
        title: Text(
          '${ue.code} - ${ue.nom}',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          ue.annee.label,
          style: GoogleFonts.plusJakartaSans(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Get.toNamed(
          AppRoutes.ueDetail,
          parameters: {'ueId': ue.id},
          arguments: ue,
        ),
      ),
    );
  }
}
