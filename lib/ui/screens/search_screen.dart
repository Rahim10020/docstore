import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../widgets/search_bar.dart';
import '../../services/unified_resource_service.dart';
import '../../providers/data_provider.dart';
import '../../data/models/ecole.dart';
import '../../data/models/concours.dart';
import '../../data/models/ue.dart' as ue_model;
import '../widgets/unified_resource_list_item.dart';
import '../widgets/compact_concours_card.dart';
import 'filieres_screen.dart';
import 'concours_detail_screen.dart';
import 'ue_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  bool _isLoading = false;
  String? _error;

  List<Ecole> _ecoles = [];
  List<Concours> _concours = [];
  List<ue_model.Ue> _ues = [];
  List<UnifiedResource> _resources = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(value.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _ecoles = [];
        _concours = [];
        _ues = [];
        _resources = [];
        _isLoading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(appwriteServiceProvider);
      final unifiedService = UnifiedResourceService();

      // Charger toutes les entités (simple approach)
      final results = await Future.wait([
        service.getEcoles(),
        service.getConcours(),
        service.getUEs(),
      ]);

      final allEcoles = results[0] as List<Ecole>;
      final allConcours = results[1] as List<Concours>;
      final allUes = results[2] as List<ue_model.Ue>;

      final q = query.toLowerCase();

      final matchedEcoles = allEcoles.where((e) {
        final name = e.nom.toLowerCase();
        final desc = (e.description ?? '').toLowerCase();
        return name.contains(q) || desc.contains(q);
      }).toList();

      final matchedConcours = allConcours.where((c) {
        final nom = (c.nom ?? '').toLowerCase();
        final desc = (c.description ?? '').toLowerCase();
        final annee = (c.annee ?? '').toLowerCase();
        final ecole = (c.idEcole ?? '').toLowerCase();
        return nom.contains(q) || desc.contains(q) || annee.contains(q) || ecole.contains(q);
      }).toList();

      final matchedUes = allUes.where((u) {
        final nom = u.nom.toLowerCase();
        final desc = (u.description ?? '').toLowerCase();
        return nom.contains(q) || desc.contains(q);
      }).toList();

      // Collecter identifiants de ressources depuis concours + ues
      final resourceIds = <String>{};
      for (final c in matchedConcours) {
        resourceIds.addAll(c.ressources);
        resourceIds.addAll(c.communiques);
      }
      for (final u in matchedUes) {
        resourceIds.addAll(u.ressources);
      }

      // Limiter la quantité de requêtes aux ressources (safety)
      final limitedIds = resourceIds.take(40).toList();
      List<UnifiedResource> matchedResources = [];
      if (limitedIds.isNotEmpty) {
        final fetched = await unifiedService.getResources(limitedIds);
        matchedResources = fetched.where((r) => r.name.toLowerCase().contains(q)).toList();
      }

      // Mettre à jour l'état
      if (mounted) {
        setState(() {
          _ecoles = matchedEcoles;
          _concours = matchedConcours;
          _ues = matchedUes;
          _resources = matchedResources;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            '($count)',
            style: TextStyle(color: AppTheme.mutedText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: RoundedSearchBar(
            controller: _controller,
            hint: 'Rechercher écoles, concours, UEs, documents...',
            onChanged: _onSearchChanged,
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoading) const LinearProgressIndicator(),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Erreur: $_error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
        Expanded(
          child: Builder(builder: (context) {
            final isEmptyQuery = _controller.text.trim().isEmpty;
            if (isEmptyQuery) {
              return Center(
                child: Text(
                  'Commencez votre recherche',
                  style: TextStyle(color: AppTheme.mutedText),
                ),
              );
            }

            if (!_isLoading && _ecoles.isEmpty && _concours.isEmpty && _ues.isEmpty && _resources.isEmpty) {
              return Center(
                child: Text(
                  'Aucun résultat',
                  style: TextStyle(color: AppTheme.mutedText),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (_ecoles.isNotEmpty) ...[
                  _buildSectionHeader('Écoles', _ecoles.length),
                  ..._ecoles.map((e) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          title: Text(e.nom),
                          subtitle: e.description != null ? Text(e.description!) : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => FilieresScreen(ecole: e)),
                            );
                          },
                        ),
                      ))
                ],

                if (_concours.isNotEmpty) ...[
                  _buildSectionHeader('Concours', _concours.length),
                  ..._concours.map((c) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: CompactConcoursCard(
                          title: c.nom ?? 'Concours',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ConcoursDetailScreen(concours: c)),
                            );
                          },
                        ),
                      ))
                ],

                if (_ues.isNotEmpty) ...[
                  _buildSectionHeader('UEs', _ues.length),
                  ..._ues.map((u) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          title: Text(u.nom),
                          subtitle: u.description != null ? Text(u.description!) : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => UeDetailScreen(ue: u)),
                            );
                          },
                        ),
                      ))
                ],

                if (_resources.isNotEmpty) ...[
                  _buildSectionHeader('Documents', _resources.length),
                  ..._resources.map((r) => UnifiedResourceListItem(resource: r)),
                ],
              ],
            );
          }),
        ),
      ],
    );
  }
}
