import 'package:docstore/ui/widgets/unified_resource_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme.dart';
import '../../data/models/ue.dart';
import '../../services/unified_resource_service.dart';
import '../widgets/rounded_search_input.dart';

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
    final filteredResources = _resources != null
        ? _filterResources(_resources!)
        : null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColorLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      ),
                      const Spacer(),
                      SvgPicture.asset(
                        'assets/icons/more.svg',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ue.nom,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryPurple.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.ue.anneeEnseignement.isNotEmpty
                                    ? widget.ue.anneeEnseignement.join(', ')
                                    : 'Annee',
                                style: const TextStyle(
                                  color: AppTheme.primaryPurple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (widget.ue.description != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            widget.ue.description!,
                            style: TextStyle(
                              color: AppTheme.textPrimary.withValues(
                                alpha: 0.75,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.ue.ressources.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundedSearchInput(
                  controller: _searchController,
                  hintText: 'Rechercher une ressource...',
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadResources,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryPurple,
                          ),
                        )
                      : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppTheme.errorColor,
                                size: 54,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppTheme.mutedText,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadResources,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reessayer'),
                              ),
                            ],
                          ),
                        )
                      : widget.ue.ressources.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucune ressource disponible',
                            style: TextStyle(color: AppTheme.mutedText),
                          ),
                        )
                      : filteredResources != null && filteredResources.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucune ressource trouvee',
                            style: TextStyle(color: AppTheme.mutedText),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24, top: 8),
                          itemCount: filteredResources?.length ?? 0,
                          itemBuilder: (context, index) {
                            return UnifiedResourceListItem(
                              resource: filteredResources![index],
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
