import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/app_constants.dart';
import '../../config/app_theme.dart';
import '../../data/models/index.dart';
import '../../data/repositories/index.dart';
import '../../data/services/appwrite_service.dart';
import '../bloc/ressource_bloc.dart';
import '../bloc/ressource_event.dart';
import '../bloc/ressource_state.dart';
import '../widgets/custom_error_widget.dart';
import '../widgets/custom_loader.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/ressource_card.dart';

class FiliereDetailPage extends StatefulWidget {
  final Filiere filiere;

  const FiliereDetailPage({required this.filiere, super.key});

  @override
  State<FiliereDetailPage> createState() => _FiliereDetailPageState();
}

class _FiliereDetailPageState extends State<FiliereDetailPage> {
  String _searchQuery = '';
  String? _selectedType;

  final List<String> _ressourceTypes = [
    'Tous',
    'Cours',
    'Exercices',
    'TD',
    'TP',
    'Communiqué',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RessourceBloc(context.read<RessourceRepository>())
            ..add(FetchRessourcesByFiliere(widget.filiere.id)),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.filiere.nom), elevation: 0),
        body: Column(
          children: [
            _buildHeader(),
            _buildFilterChips(),
            Expanded(child: _buildRessourcesList()),
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
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            widget.filiere.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
          ),
          const SizedBox(height: AppConstants.paddingDefault),
          CustomSearchBar(
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            hintText: 'Rechercher une ressource...',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingDefault,
        vertical: AppConstants.paddingSmall,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _ressourceTypes.length,
        itemBuilder: (context, index) {
          final type = _ressourceTypes[index];
          final isSelected =
              _selectedType == type ||
              (type == 'Tous' && _selectedType == null);

          return Padding(
            padding: const EdgeInsets.only(right: AppConstants.paddingSmall),
            child: FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (type == 'Tous') {
                    _selectedType = null;
                    context.read<RessourceBloc>().add(
                      FetchRessourcesByFiliere(widget.filiere.id),
                    );
                  } else {
                    _selectedType = type;
                    context.read<RessourceBloc>().add(
                      FetchRessourcesByType(widget.filiere.id, type),
                    );
                  }
                });
              },
              selectedColor: AppColors.primaryBlue.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primaryBlue,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryBlue : AppColors.textGray,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRessourcesList() {
    return BlocBuilder<RessourceBloc, RessourceState>(
      builder: (context, state) {
        if (state is RessourceLoading) {
          return const CustomLoader(message: 'Chargement des ressources...');
        } else if (state is RessourceLoaded) {
          return _buildRessourcesContent(state.ressources);
        } else if (state is RessourceEmpty) {
          return const EmptyStateWidget(
            message: 'Aucune ressource disponible',
            icon: Icons.folder_open,
          );
        } else if (state is RessourceError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: () {
              if (_selectedType == null) {
                context.read<RessourceBloc>().add(
                  FetchRessourcesByFiliere(widget.filiere.id),
                );
              } else {
                context.read<RessourceBloc>().add(
                  FetchRessourcesByType(widget.filiere.id, _selectedType!),
                );
              }
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRessourcesContent(List<Ressource> ressources) {
    // Filtrer par recherche
    final filteredRessources = _searchQuery.isEmpty
        ? ressources
        : ressources.where((ressource) {
            final query = _searchQuery.toLowerCase();
            return ressource.nom.toLowerCase().contains(query) ||
                (ressource.description?.toLowerCase().contains(query) ?? false);
          }).toList();

    if (filteredRessources.isEmpty) {
      return const EmptyStateWidget(
        message: 'Aucune ressource trouvée',
        icon: Icons.search_off,
      );
    }

    // Grouper par type
    final groupedRessources = <String, List<Ressource>>{};
    for (final ressource in filteredRessources) {
      if (!groupedRessources.containsKey(ressource.type)) {
        groupedRessources[ressource.type] = [];
      }
      groupedRessources[ressource.type]!.add(ressource);
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedType == null) {
          context.read<RessourceBloc>().add(
            FetchRessourcesByFiliere(widget.filiere.id),
          );
        } else {
          context.read<RessourceBloc>().add(
            FetchRessourcesByType(widget.filiere.id, _selectedType!),
          );
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingDefault),
        itemCount: groupedRessources.length,
        itemBuilder: (context, index) {
          final type = groupedRessources.keys.elementAt(index);
          final ressources = groupedRessources[type]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingSmall,
                ),
                child: Row(
                  children: [
                    Icon(
                      _getTypeIcon(type),
                      color: _getTypeColor(type),
                      size: 20,
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Text(
                      type,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getTypeColor(type),
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(type).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${ressources.length}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getTypeColor(type),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...ressources.map(
                (ressource) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppConstants.paddingSmall,
                  ),
                  child: RessourceCard(
                    nom: ressource.nom,
                    type: ressource.type,
                    onTap: () => _handleRessourceTap(ressource),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingDefault),
            ],
          );
        },
      ),
    );
  }

  void _handleRessourceTap(Ressource ressource) {
    // TODO: Implémenter le téléchargement/ouverture de la ressource
    final appwriteService = AppwriteService();
    final fileUrl = appwriteService.getFileView(ressource.url);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture de ${ressource.nom}...'),
        action: SnackBarAction(
          label: 'Voir',
          onPressed: () {
            // TODO: Ouvrir le PDF viewer ou télécharger
            debugPrint('File URL: $fileUrl');
          },
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'cours':
        return AppColors.primaryBlue;
      case 'exercices':
      case 'td':
        return AppColors.secondaryOrange;
      case 'tp':
        return AppColors.primaryIndigo;
      case 'communiqué':
        return AppColors.successGreen;
      default:
        return AppColors.textLight;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cours':
        return Icons.book;
      case 'exercices':
        return Icons.assignment;
      case 'td':
        return Icons.description;
      case 'tp':
        return Icons.construction;
      case 'communiqué':
        return Icons.notification_important;
      default:
        return Icons.file_present;
    }
  }
}
