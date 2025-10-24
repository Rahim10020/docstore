import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/ue_controller.dart';
import '../../widgets/custom_app_bar.dart';
import '../ues/widgets/resource_card.dart';
import '../../../data/models/ue_model.dart';
import '../../../core/enums/annee_enum.dart';

class UeDetailScreen extends StatefulWidget {
  const UeDetailScreen({super.key});

  @override
  State<UeDetailScreen> createState() => _UeDetailScreenState();
}

class _UeDetailScreenState extends State<UeDetailScreen>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<UeController>();
  late TabController _tabController;
  String selectedYear = 'Annee';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final ueId = Get.parameters['ueId'];
    if (ueId != null) {
      controller.getUeById(ueId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ue = Get.arguments as UeModel?;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(title: ue?.code ?? 'UE', showBackButton: true),
      body: Obx(() {
        final currentUe = controller.selectedUe.value ?? ue;

        if (currentUe == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Header violet avec infos UE
            Container(
              width: double.infinity,
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
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.book_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUe.code,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentUe.nom,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.calendar_today,
                        label: currentUe.annee.label,
                      ),
                      const SizedBox(width: 8),
                      if (currentUe.semestre != null)
                        _buildInfoChip(
                          icon: Icons.schedule,
                          label: currentUe.semestre!.label,
                        ),
                      const SizedBox(width: 8),
                      if (currentUe.credits != null)
                        _buildInfoChip(
                          icon: Icons.star,
                          label: '${currentUe.credits} crédits',
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Filtre par année
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Code + nom de l\'ue',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedYear,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: ['Annee', ...AnneeEnum.values.map((e) => e.label)]
                        .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9D5FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                value,
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF8B5CF6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        })
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedYear = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Nom de l'UE avec dropdown
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nom de l\'ue',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9D5FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      selectedYear,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF8B5CF6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section Ressources disponibles avec compteur
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ressources disponibles',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '10',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Liste des ressources (fichiers PDF)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return ResourceCard(
                    fileName: 'Nom du fichier.pdf',
                    onView: () {
                      // TODO: Implémenter la vue du PDF
                      Get.snackbar(
                        'Aperçu',
                        'Ouverture du fichier...',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    onDownload: () {
                      // TODO: Implémenter le téléchargement
                      Get.snackbar(
                        'Téléchargement',
                        'Téléchargement en cours...',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
