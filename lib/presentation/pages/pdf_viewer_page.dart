import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import '../../data/services/index.dart';

class PdfViewerPage extends StatefulWidget {
  final String url;
  final String title;
  final String? downloadUrl;

  const PdfViewerPage({
    required this.url,
    required this.title,
    this.downloadUrl,
    super.key,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late PdfViewerController _pdfViewerController;
  final Logger _logger = Logger();
  bool _hasError = false;
  String? _resolvedUrl;
  bool _isResolvingUrl = true;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _resolveUrl();
  }

  Future<void> _resolveUrl() async {
    try {
      String urlToUse = widget.url;

      // If downloadUrl is provided, use it (more reliable for PDFs)
      if (widget.downloadUrl != null && widget.downloadUrl!.isNotEmpty) {
        urlToUse = widget.downloadUrl!;
      }

      // If URL is a Google Drive link, convert it to a download URL
      final googleDriveService = GoogleDriveService();
      if (googleDriveService.isGoogleDriveUrl(urlToUse)) {
        final fileId = googleDriveService.extractFileId(urlToUse);
        if (fileId != null) {
          urlToUse = googleDriveService.getDownloadUrl(fileId);
          _logger.i('Converted Google Drive URL to download URL');
        }
      }

      setState(() {
        _resolvedUrl = urlToUse;
        _isResolvingUrl = false;
      });
    } catch (e) {
      _logger.e('Error resolving URL: $e');
      setState(() {
        _isResolvingUrl = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implement download
            },
          ),
        ],
      ),
      body: _isResolvingUrl
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load PDF'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _isResolvingUrl = true;
                      });
                      _resolveUrl();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _PdfViewerWrapper(
              url: _resolvedUrl!,
              controller: _pdfViewerController,
              onError: () {
                setState(() {
                  _hasError = true;
                });
              },
            ),
    );
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }
}

class _PdfViewerWrapper extends StatefulWidget {
  final String url;
  final PdfViewerController controller;
  final VoidCallback onError;

  const _PdfViewerWrapper({
    required this.url,
    required this.controller,
    required this.onError,
  });

  @override
  State<_PdfViewerWrapper> createState() => _PdfViewerWrapperState();
}

class _PdfViewerWrapperState extends State<_PdfViewerWrapper> {
  final Logger _logger = Logger();
  bool _errorHandled = false;

  @override
  void initState() {
    super.initState();
    // Add a delay to allow the widget to render before potential errors
    _scheduleDocumentLoad();
  }

  void _scheduleDocumentLoad() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SfPdfViewer.network(
      widget.url,
      controller: widget.controller,
      pageLayoutMode: PdfPageLayoutMode.continuous,
      interactionMode: PdfInteractionMode.selection,
      enableDocumentLinkAnnotation: true,
      canShowScrollHead: true,
      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
        if (mounted && !_errorHandled) {
          _logger.i('PDF document loaded successfully');
        }
      },
      onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
        _errorHandled = true;
        _logger.e('PDF load failed: ${details.description}');
        if (mounted) {
          widget.onError();
        }
      },
    );
  }
}
