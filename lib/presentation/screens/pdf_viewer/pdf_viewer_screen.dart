import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final isLoading = true.obs;
  final currentPage = 0.obs;
  final totalPages = 0.obs;
  final errorMessage = ''.obs;
  PDFViewController? pdfViewController;

  @override
  Widget build(BuildContext context) {
    // Récupère les paramètres passés
    final fileName = Get.parameters['fileName'] ?? 'Document';
    final filePath = Get.parameters['filePath'] ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fileName,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Obx(
              () => Text(
                totalPages.value > 0
                    ? 'Page ${currentPage.value + 1} / ${totalPages.value}'
                    : '',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              Get.snackbar(
                'Partage',
                'Fonctionnalité à venir',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.black87,
                colorText: Colors.white,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              Get.snackbar(
                'Téléchargement',
                'Fichier téléchargé avec succès',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Obx(() {
            if (errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.white70,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage.value,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Retour'),
                    ),
                  ],
                ),
              );
            }

            if (filePath.isEmpty) {
              return Center(
                child: Text(
                  'Aucun fichier sélectionné',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              );
            }

            return PDFView(
              filePath: filePath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              pageSnap: true,
              defaultPage: currentPage.value,
              fitPolicy: FitPolicy.WIDTH,
              preventLinkNavigation: false,
              backgroundColor: Colors.grey[900]!,
              onRender: (pages) {
                totalPages.value = pages ?? 0;
                isLoading.value = false;
              },
              onError: (error) {
                errorMessage.value = 'Erreur lors du chargement du PDF';
                isLoading.value = false;
              },
              onPageError: (page, error) {
                errorMessage.value = 'Erreur page $page: $error';
              },
              onViewCreated: (PDFViewController controller) {
                pdfViewController = controller;
              },
              onPageChanged: (int? page, int? total) {
                if (page != null) {
                  currentPage.value = page;
                }
              },
            );
          }),

          // Indicateur de chargement
          Obx(
            () => isLoading.value
                ? Container(
                    color: Colors.black87,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        if (totalPages.value == 0) return const SizedBox();

        return Container(
          color: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bouton page précédente
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: currentPage.value > 0
                    ? () {
                        pdfViewController?.setPage(currentPage.value - 1);
                      }
                    : null,
              ),

              // Indicateur de page
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${currentPage.value + 1} / ${totalPages.value}',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Bouton page suivante
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onPressed: currentPage.value < totalPages.value - 1
                    ? () {
                        pdfViewController?.setPage(currentPage.value + 1);
                      }
                    : null,
              ),
            ],
          ),
        );
      }),
    );
  }
}
