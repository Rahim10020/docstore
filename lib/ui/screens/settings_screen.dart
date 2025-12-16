import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/notification_provider.dart';
import '../../services/notification_test_helper.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationPrefs = ref.watch(notificationPreferencesProvider);
    final notificationNotifier = ref.read(
      notificationPreferencesProvider.notifier,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // Notifications Section
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.mutedText,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildNotificationToggle(
                  context,
                  'Nouveaux documents',
                  'Être notifié quand un nouveau document est ajouté',
                  notificationPrefs.documentsEnabled,
                  notificationNotifier.toggleDocuments,
                ),
                const Divider(height: 24),
                _buildNotificationToggle(
                  context,
                  'Nouvelles écoles',
                  'Être notifié quand une nouvelle école est ajoutée',
                  notificationPrefs.ecolesEnabled,
                  notificationNotifier.toggleEcoles,
                ),
                const Divider(height: 24),
                _buildNotificationToggle(
                  context,
                  'Nouvelles filières',
                  'Être notifié quand une nouvelle filière est ajoutée',
                  notificationPrefs.filieresEnabled,
                  notificationNotifier.toggleFilieres,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Developer Section (pour tester les notifications)
          const Text(
            'Développeur',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.mutedText,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    NotificationTestHelper.addDemoNotifications(ref);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications de test ajoutées !'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_alert),
                  label: const Text('Ajouter des notifications de test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24), // Add some bottom padding
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: value,
          activeThumbColor: Colors.white,
          activeTrackColor: AppTheme.successColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
