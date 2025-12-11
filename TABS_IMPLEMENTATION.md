# Guide pour implémenter les 3 tabs (Écoles, Concours, Recherche)

## Structure proposée

Pour implémenter les 3 tabs dans la HomePage, voici l'architecture recommandée:

### 1. Modifier HomeScreen

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import 'ecoles_tab.dart';
import 'concours_tab.dart';
import 'search_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DocStore EPL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryBlue,
          indicatorWeight: 3,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.school), text: 'Écoles'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Concours'),
            Tab(icon: Icon(Icons.search), text: 'Recherche'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          EcolesTab(),
          ConcoursTab(),
          SearchTab(),
        ],
      ),
    );
  }
}
```

### 2. Créer EcolesTab (copier le code actuel de HomeScreen)

**Fichier: `lib/ui/screens/tabs/ecoles_tab.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/data_provider.dart';
import '../../../core/theme.dart';
import '../filieres_screen.dart';

class EcolesTab extends ConsumerWidget {
  const EcolesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ecolesAsync = ref.watch(ecolesProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: ecolesAsync.when(
        data: (ecoles) {
          if (ecoles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('Aucune école disponible',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ecoles.length,
            itemBuilder: (context, index) {
              final ecole = ecoles[index];
              return _buildEcoleCard(context, ecole);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erreur: $error')),
      ),
    );
  }

  Widget _buildEcoleCard(BuildContext context, Ecole ecole) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FilieresScreen(ecole: ecole)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: AppTheme.schoolGradient,
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.school, size: 40, color: AppTheme.primaryBlue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ecole.nom,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (ecole.description != null) ...[
                      const SizedBox(height: 6),
                      Text(ecole.description!,
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 3. Créer ConcoursTab

**Fichier: `lib/ui/screens/tabs/concours_tab.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/data_provider.dart';
import '../../../core/theme.dart';
import '../concours_detail_screen.dart';

class ConcoursTab extends ConsumerWidget {
  const ConcoursTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final concoursAsync = ref.watch(concoursProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: concoursAsync.when(
        data: (concours) {
          if (concours.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('Aucun concours disponible',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: concours.length,
            itemBuilder: (context, index) {
              final concoursItem = concours[index];
              return _buildConcoursCard(context, concoursItem);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erreur: $error')),
      ),
    );
  }

  Widget _buildConcoursCard(BuildContext context, Concours concours) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConcoursDetailScreen(concours: concours),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
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
                    child: const Icon(Icons.emoji_events, size: 36, color: AppTheme.primaryOrange),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(concours.nom ?? 'Concours',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (concours.annee != null) ...[
                          const SizedBox(height: 4),
                          Text('Année: ${concours.annee}',
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (concours.description != null) ...[
                const SizedBox(height: 16),
                Text(concours.description!,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

### 4. Créer SearchTab

**Fichier: `lib/ui/screens/tabs/search_tab.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../providers/data_provider.dart';

class SearchTab extends ConsumerStatefulWidget {
  const SearchTab({super.key});

  @override
  ConsumerState<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher écoles, filières, UEs, ressources...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
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
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase().trim();
                });
              },
            ),
          ),

          // Résultats
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildEmptyState()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Recherchez des écoles, filières,\nUEs ou ressources',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    // Implémentation de la recherche globale
    return const Center(child: Text('Résultats de recherche ici'));
  }
}
```

## Étapes d'implémentation

1. **Créer le dossier tabs**:
   ```bash
   mkdir -p lib/ui/screens/tabs
   ```

2. **Créer les 3 fichiers tabs** avec le code ci-dessus

3. **Modifier home_screen.dart** pour utiliser le TabController

4. **Importer les modèles nécessaires** dans chaque tab

5. **Tester l'application**:
   ```bash
   flutter run -d linux
   ```

## Avantages de cette architecture

- ✅ Code modulaire et maintenable
- ✅ Chaque tab est indépendant
- ✅ Facile à tester individuellement
- ✅ Navigation fluide entre les tabs
- ✅ État préservé lors du changement de tab

## Note importante

Cette implémentation nécessite de créer les fichiers un par un proprement, sans conflits de noms ou d'imports.

