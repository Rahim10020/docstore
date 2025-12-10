import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/unified_resource_service.dart';
import '../../core/theme.dart';

class UnifiedResourceListItem extends StatelessWidget {
  final UnifiedResource resource;
  final VoidCallback? onTap;

  const UnifiedResourceListItem({
    super.key,
    required this.resource,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icône du fichier
              _buildFileIcon(),
              const SizedBox(width: 12),

              // Informations du fichier
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom du fichier
                    Text(
                      resource.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Badge de source + taille
                    Row(
                      children: [
                        _buildSourceBadge(),
                        if (resource.size != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            UnifiedResourceService().formatFileSize(
                              resource.size,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bouton télécharger
                  IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: 'Télécharger',
                    color: AppTheme.successColor,
                    iconSize: 22,
                    onPressed: () => _handleDownload(context),
                  ),

                  // Bouton ouvrir
                  IconButton(
                    icon: const Icon(Icons.open_in_new),
                    tooltip: 'Ouvrir',
                    color: AppTheme.primaryBlue,
                    iconSize: 22,
                    onPressed: () => _handleOpen(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit l'icône du fichier selon son type
  Widget _buildFileIcon() {
    Color iconColor;
    Color backgroundColor;
    IconData icon;

    if (resource.isPdf) {
      iconColor = Colors.red;
      backgroundColor = Colors.red.shade50;
      icon = Icons.picture_as_pdf;
    } else if (resource.isImage) {
      iconColor = Colors.purple;
      backgroundColor = Colors.purple.shade50;
      icon = Icons.image;
    } else {
      iconColor = Colors.blue;
      backgroundColor = Colors.blue.shade50;
      icon = Icons.insert_drive_file;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: iconColor, size: 28),
    );
  }

  /// Construit le badge de source
  Widget _buildSourceBadge() {
    final isGoogleDrive = resource.source == ResourceSource.googleDrive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isGoogleDrive
            ? Colors.green.shade50
            : AppTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGoogleDrive ? Icons.cloud : Icons.storage,
            size: 12,
            color: isGoogleDrive ? Colors.green : AppTheme.primaryBlue,
          ),
          const SizedBox(width: 4),
          Text(
            isGoogleDrive ? 'Drive' : 'Appwrite',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isGoogleDrive ? Colors.green : AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// Gère le téléchargement du fichier
  Future<void> _handleDownload(BuildContext context) async {
    try {
      final uri = Uri.parse(resource.downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Impossible de télécharger le fichier');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Erreur lors du téléchargement');
      }
    }
  }

  /// Gère l'ouverture du fichier
  Future<void> _handleOpen(BuildContext context) async {
    try {
      final uri = Uri.parse(resource.viewUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Impossible d\'ouvrir le fichier');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Erreur lors de l\'ouverture');
      }
    }
  }

  /// Affiche un message d'erreur
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
