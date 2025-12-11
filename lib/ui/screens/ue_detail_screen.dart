import 'package:docstore/ui/widgets/unified_resource_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/models/ue.dart';
import '../../services/unified_resource_service.dart';

class UeDetailScreen extends ConsumerStatefulWidget {
  final Ue ue;

  const UeDetailScreen({super.key, required this.ue});

  @override
  ConsumerState<UeDetailScreen> createState() => _UeDetailScreenState();
}

class _UeDetailScreenState extends ConsumerState<UeDetailScreen> {
  final UnifiedResourceService _resourceService = UnifiedResourceService();
  final TextEditingController _searchController = TextEditingController();
  List<UnifiedResource>? _resources;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Charge les ressources de l'UE
  Future<void> _loadResources() async {
    if (widget.ue.ressources.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resources = await _resourceService.getResources(
        widget.ue.ressources,
      );
      if (mounted) {
        setState(() {
          _resources = resources;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<UnifiedResource> _filterResources(List<UnifiedResource> resources) {
    if (_searchQuery.isEmpty) return resources;

    return resources.where((resource) {
      return resource.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredResources = _resources != null ? _filterResources(_resources!) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.ue.nom,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Column(
          children: [
            // En-tête avec infos de l'UE
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryIndigo.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.book,
                            color: AppTheme.primaryIndigo,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.ue.nom,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              if (widget.ue.anneeEnseignement.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.ue.anneeEnseignement.join(', '),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.ue.description != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        widget.ue.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  const Divider(height: 1),
                ],
              ),
            ),

            // Barre de recherche (si des ressources existent)
            if (widget.ue.ressources.isNotEmpty && _resources != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher une ressource...',
                          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryIndigo),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryIndigo.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${filteredResources?.length ?? 0}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryIndigo,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Contenu
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadResources,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryIndigo,
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppTheme.errorColor,
                                    size: 64,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Erreur lors du chargement',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.errorColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _error!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _loadResources,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Réessayer'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : widget.ue.ressources.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.folder_off,
                                      size: 80,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Aucune ressource disponible',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : filteredResources != null && filteredResources.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_off,
                                          size: 80,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Aucune ressource trouvée',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Essayez avec d\'autres mots-clés',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: filteredResources?.length ?? 0,
                                    itemBuilder: (context, index) {
                                      return UnifiedResourceListItem(
                                        resource: filteredResources![index],
                                      );
                                    },
                                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
