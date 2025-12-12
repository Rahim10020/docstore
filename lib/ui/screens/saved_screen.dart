import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';
import '../widgets/unified_resource_list_item.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedResourcesAsync = ref.watch(savedUnifiedResourcesProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(savedUnifiedResourcesProvider),
      edgeOffset: 16,
      child: savedResourcesAsync.when(
        data: (resources) {
          if (resources.isEmpty) {
            return ListView(
              padding: const EdgeInsets.only(top: 160),
              children: [
                Icon(
                  Icons.bookmark_border_outlined,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Aucun document sauvegardé',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Les documents que vous sauvegardez\napparaîtront ici',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.mutedText,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: resources.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final resource = resources[index];
              return UnifiedResourceListItem(
                resource: resource,
                onTap: () {
                  // Navigation vers le détail si nécessaire
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(
          padding: const EdgeInsets.only(top: 140, left: 20, right: 20),
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: AppTheme.errorColor.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 12),
            const Text(
              'Erreur de chargement',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.mutedText),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(savedUnifiedResourcesProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Reessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
