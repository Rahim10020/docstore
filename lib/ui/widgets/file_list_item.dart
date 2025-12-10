import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/drive_file.dart';

  final String resourceId;
  final String title;
  final String? subtitle;
  final String fileUrl;
  final String downloadUrl;
    super.key,
    required this.file,
    required this.onTap,
  });
    required this.resourceId,
    required this.title,
    this.subtitle,
    required this.fileUrl,
    required this.downloadUrl,
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isPdf ? Colors.red.shade50 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
            color: Colors.red.shade50,
          ),
        ),
          child: const Icon(
            Icons.picture_as_pdf,
            color: Colors.red,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          title,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          file.mimeType,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              )
            : null,
                  final uri = Uri.parse(file.webViewLink!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Télécharger',
              onPressed: () async {
                final uri = Uri.parse(downloadUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'Ouvrir',
              onPressed: () async {
                final uri = Uri.parse(fileUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
