import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/models/concours.dart';
import '../../services/unified_resource_service.dart';
import '../widgets/unified_resource_list_item.dart';

class ConcoursDetailScreen extends ConsumerStatefulWidget {
  final Concours concours;

  const ConcoursDetailScreen({super.key, required this.concours});

  @override
  ConsumerState<ConcoursDetailScreen> createState() =>
      _ConcoursDetailScreenState();
}

class _ConcoursDetailScreenState extends ConsumerState<ConcoursDetailScreen> {
  final UnifiedResourceService _resourceService = UnifiedResourceService();
  List<UnifiedResource>? _resources;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    if (widget.concours.ressources.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resources = await _resourceService.getResources(
        widget.concours.ressources,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.concours.nom ?? 'Concours'),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: RefreshIndicator(
          onRefresh: _loadResources,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec infos du concours
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: AppTheme.concoursGradient,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.emoji_events,
                                color: AppTheme.primaryOrange,
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.concours.nom ?? 'Concours',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (widget.concours.annee != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Année: ${widget.concours.annee}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (widget.concours.description != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            widget.concours.description!,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Section Ressources
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ressources disponibles',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (widget.concours.ressources.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.concours.ressources.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryOrange,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                  )
                else if (_error != null)
                  Card(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.errorColor,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Erreur lors du chargement',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.errorColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            style: TextStyle(
                              fontSize: 12,
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
                else if (widget.concours.ressources.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.folder_off,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aucune ressource disponible',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (_resources != null)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _resources!.length,
                    itemBuilder: (context, index) {
                      return UnifiedResourceListItem(
                        resource: _resources![index],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

