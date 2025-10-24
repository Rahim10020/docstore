import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ecole_controller.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/header_card.dart';
import 'widgets/school_faculty_card.dart';
import '../../../app/routes/app_routes.dart';

class EcolesFacultesScreen extends StatelessWidget {
  const EcolesFacultesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EcoleController>();

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

        return RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: ListView(
            children: [
              const HeaderCard(
                title: 'Etablissements',
                subtitle:
                    'Découvrez toutes les écoles disponibles\net explorez leurs filières académiques.',
                color: Color(0xFF8B5CF6),
              ),

              // Section Écoles
              if (controller.ecoles.isNotEmpty) ...[
                _buildSectionHeader('Écoles', controller.totalEcoles),
                ...controller.ecoles.map(
                  (ecole) => SchoolFacultyCard(
                    title: ecole.nom,
                    subtitle: ecole.nomComplet,
                    headerColor: const Color(0xFF8B5CF6),
                    icon: Icons.school,
                    onTap: () => Get.toNamed(
                      AppRoutes.filieres,
                      parameters: {'ecoleId': ecole.id},
                      arguments: ecole,
                    ),
                  ),
                ),
              ],

              // Section Facultés
              if (controller.facultes.isNotEmpty) ...[
                _buildSectionHeader('Facultés', controller.totalFacultes),
                ...controller.facultes.map(
                  (faculte) => SchoolFacultyCard(
                    title: faculte.nom,
                    subtitle: faculte.nomComplet,
                    headerColor: const Color(0xFF10B981),
                    icon: Icons.account_balance,
                    onTap: () => Get.toNamed(
                      AppRoutes.filieres,
                      parameters: {'ecoleId': faculte.id},
                      arguments: faculte,
                    ),
                  ),
                ),
              ],

              // Section Instituts
              if (controller.instituts.isNotEmpty) ...[
                _buildSectionHeader('Instituts', controller.totalInstituts),
                ...controller.instituts.map(
                  (institut) => SchoolFacultyCard(
                    title: institut.nom,
                    subtitle: institut.nomComplet,
                    headerColor: const Color(0xFFF59E0B),
                    icon: Icons.business,
                    onTap: () => Get.toNamed(
                      AppRoutes.filieres,
                      parameters: {'ecoleId': institut.id},
                      arguments: institut,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B5CF6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
