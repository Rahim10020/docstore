import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import '../../config/app_theme.dart';
import '../../data/models/index.dart';
import '../widgets/index.dart';

class CoursDetailPage extends StatelessWidget {
  final Cours cours;

  const CoursDetailPage({required this.cours, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails du cours')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: AppColors.bgLighter,
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cours.titre,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  if (cours.description.isNotEmpty)
                    Text(
                      cours.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (cours.ressources.isNotEmpty) ...[
                    Text(
                      'Ressources (${cours.ressources.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cours.ressources.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppConstants.paddingSmall),
                      itemBuilder: (context, index) {
                        final ressource = cours.ressources[index];
                        return RessourceCard(
                          nom: ressource.nom,
                          type: ressource.type,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/pdf-viewer',
                              arguments: {
                                'url': ressource.url,
                                'title': ressource.nom,
                              },
                            );
                          },
                        );
                      },
                    ),
                  ] else
                    const EmptyStateWidget(
                      message: 'Aucune ressource disponible',
                      icon: Icons.file_present,
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
