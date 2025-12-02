import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import '../../config/app_theme.dart';
import '../../data/models/index.dart';

class CoursCard extends StatelessWidget {
  final Cours cours;
  final VoidCallback onTap;
  final VoidCallback? onDownload;

  const CoursCard({
    required this.cours,
    required this.onTap,
    this.onDownload,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      cours.titre,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (cours.ressources.isNotEmpty)
                    Badge(
                      label: Text(cours.ressources.length.toString()),
                      backgroundColor: AppColors.primaryIndigo,
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                cours.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (cours.ressources.isNotEmpty) ...[
                const SizedBox(height: AppConstants.paddingDefault),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${cours.ressources.length} ressource(s)',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primaryIndigo,
                      ),
                    ),
                    if (onDownload != null)
                      IconButton(
                        onPressed: onDownload,
                        icon: const Icon(Icons.download),
                        iconSize: 20,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
