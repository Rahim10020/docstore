import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';

class DocumentViewerScreen extends StatelessWidget {
  final String documentUrl;
  final String documentName;
  final bool isPdf;

  const DocumentViewerScreen({
    super.key,
    required this.documentUrl,
    required this.documentName,
    this.isPdf = true,
  });

  @override
  Widget build(BuildContext context) {
    if (documentUrl.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'URL du document non disponible',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColorLight,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header with WhatsApp share
            _DocumentViewerHeader(
              documentName: documentName,
              documentUrl: documentUrl,
              onBack: () => Navigator.pop(context),
            ),
            // Document content
            Expanded(
              child: isPdf
                  ? _PdfViewer(documentUrl: documentUrl)
                  : _ImageViewer(documentUrl: documentUrl),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentViewerHeader extends StatelessWidget {
  final String documentName;
  final String documentUrl;
  final VoidCallback onBack;

  const _DocumentViewerHeader({
    required this.documentName,
    required this.documentUrl,
    required this.onBack,
  });

  Future<void> _shareViaWhatsApp(BuildContext context) async {
    try {
      // Try to share directly via WhatsApp
      final whatsappUrl = Uri.parse(
        'whatsapp://send?text=${Uri.encodeComponent('Voici le document: $documentName\n$documentUrl')}',
      );

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to regular share sheet if WhatsApp is not installed
        await Share.share(
          'Voici le document: $documentName\n$documentUrl',
          subject: documentName,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'WhatsApp non installé, utilisation du menu de partage',
              ),
              backgroundColor: AppTheme.mutedText,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du partage: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.backgroundColorLight,
              foregroundColor: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documentName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Appuyez pour partager via WhatsApp',
                  style: TextStyle(fontSize: 12, color: AppTheme.mutedText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // WhatsApp share button
          InkWell(
            onTap: () => _shareViaWhatsApp(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                'assets/icons/share.svg',
                width: 20,
                height: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // More options menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            onSelected: (value) async {
              if (value == 'share') {
                await Share.share(
                  'Voici le document: $documentName\n$documentUrl',
                  subject: documentName,
                );
              } else if (value == 'download') {
                final uri = Uri.parse(documentUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              } else if (value == 'browser') {
                final uri = Uri.parse(documentUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/share.svg',
                      width: 20,
                      height: 20,
                    ),
                    SizedBox(width: 12),
                    Text('Partager'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/download.svg',
                      width: 20,
                      height: 20,
                    ),
                    SizedBox(width: 12),
                    Text('Télécharger'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'browser',
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/browser.svg',
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Ouvrir dans le navigateur'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PdfViewer extends StatelessWidget {
  final String documentUrl;

  const _PdfViewer({required this.documentUrl});

  @override
  Widget build(BuildContext context) {
    return PDF(
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: false,
      pageFling: true,
      pageSnap: true,
      onPageChanged: (int? current, int? total) {
        debugPrint('Page $current sur $total');
      },
      onError: (error) {
        debugPrint('Erreur PDF: $error');
      },
      onPageError: (int? page, dynamic error) {
        debugPrint('Erreur page $page: $error');
      },
    ).cachedFromUrl(
      documentUrl,
      placeholder: (progress) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: progress,
              color: AppTheme.primaryPurple,
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement: ${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
      errorWidget: (error) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Erreur lors du chargement du PDF',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppTheme.mutedText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageViewer extends StatelessWidget {
  final String documentUrl;

  const _ImageViewer({required this.documentUrl});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      panEnabled: true,
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.network(
          documentUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                color: AppTheme.primaryPurple,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Erreur lors du chargement de l\'image',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.mutedText,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
