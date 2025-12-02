import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import '../../config/app_theme.dart';
import '../../data/models/index.dart';

class ConcoursDetailPage extends StatelessWidget {
  final Concours concours;
  final String? ecoleNom;

  const ConcoursDetailPage({required this.concours, this.ecoleNom, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails du concours')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(gradient: AppColors.concoursGradient),
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concours.nom,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineLarge?.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  if (ecoleNom != null)
                    Text(
                      ecoleNom!,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: AppColors.white),
                    ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppColors.white.withValues(alpha: 0.8),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Année ${concours.annee}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    concours.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (concours.hasCommunique) ...[
                    const SizedBox(height: AppConstants.paddingLarge),
                    Text(
                      'Communiqué',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/pdf-viewer',
                                arguments: {
                                  'url': concours.communiquePdfUrl,
                                  'title':
                                      concours.communiquePdfNom ?? 'Communiqué',
                                },
                              );
                            },
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Ouvrir le PDF'),
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implement download
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.border,
                          ),
                          child: const Icon(Icons.download),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppConstants.paddingLarge),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement share functionality
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Partager'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
