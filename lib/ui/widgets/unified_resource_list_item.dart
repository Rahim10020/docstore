import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/unified_resource_service.dart';
import '../../core/theme.dart';
import '../../providers/saved_resources_provider.dart';
import '../screens/document_viewer_screen.dart';

class UnifiedResourceListItem extends ConsumerWidget {
  final UnifiedResource resource;
  final VoidCallback? onTap;

  const UnifiedResourceListItem({
    super.key,
    required this.resource,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildFileIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Row(
                  children: [
                    _buildSourceBadge(),
                    if (resource.size != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        UnifiedResourceService().formatFileSize(resource.size),
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
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionChip(
                iconWidget: SvgPicture.asset(
                  'assets/icons/view.svg',
                  width: 20,
                  height: 20,
                ),
                color: AppTheme.successColor,
                onTap: () => _handleView(context),
              ),
              const SizedBox(width: 8),
              _ActionChip(
                iconWidget: SvgPicture.asset(
                  'assets/icons/download.svg',
                  width: 20,
                  height: 20,
                ),
                color: AppTheme.primaryPurple,
                onTap: () => _handleDownload(context),
              ),
              const SizedBox(width: 8),
              _SaveActionChip(
                resourceId: resource.id,
                isSaved: ref
                    .watch(savedResourcesProvider)
                    .contains(resource.id),
                onToggle: () async {
                  final result = await ref
                      .read(savedResourcesProvider.notifier)
                      .toggleSave(resource.id);
                  if (result != null && context.mounted) {
                    _showSaveSnackBar(context, ref, result);
                  }
                },
              ),
            ],
          ),
        ],
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
            : AppTheme.primaryBlue.withValues(alpha: 0.1),
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

  /// Gère la visualisation du document dans l'application
  Future<void> _handleView(BuildContext context) async {
    try {
      // Open the document in the in-app viewer
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentViewerScreen(
            documentUrl: resource.viewUrl,
            documentName: resource.name,
            isPdf: resource.isPdf,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Erreur lors de l\'ouverture du document');
      }
    }
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

  /// Affiche un snackbar pour les actions de sauvegarde
  void _showSaveSnackBar(
    BuildContext context,
    WidgetRef ref,
    SaveActionResult result,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.wasSaved
            ? AppTheme.successColor
            : AppTheme.mutedText,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final Widget iconWidget;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.iconWidget,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          child: iconWidget,
        ),
      ),
    );
  }
}

class _SaveActionChip extends StatelessWidget {
  final String resourceId;
  final bool isSaved;
  final VoidCallback onToggle;

  const _SaveActionChip({
    required this.resourceId,
    required this.isSaved,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSaved
              ? AppTheme.primaryPurple.withValues(alpha: 0.12)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SvgPicture.asset(
          isSaved ? 'assets/icons/saved-fill.svg' : 'assets/icons/saved.svg',
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(
            isSaved ? AppTheme.primaryPurple : Colors.grey.shade600,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
