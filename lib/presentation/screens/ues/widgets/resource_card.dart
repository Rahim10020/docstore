import 'package:flutter/material.dart';

class ResourceCard extends StatelessWidget {
  final String fileName;
  final VoidCallback onView;
  final VoidCallback onDownload;

  const ResourceCard({
    super.key,
    required this.fileName,
    required this.onView,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icône PDF
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'PDF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Nom du fichier
            Expanded(
              child: Text(
                fileName,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Bouton voir
            IconButton(
              onPressed: onView,
              icon: const Icon(Icons.visibility),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFD1FAE5),
                foregroundColor: const Color(0xFF059669),
              ),
            ),
            const SizedBox(width: 8),
            // Bouton télécharger
            IconButton(
              onPressed: onDownload,
              icon: const Icon(Icons.download),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFE9D5FF),
                foregroundColor: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
