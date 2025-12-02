import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:logger/logger.dart';

class PdfViewerPage extends StatefulWidget {
  final String url;
  final String title;

  const PdfViewerPage({required this.url, required this.title, super.key});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late PdfViewerController _pdfViewerController;
  final Logger _logger = Logger();
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
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
      body: _hasError
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
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _PdfViewerWrapper(
              url: widget.url,
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

  @override
  Widget build(BuildContext context) {
    return SfPdfViewer.network(
      widget.url,
      controller: widget.controller,
      pageLayoutMode: PdfPageLayoutMode.continuous,
      interactionMode: PdfInteractionMode.selection,
      enableDocumentLinkAnnotation: true,
      canShowScrollHead: true,
      onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
        _logger.e('PDF load failed: ${details.description}');
        widget.onError();
      },
    );
  }
}
