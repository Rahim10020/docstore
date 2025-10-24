import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controllers/concours_controller.dart';
import '../../widgets/custom_app_bar.dart';
import '../ues/widgets/resource_card.dart';
import '../../../data/models/concours_model.dart';

class ConcoursDetailScreen extends StatefulWidget {
  const ConcoursDetailScreen({super.key});

  @override
  State<ConcoursDetailScreen> createState() => _ConcoursDetailScreenState();
}

class _ConcoursDetailScreenState extends State<ConcoursDetailScreen> {
  final controller = Get.find<ConcoursController>();
  String selectedYear = 'Annee';

  @override
  void initState() {
    super.initState();

    final concoursId = Get.parameters['concoursId'];
    if (concoursId != null) {
      controller.getConcoursById(concoursId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final concours = Get.arguments as ConcoursModel?;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: concours?.nom ?? 'Concours',
        showBackButton: true,
      ),
      body: Obx(() {
        final currentConcours = controller.selectedConcours.value ?? concours;

        if (currentConcours == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header rouge avec infos concours
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red,
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
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.emoji_events,
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
                                currentConcours.nom,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentConcours.typeEtablissement.label,
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
                          label: currentConcours.annee,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          icon: Icons.info,
                          label: currentConcours.statut.label,
                        ),
                        const SizedBox(width: 8),
                        if (currentConcours.joursRestants != null &&
                            currentConcours.joursRestants! > 0)
                          _buildInfoChip(
                            icon: Icons.access_time,
                            label: '${currentConcours.joursRestants}j restants',
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Dates du concours
              if (currentConcours.dateDebut != null ||
                  currentConcours.dateFin != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (currentConcours.dateDebut != null)
                        _buildDateRow(
                          icon: Icons.play_circle_outline,
                          label: 'Date de début',
                          date: currentConcours.dateDebut!,
                        ),
                      if (currentConcours.dateDebut != null &&
                          currentConcours.dateFin != null)
                        const Divider(height: 24),
                      if (currentConcours.dateFin != null)
                        _buildDateRow(
                          icon: Icons.stop_circle_outlined,
                          label: 'Date de fin',
                          date: currentConcours.dateFin!,
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Lien d'inscription
              if (currentConcours.lienInscription != null &&
                  currentConcours.lienInscription!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        controller.openInscriptionLink(currentConcours),
                    icon: const Icon(Icons.link),
                    label: Text(
                      'Lien d\'inscription',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Filtre par année pour les épreuves
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Épreuves par année',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    DropdownButton<String>(
                      value: selectedYear,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: ['Annee', '2024', '2023', '2022', '2021'].map((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              value,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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

              // Section Ressources disponibles
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '8',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Liste des épreuves (fichiers PDF)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return ResourceCard(
                    fileName:
                        'Epreuve_${currentConcours.annee}_${index + 1}.pdf',
                    onView: () {
                      Get.snackbar(
                        'Aperçu',
                        'Ouverture du fichier...',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    onDownload: () {
                      Get.snackbar(
                        'Téléchargement',
                        'Téléchargement en cours...',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
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

  Widget _buildDateRow({
    required IconData icon,
    required String label,
    required DateTime date,
  }) {
    final formattedDate = DateFormat('dd MMMM yyyy', 'fr_FR').format(date);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.red, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
