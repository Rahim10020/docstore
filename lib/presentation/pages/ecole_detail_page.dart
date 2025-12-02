import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import '../../config/app_theme.dart';
import '../../data/models/index.dart';

class EcoleDetailPage extends StatelessWidget {
  final Ecole ecole;

  const EcoleDetailPage({required this.ecole, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ecole.nom)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(gradient: AppColors.ecoleGradient),
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ecole.nom,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineLarge?.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.white.withValues(alpha: 0.8),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ecole.lieu,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.white),
                        ),
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
                    'À propos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    ecole.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/filieres',
                        arguments: {
                          'ecoleId': ecole.id,
                          'ecoleName': ecole.nom,
                        },
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Voir les filières'),
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
