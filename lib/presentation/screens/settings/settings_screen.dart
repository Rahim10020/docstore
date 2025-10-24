import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/settings_controller.dart';
import '../../widgets/custom_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(title: 'Paramètres', showBackButton: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section Mode nuit
            _buildSectionCard(
              title: 'Apparence',
              children: [
                _buildSwitchTile(
                  icon: Icons.dark_mode,
                  title: 'Mode nuit',
                  value: controller.darkModeEnabled.value,
                  onChanged: controller.toggleDarkMode,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section Téléchargements
            _buildSectionCard(
              title: 'Téléchargements',
              children: [
                _buildSwitchTile(
                  icon: Icons.wifi,
                  title: 'Télécharger uniquement en WiFi',
                  subtitle: 'Économisez vos données mobiles',
                  value: controller.autoDownloadOnWifi.value,
                  onChanged: controller.toggleAutoDownloadOnWifi,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section Notifications
            _buildSectionCard(
              title: 'Notifications',
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Recevoir les alertes',
                  value: controller.notificationsEnabled.value,
                  onChanged: controller.toggleNotifications,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section Stockage
            _buildSectionCard(
              title: 'Stockage',
              children: [
                _buildInfoTile(
                  icon: Icons.storage,
                  title: 'Cache',
                  trailing: Text(
                    controller.cacheSizeFormatted,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  icon: Icons.download,
                  title: 'Téléchargements',
                  trailing: Text(
                    controller.downloadSizeFormatted,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.delete_sweep,
                  title: 'Vider le cache',
                  iconColor: Colors.orange,
                  onTap: () => _showClearCacheDialog(context, controller),
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.folder_delete,
                  title: 'Supprimer les téléchargements',
                  iconColor: Colors.red,
                  onTap: controller.clearDownloads,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section À propos
            _buildSectionCard(
              title: 'À propos',
              children: [
                _buildActionTile(
                  icon: Icons.email,
                  title: 'Contacter le support',
                  onTap: controller.contactSupport,
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.language,
                  title: 'Site web',
                  onTap: controller.openWebsite,
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.privacy_tip,
                  title: 'Politique de confidentialité',
                  onTap: controller.openPrivacyPolicy,
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.description,
                  title: 'Conditions d\'utilisation',
                  onTap: controller.openTerms,
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.share,
                  title: 'Partager l\'application',
                  onTap: controller.shareApp,
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.info,
                  title: 'À propos de DocStore',
                  onTap: controller.showAboutDialog,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bouton Réinitialiser
            Container(
              width: double.infinity,
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
              child: TextButton.icon(
                onPressed: controller.resetAllSettings,
                icon: const Icon(Icons.restore, color: Colors.red),
                label: Text(
                  'Réinitialiser tous les paramètres',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Version
            Center(
              child: Text(
                'DocStore v1.0.0',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF8B5CF6),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.grey[600], size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? const Color(0xFF8B5CF6)).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? const Color(0xFF8B5CF6),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showClearCacheDialog(
    BuildContext context,
    SettingsController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Vider le cache',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vider le cache ? Cette action supprimera toutes les données temporaires.',
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Annuler',
              style: GoogleFonts.plusJakartaSans(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearCache();
            },
            child: Text(
              'Vider',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
