import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FileListItem extends StatelessWidget {
  final String resourceId;
  final String title;
  final String? subtitle;
  final String fileUrl;
  final String downloadUrl;

  const FileListItem({
    super.key,
    required this.resourceId,
    required this.title,
    this.subtitle,
    required this.fileUrl,
    required this.downloadUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Déterminer si c'est un fichier PDF basé sur l'extension ou le titre
    final isPdf = title.toLowerCase().endsWith('.pdf') ||
                  (subtitle?.toLowerCase().contains('pdf') ?? false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isPdf ? Colors.red.shade50 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
            color: isPdf ? Colors.red : Colors.blue,
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                'ID: ${resourceId.substring(0, 8)}...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Télécharger',
              color: Colors.green,
              onPressed: () async {
                final uri = Uri.parse(downloadUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Impossible de télécharger le fichier'),
                      ),
                    );
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'Ouvrir',
              color: Colors.blue,
              onPressed: () async {
                final uri = Uri.parse(fileUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Impossible d\'ouvrir le fichier'),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

