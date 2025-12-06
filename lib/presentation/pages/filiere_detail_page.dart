import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/app_constants.dart';
import '../../config/app_theme.dart';
import '../../data/models/index.dart';
import '../../data/repositories/index.dart';
import '../../data/services/index.dart';
import '../bloc/index.dart';
import '../widgets/custom_error_widget.dart';
import '../widgets/custom_loader.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/empty_state_widget.dart';
import 'pdf_viewer_page.dart';

class FiliereDetailPage extends StatefulWidget {
  final Filiere filiere;

  const FiliereDetailPage({required this.filiere, super.key});

  @override
  State<FiliereDetailPage> createState() => _FiliereDetailPageState();
}

class _FiliereDetailPageState extends State<FiliereDetailPage> {
  String _searchQuery = '';
  String? _selectedYear;
  String? _expandedUEId;

  @override
  Widget build(BuildContext context) {
    final ueRepository = context.read<UERepository>();

    return BlocProvider(
      create: (context) => UEBloc(ueRepository)
        ..add(FetchUEsByFiliere(widget.filiere.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.filiere.nom),
          elevation: 0,
        ),
        body: Column(
          children: [
            _buildHeader(),
            _buildFilterSection(),
            Expanded(child: _buildUEsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.filiere.nom,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          if (widget.filiere.description.isNotEmpty)
            Text(
              widget.filiere.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textGray,
              ),
            ),
          const SizedBox(height: AppConstants.paddingDefault),
          CustomSearchBar(
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
              if (query.isNotEmpty) {
                context.read<UEBloc>().add(
                  SearchUEs(widget.filiere.id, query),
                );
              } else {
                context.read<UEBloc>().add(
                  FetchUEsByFiliere(widget.filiere.id),
                );
              }
            },
            hintText: 'Rechercher une UE...',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    // Récupérer les années uniques depuis les UEs chargées
    return BlocBuilder<UEBloc, UEState>(
      builder: (context, state) {
        if (state is! UELoaded) {
          return const SizedBox.shrink();
        }

        final years = state.ues
            .where((ue) => ue.anneeEnseignement != null)
            .map((ue) => ue.anneeEnseignement!)
            .toSet()
            .toList()
          ..sort();

        if (years.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingDefault,
            vertical: AppConstants.paddingSmall,
          ),
          child: Row(
            children: [
              const Text(
                'Année: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: years.length + 1,
                  itemBuilder: (context, index) {
                    final year = index == 0 ? null : years[index - 1];
                    final isSelected = _selectedYear == year;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(year ?? 'Toutes'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedYear = selected ? year : null;
                          });
                        },
                        selectedColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primaryBlue,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUEsList() {
    return BlocBuilder<UEBloc, UEState>(
      builder: (context, state) {
        if (state is UELoading) {
          return const CustomLoader(message: 'Chargement des UEs...');
        } else if (state is UELoaded) {
          return _buildUEsContent(state.ues);
        } else if (state is UEEmpty) {
          return const EmptyStateWidget(
            message: 'Aucune UE disponible',
            icon: Icons.folder_open,
          );
        } else if (state is UEError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<UEBloc>().add(
                FetchUEsByFiliere(widget.filiere.id),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildUEsContent(List<UE> ues) {
    // Filtrer par recherche et année
    var filteredUEs = ues;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredUEs = filteredUEs.where((ue) {
        return ue.nom.toLowerCase().contains(query) ||
            ue.description.toLowerCase().contains(query);
      }).toList();
    }

    if (_selectedYear != null) {
      filteredUEs = filteredUEs.where((ue) {
        return ue.anneeEnseignement == _selectedYear;
      }).toList();
    }

    // Trier par nom
    filteredUEs.sort((a, b) => a.nom.compareTo(b.nom));

    if (filteredUEs.isEmpty) {
      return const EmptyStateWidget(
        message: 'Aucune UE trouvée',
        icon: Icons.search_off,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<UEBloc>().add(FetchUEsByFiliere(widget.filiere.id));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingDefault),
        itemCount: filteredUEs.length,
        itemBuilder: (context, index) {
          final ue = filteredUEs[index];
          return _buildUECard(ue);
        },
      ),
    );
  }

  Widget _buildUECard(UE ue) {
    final isExpanded = _expandedUEId == ue.id;
    final files = ue.files ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la carte UE
          InkWell(
            onTap: () {
              setState(() {
                _expandedUEId = isExpanded ? null : ue.id;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingDefault),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ue.nom,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (ue.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            ue.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textGray,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (ue.anneeEnseignement != null) ...[
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(ue.anneeEnseignement!),
                            labelStyle: const TextStyle(fontSize: 12),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),
          // Ressources disponibles (affichées si la carte est expansée)
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ressources disponibles',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingDefault),
                  if (files.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(AppConstants.paddingDefault),
                      child: Text(
                        'Aucune ressource disponible',
                        style: TextStyle(color: AppColors.textGray),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppConstants.paddingDefault,
                        mainAxisSpacing: AppConstants.paddingDefault,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        return _buildFileCard(file);
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileCard(FileResource file) {
    return Card(
      elevation: 0,
      color: AppColors.primaryBlue.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () => _handlePreview(file),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                file.isPdf ? Icons.picture_as_pdf : Icons.description,
                color: AppColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                file.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.preview, size: 18),
                    onPressed: () => _handlePreview(file),
                    tooltip: 'Aperçu',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download, size: 18),
                    onPressed: () => _handleDownload(file),
                    tooltip: 'Télécharger',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePreview(FileResource file) {
    // Ouvrir directement la page PDF viewer pour tous les types
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(
          url: file.url,
          title: file.name,
          downloadUrl: file.downloadUrl,
        ),
      ),
    );
  }

  void _handleDownload(FileResource file) async {
    final downloadService = context.read<DownloadService>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DownloadDialog(
        fileName: file.name,
        downloadService: downloadService,
        downloadUrl: file.downloadUrl,
      ),
    );
  }

}

class _DownloadDialog extends StatefulWidget {
  final String fileName;
  final DownloadService downloadService;
  final String downloadUrl;

  const _DownloadDialog({
    required this.fileName,
    required this.downloadService,
    required this.downloadUrl,
  });

  @override
  State<_DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<_DownloadDialog> {
  double _progress = 0.0;
  bool _isDownloading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      final filePath = await widget.downloadService.downloadFile(
        url: widget.downloadUrl,
        fileName: widget.fileName,
        onProgress: (received, total) {
          setState(() {
            _progress = received / total;
          });
        },
      );

      if (filePath != null && mounted) {
        setState(() {
          _isDownloading = false;
        });
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Téléchargement terminé: ${widget.fileName}'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      } else {
        setState(() {
          _isDownloading = false;
          _error = 'Échec du téléchargement';
        });
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _error = 'Erreur: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Téléchargement'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isDownloading) ...[
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 16),
            Text('${(_progress * 100).toStringAsFixed(0)}%'),
          ] else if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ] else ...[
            const Text('Téléchargement terminé!'),
          ],
        ],
      ),
      actions: [
        if (!_isDownloading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
      ],
    );
  }
}
