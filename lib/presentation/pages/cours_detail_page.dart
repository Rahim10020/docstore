import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import '../../config/app_theme.dart';
import '../../data/models/index.dart';
import '../../data/repositories/cours_repository.dart';
import '../../data/services/appwrite_service.dart';
import '../widgets/index.dart';

class CoursDetailPage extends StatefulWidget {
  final Cours cours;

  const CoursDetailPage({required this.cours, super.key});

  @override
  State<CoursDetailPage> createState() => _CoursDetailPageState();
}

class _CoursDetailPageState extends State<CoursDetailPage> {
  late final CoursRepository _repository;
  List<FileResource>? _ressources;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = CoursRepository(AppwriteService());
    _loadResources();
  }

  Future<void> _loadResources() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final resources = await _repository.getResourcesFromCours(widget.cours);

      setState(() {
        _ressources = resources;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des ressources';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails du cours')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: AppColors.bgLighter,
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.cours.titre,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  if (widget.cours.description.isNotEmpty)
                    Text(
                      widget.cours.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ressources',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (_ressources != null)
                        Text(
                          '(${_ressources!.length})',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.textLight),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppConstants.paddingLarge),
                        child: CustomLoader(),
                      ),
                    )
                  else if (_errorMessage != null)
                    CustomErrorWidget(
                      message: _errorMessage!,
                      onRetry: _loadResources,
                    )
                  else if (_ressources != null && _ressources!.isNotEmpty)
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _ressources!.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppConstants.paddingSmall),
                      itemBuilder: (context, index) {
                        final resource = _ressources![index];
                        return _FileResourceCard(resource: resource);
                      },
                    )
                  else
                    const EmptyStateWidget(
                      message: 'Aucune ressource disponible',
                      icon: Icons.file_present,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileResourceCard extends StatelessWidget {
  final FileResource resource;

  const _FileResourceCard({required this.resource});

  String _getSourceLabel() {
    switch (resource.sourceType) {
      case FileSourceType.googleDrive:
        return 'Google Drive';
      case FileSourceType.appwrite:
        return 'Appwrite';
    }
  }

  IconData _getSourceIcon() {
    switch (resource.sourceType) {
      case FileSourceType.googleDrive:
        return Icons.cloud;
      case FileSourceType.appwrite:
        return Icons.storage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryIndigo.withValues(alpha: 0.1),
          child: Icon(
            resource.isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
            color: AppColors.primaryIndigo,
          ),
        ),
        title: Text(
          resource.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(_getSourceIcon(), size: 14, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(
                  _getSourceLabel(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textLight),
                ),
                if (resource.size != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '• ${resource.formattedSize}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textLight),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/pdf-viewer',
            arguments: {
              'url': resource.url,
              'downloadUrl': resource.downloadUrl,
              'title': resource.name,
            },
          );
        },
      ),
    );
  }
}
