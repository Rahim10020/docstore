import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import '../../data/models/drive_file.dart';

class PdfViewerScreen extends StatelessWidget {
  final DriveFile file;

  const PdfViewerScreen({
    super.key,
    required this.file,
  });

  String get _pdfUrl {
    // Utiliser webContentLink si disponible, sinon webViewLink
    return file.webContentLink ?? file.webViewLink ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (_pdfUrl.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(file.name),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'URL du PDF non disponible',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          file.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implémenter le téléchargement
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Téléchargement à implémenter'),
                ),
              );
            },
          ),
        ],
      ),
      body: PDF(
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: true,
        onPageChanged: (int? current, int? total) {
          debugPrint('Page $current sur $total');
        },
        onError: (error) {
          debugPrint('Erreur PDF: $error');
        },
        onPageError: (int? page, dynamic error) {
          debugPrint('Erreur page $page: $error');
        },
        onLinkHandler: (String? uri) {
          debugPrint('Lien cliqué: $uri');
        },
      ).cachedFromUrl(
        _pdfUrl,
        placeholder: (progress) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(value: progress),
              const SizedBox(height: 16),
              Text('Chargement: ${(progress * 100).toStringAsFixed(0)}%'),
            ],
          ),
        ),
        errorWidget: (error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Erreur lors du chargement du PDF',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

