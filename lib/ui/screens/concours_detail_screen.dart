import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme.dart';
import '../../data/models/concours.dart';
import '../../services/unified_resource_service.dart';
import '../widgets/unified_resource_list_item.dart';
import '../widgets/rounded_search_input.dart';

class ConcoursDetailScreen extends ConsumerStatefulWidget {
  final Concours concours;

  const ConcoursDetailScreen({super.key, required this.concours});

  @override
  ConsumerState<ConcoursDetailScreen> createState() =>
      _ConcoursDetailScreenState();
}

class _ConcoursDetailScreenState extends ConsumerState<ConcoursDetailScreen> {
  final UnifiedResourceService _resourceService = UnifiedResourceService();
  final TextEditingController _searchController = TextEditingController();
  List<UnifiedResource>? _resources;
  List<UnifiedResource>? _communiques;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    if (widget.concours.ressources.isEmpty &&
        widget.concours.communiques.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resources = await _resourceService.getResources(
        widget.concours.ressources,
      );
      final communiques = await _resourceService.getResources(
        widget.concours.communiques,
      );
      if (mounted) {
        setState(() {
          _resources = resources;
          _communiques = communiques;
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

  // helper safe lower
  String _safeLower(Object? v) => v == null ? '' : v.toString().toLowerCase();

  List<UnifiedResource> _filterResources(List<UnifiedResource> resources) {
    if (_searchQuery.isEmpty) return resources;

    final q = _safeLower(_searchQuery);
    return resources.where((resource) {
      final name = _safeLower(resource.name);
      return name.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredResources = _resources != null
        ? _filterResources(_resources!)
        : null;
    final filteredCommuniques = _communiques != null
        ? _filterResources(_communiques!)
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
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.concoursCardGradient,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.concours.nom ?? 'Concours',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${widget.concours.idEcole ?? 'Ecole'} • ${widget.concours.annee ?? 'Année'}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.concours.ressources.isNotEmpty ||
                      widget.concours.communiques.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    RoundedSearchInput(
                      controller: _searchController,
                      hintText: 'Rechercher un document...',
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                    ),
                  ],
                ],
              ),
            ),
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
                              const SizedBox(height: 12),
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
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 24),
                          children: [
                            if (widget.concours.communiques.isNotEmpty)
                              _ResourceSection(
                                title: 'Communiques officiels',
                                count: filteredCommuniques?.length ?? 0,
                                children:
                                    filteredCommuniques
                                        ?.map(
                                          (r) => UnifiedResourceListItem(
                                            resource: r,
                                          ),
                                        )
                                        .toList() ??
                                    [],
                              ),
                            if (widget.concours.ressources.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _ResourceSection(
                                title: 'Ressources et epreuves disponibles',
                                count: filteredResources?.length ?? 0,
                                children:
                                    filteredResources
                                        ?.map(
                                          (r) => UnifiedResourceListItem(
                                            resource: r,
                                          ),
                                        )
                                        .toList() ??
                                    [],
                              ),
                            ],
                            if (widget.concours.communiques.isEmpty &&
                                widget.concours.ressources.isEmpty)
                              const Center(
                                child: Text(
                                  'Aucun document disponible',
                                  style: TextStyle(color: AppTheme.mutedText),
                                ),
                              ),
                          ],
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

class _ResourceSection extends StatelessWidget {
  final String title;
  final int count;
  final List<Widget> children;

  const _ResourceSection({
    required this.title,
    required this.count,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text('$count', style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}
