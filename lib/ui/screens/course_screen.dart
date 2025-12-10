import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/models/school.dart';
import '../../data/models/department.dart';
import '../../providers/data_provider.dart';
import '../widgets/file_list_item.dart';
import 'pdf_viewer_screen.dart';

class CourseScreen extends ConsumerStatefulWidget {
  final School school;
  final Department department;
  final String? selectedLevel; // Optionnel: niveau sélectionné

  const CourseScreen({
    super.key,
    required this.school,
    required this.department,
    this.selectedLevel,
  });

  @override
  ConsumerState<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends ConsumerState<CourseScreen> {
  String? selectedFolderId;
  String? selectedLevel;

  @override
  void initState() {
    super.initState();
    selectedLevel = widget.selectedLevel ?? widget.department.levels.first;
  }

  void _loadCourseFiles(String folderId) {
    setState(() {
      selectedFolderId = folderId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.department.name),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            // Sélecteur de niveau
            Container(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.department.levels.map((level) {
                  final isSelected = selectedLevel == level;
                  return FilterChip(
                    label: Text(level),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedLevel = level;
                        selectedFolderId = null;
                      });
                    },
                    selectedColor: AppTheme.primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
            ),

            // Liste des cours ou fichiers
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Si un cours est sélectionné, afficher les fichiers
    if (selectedFolderId != null) {
      return _buildFilesList();
    }

    // Sinon, afficher la liste des cours disponibles
    return _buildCoursesList();
  }

  Widget _buildCoursesList() {
    final courseFolders = widget.department.courseFolders ?? {};

    if (courseFolders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_off,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun cours disponible',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Les dossiers Google Drive doivent être configurés dans schools_data.dart',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courseFolders.length,
      itemBuilder: (context, index) {
        final courseName = courseFolders.keys.elementAt(index);
        final folderId = courseFolders[courseName];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.book,
                color: AppTheme.primaryIndigo,
              ),
            ),
            title: Text(
              courseName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: const Text('Cliquer pour voir les fichiers'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 20),
            onTap: () => _loadCourseFiles(folderId!),
          ),
        );
      },
    );
  }

  Widget _buildFilesList() {
    final folderId = selectedFolderId!;
    final filesAsync = ref.watch(folderFilesProvider(folderId));

    return filesAsync.when(
      data: (files) {
        if (files.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Icon(
                Icons.folder_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
                const SizedBox(height: 16),
                Text(
                  'Aucun fichier dans ce dossier',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            return FileListItem(
              file: file,
              onTap: () {
                if (file.mimeType == 'application/pdf') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfViewerScreen(
                        file: file,
                      ),
                    ),
                  );
                } else {
                  // Ouvrir dans le navigateur pour les autres types
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Type de fichier non supporté: ${file.mimeType}'),
                    ),
                  );
                }
              },
            );
          },
        );
      },
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement des fichiers...'),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur lors du chargement',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(folderFilesProvider(folderId));
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

