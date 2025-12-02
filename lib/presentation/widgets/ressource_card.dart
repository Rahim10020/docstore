import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import '../../config/app_theme.dart';

class RessourceCard extends StatelessWidget {
  final String nom;
  final String type;
  final VoidCallback onTap;
  final bool isDownloading;
  final double downloadProgress;

  const RessourceCard({
    required this.nom,
    required this.type,
    required this.onTap,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    Key? key,
  }) : super(key: key);

  Color _getTypeColor() {
    switch (type.toLowerCase()) {
      case 'cours':
        return AppColors.primaryBlue;
      case 'exercices':
      case 'td':
        return AppColors.secondaryOrange;
      case 'tp':
        return AppColors.primaryIndigo;
      case 'communiqué':
        return AppColors.successGreen;
      default:
        return AppColors.textLight;
    }
  }

  IconData _getTypeIcon() {
    switch (type.toLowerCase()) {
      case 'cours':
        return Icons.book;
      case 'exercices':
        return Icons.assignment;
      case 'td':
        return Icons.description;
      case 'tp':
        return Icons.construction;
      case 'communiqué':
        return Icons.notification_important;
      default:
        return Icons.file_present;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDownloading ? null : onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      color: _getTypeColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nom,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          type,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: _getTypeColor()),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.download,
                    color: isDownloading
                        ? AppColors.textLight
                        : _getTypeColor(),
                    size: 20,
                  ),
                ],
              ),
              if (isDownloading) ...[
                const SizedBox(height: AppConstants.paddingSmall),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: downloadProgress,
                    minHeight: 4,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(_getTypeColor()),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(downloadProgress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: _getTypeColor()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
