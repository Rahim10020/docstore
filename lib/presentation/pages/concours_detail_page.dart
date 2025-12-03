import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import '../../config/app_theme.dart';
import '../../data/models/index.dart';
import '../../data/repositories/concours_repository.dart';
import '../../data/services/appwrite_service.dart';
import '../widgets/index.dart';

class ConcoursDetailPage extends StatefulWidget {
  final Concours concours;
  final String? ecoleNom;

  const ConcoursDetailPage({required this.concours, this.ecoleNom, super.key});

  @override
  State<ConcoursDetailPage> createState() => _ConcoursDetailPageState();
}

class _ConcoursDetailPageState extends State<ConcoursDetailPage> {
  late final ConcoursRepository _repository;
  List<FileResource>? _communiques;
  List<FileResource>? _ressources;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = ConcoursRepository(AppwriteService());
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final communiques = await _repository.getCommuniquesFromConcours(
        widget.concours,
      );
      final ressources = await _repository.getRessourcesFromConcours(
        widget.concours,
      );

      setState(() {
        _communiques = communiques;
        _ressources = ressources;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des fichiers';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails du concours')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(gradient: AppColors.concoursGradient),
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.concours.nom,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineLarge?.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  if (widget.ecoleNom != null)
                    Text(
                      widget.ecoleNom!,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: AppColors.white),
                    ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppColors.white.withValues(alpha: 0.8),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Année ${widget.concours.annee}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    widget.concours.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),

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
                      onRetry: _loadFiles,
                    )
                  else ...[
                    // Communiqués
                    if (_communiques != null && _communiques!.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Communiqués',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '(${_communiques!.length})',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppColors.textLight),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _communiques!.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppConstants.paddingSmall),
                        itemBuilder: (context, index) {
                          final file = _communiques![index];
                          return _FileResourceCard(resource: file);
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                    ],

                    // Ressources
                    if (_ressources != null && _ressources!.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ressources',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '(${_ressources!.length})',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppColors.textLight),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _ressources!.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppConstants.paddingSmall),
                        itemBuilder: (context, index) {
                          final file = _ressources![index];
                          return _FileResourceCard(resource: file);
                        },
                      ),
                    ],

                    if ((_communiques == null || _communiques!.isEmpty) &&
                        (_ressources == null || _ressources!.isEmpty))
                      const EmptyStateWidget(
                        message: 'Aucun fichier disponible',
                        icon: Icons.file_present,
                      ),
                  ],

                  const SizedBox(height: AppConstants.paddingLarge),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement share functionality
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Partager'),
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
                Expanded(
                  child: Text(
                    _getSourceLabel(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textLight),
                  ),
                ),
                if (resource.size != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '• ${resource.formattedSize}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
