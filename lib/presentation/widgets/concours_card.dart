import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import '../../config/app_theme.dart';
import '../../data/models/index.dart';

class ConcoursCard extends StatelessWidget {
  final Concours concours;
  final VoidCallback onTap;
  final String? ecoleNom;

  const ConcoursCard({
    required this.concours,
    required this.onTap,
    this.ecoleNom,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
            gradient: AppColors.concoursGradient,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        concours.nom,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (concours.hasCommunique)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.picture_as_pdf,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                if (ecoleNom != null) ...[
                  Text(
                    ecoleNom!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                ],
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      concours.annee.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
