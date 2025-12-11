import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({super.key, required this.pdfUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    if (pdfUrl.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('URL du PDF non disponible', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/download.svg',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              // TODO: Implémenter le téléchargement
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Téléchargement à implémenter')),
              );
            },
          ),
        ],
      ),
      body:
          PDF(
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
            pdfUrl,
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
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
