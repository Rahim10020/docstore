import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';
import '../widgets/concours_card.dart';
import 'concours_detail_screen.dart';

class ConcoursScreen extends ConsumerWidget {
  const ConcoursScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final concoursAsync = ref.watch(concoursProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(concoursProvider),
      edgeOffset: 16,
      child: concoursAsync.when(
        data: (concours) {
          if (concours.isEmpty) {
            return ListView(
              padding: const EdgeInsets.only(top: 160),
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Aucun concours disponible',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: concours.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = concours[index];
              return ConcoursCard(
                concours: item,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConcoursDetailScreen(concours: item),
                    ),
                  );
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
              onPressed: () => ref.invalidate(concoursProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Reessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
