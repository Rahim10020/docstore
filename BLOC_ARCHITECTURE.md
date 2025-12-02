# Architecture BLoC - DocStore EPL

## Vue d'ensemble

L'application utilise le pattern **BLoC** (Business Logic Component) pour séparer la logique métier de la présentation.

```
     UI Layer (Widgets)
            ↓
     BLoC Layer (State Management)
            ↓
     Data Layer (Repositories)
            ↓
     Service Layer (Appwrite, Download, etc.)
```

## BLoCs Implémentés

### 1. EcoleBloc

**Responsabilités:**
- Gestion du chargement des écoles
- Paginatio et recherche
- État des écoles

**Events:**
```dart
FetchEcoles({int page = 0})        // Chargement paginé
FetchEcoleById(String id)           // Détails d'une école
SearchEcoles(String query)          // Recherche
```

**States:**
```dart
EcoleInitial                        // État initial
EcoleLoading                        // En cours de chargement
EcoleLoaded(ecoles, hasReachedEnd)  // Données chargées
EcoleDetailLoaded(ecole)            // Détail d'une école
EcoleError(message)                 // Erreur
EcoleEmpty                          // Aucune donnée
```

**Usage:**
```dart
// Déclencher le chargement
context.read<EcoleBloc>().add(const FetchEcoles());

// Écouter les changements
BlocBuilder<EcoleBloc, EcoleState>(
  builder: (context, state) {
    if (state is EcoleLoaded) {
      return ListView(...);
    }
    // ...
  },
);
```

### 2. ConcoursBloc

**Responsabilités:**
- Gestion du chargement des concours
- Pagination et recherche
- Filtrage par année/école

**Events:**
```dart
FetchConcours({int page = 0})      // Chargement paginé
FetchConcoursById(String id)        // Détails d'un concours
FilterConcoursById(String ecoleId)  // Filtrer par école
FilterConcoursById(int year)        // Filtrer par année
SearchConcours(String query)        // Recherche
```

**States:**
```dart
ConcoursInitial
ConcoursLoading
ConcoursLoaded(concours, hasReachedEnd)
ConcoursDetailLoaded(concours)
ConcoursError(message)
ConcoursEmpty
```

### 3. SearchBloc

**Responsabilités:**
- Recherche multi-entités (écoles, filières, cours, concours)
- Gestion de l'historique de recherche
- Debouncing intégré via les repositories

**Events:**
```dart
PerformSearch(String query)   // Exécuter une recherche
ClearSearch()                  // Effacer les résultats
AddToHistory(String query)     // Ajouter à l'historique
ClearHistory()                 // Effacer l'historique
```

**States:**
```dart
SearchInitial(history)                          // État initial
SearchLoading                                   // Recherche en cours
SearchResults(ecoles, filieres, cours, concours, history)
SearchError(message)
```

## Flux de Données

### Exemple: Chargement des écoles

```
1. UI (HomePage)
   └─ context.read<EcoleBloc>().add(FetchEcoles())
   
2. EcoleBloc
   └─ on<FetchEcoles>(_onFetchEcoles)
      └─ emit(EcoleLoading())
      └─ _repository.getEcoles()
      └─ emit(EcoleLoaded(ecoles))
   
3. Data Layer (EcoleRepository)
   └─ databases.listDocuments(...)
   └─ map to List<Ecole>
   
4. Service Layer (AppwriteService)
   └─ Appwrite API Call
   └─ Parse Response
   
5. UI Update
   └─ BlocBuilder rebuilds with new state
   └─ Display GridView of EcoleCard
```

## Pagination

Implémentée dans les BLoCs avec une variable `_currentPage`:

```dart
class EcoleBloc extends Bloc<EcoleEvent, EcoleState> {
  int _currentPage = 0;

  Future<void> _onFetchEcoles(
    FetchEcoles event,
    Emitter<EcoleState> emit,
  ) async {
    if (event.page == 0) {
      _currentPage = 0;  // Reset
      emit(const EcoleLoading());
    }

    final offset = _currentPage * AppConstants.itemsPerPage;
    final ecoles = await _repository.getEcoles(
      limit: AppConstants.itemsPerPage,
      offset: offset,
    );

    // Append to existing list
    final previousEcoles = 
        state is EcoleLoaded ? (state as EcoleLoaded).ecoles : [];
    final updatedEcoles = _currentPage == 0 
        ? ecoles 
        : [...previousEcoles, ...ecoles];

    emit(EcoleLoaded(
      ecoles: updatedEcoles,
      hasReachedEnd: ecoles.length < AppConstants.itemsPerPage,
    ));

    if (ecoles.length == AppConstants.itemsPerPage) {
      _currentPage++;
    }
  }
}
```

## Recherche avec Historique

Le SearchBloc gère un historique interne:

```dart
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final List<String> _searchHistory = [];

  void _onAddToHistory(
    AddToHistory event,
    Emitter<SearchState> emit,
  ) {
    if (!_searchHistory.contains(event.query)) {
      _searchHistory.insert(0, event.query);
      if (_searchHistory.length > AppConstants.maxSearchHistory) {
        _searchHistory.removeLast();
      }
    }
  }
}
```

## Gestion d'Erreurs

Tous les BLoCs implémentent la gestion d'erreurs:

```dart
try {
  final ecoles = await _repository.getEcoles();
  emit(EcoleLoaded(ecoles: ecoles));
} catch (e) {
  emit(EcoleError(e.toString()));
}
```

Les erreurs sont affichées via `CustomErrorWidget` avec bouton retry:

```dart
BlocBuilder<EcoleBloc, EcoleState>(
  builder: (context, state) {
    if (state is EcoleError) {
      return CustomErrorWidget(
        message: state.message,
        onRetry: () {
          context.read<EcoleBloc>().add(const FetchEcoles());
        },
      );
    }
    // ...
  },
);
```

## Multi-Repository Pattern

Le SearchBloc utilise plusieurs repositories:

```dart
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final EcoleRepository _ecoleRepository;
  final FiliereRepository _filiereRepository;
  final CoursRepository _coursRepository;
  final ConcoursRepository _concoursRepository;

  Future<void> _onPerformSearch(...) async {
    // Requêtes parallèles
    final ecoles = await _ecoleRepository.searchEcoles(query);
    final filieres = await _filiereRepository.searchFilieres(query);
    final cours = await _coursRepository.searchCours(query);
    final concours = await _concoursRepository.searchConcours(query);

    emit(SearchResults(...));
  }
}
```

## Testing BLoCs

Exemple de test:

```dart
void main() {
  group('EcoleBloc', () {
    late EcoleBloc ecoleBloc;
    late MockEcoleRepository mockRepository;

    setUp(() {
      mockRepository = MockEcoleRepository();
      ecoleBloc = EcoleBloc(mockRepository);
    });

    test('emit [EcoleLoading, EcoleLoaded] when FetchEcoles', () async {
      when(mockRepository.getEcoles()).thenAnswer((_) async => [testEcole]);

      expect(
        ecoleBloc.stream,
        emitsInOrder([
          EcoleLoading(),
          EcoleLoaded(ecoles: [testEcole]),
        ]),
      );

      ecoleBloc.add(const FetchEcoles());
    });
  });
}
```

## Bonnes Pratiques

1. **Immutabilité**: Tous les events et states sont immutables
2. **Équatable**: Pour la comparaison d'objets
3. **Logging**: Logger pour debug
4. **Erreurs**: Toujours gérer les erreurs
5. **States**: Créer des states spécifiques pour chaque cas
6. **Events**: Un event = une action utilisateur
7. **Repositories**: BLoCs ne connaissent pas Appwrite
8. **Testing**: Mocker les repositories pour les tests

## Intégration dans main.dart

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => EcoleBloc(ecoleRepository)),
    BlocProvider(create: (_) => ConcoursBloc(concoursRepository)),
    BlocProvider(
      create: (_) => SearchBloc(
        ecoleRepository,
        filiereRepository,
        coursRepository,
        concoursRepository,
      ),
    ),
  ],
  child: MaterialApp(...),
)
```

## Conclusion

L'architecture BLoC offre:
- ✅ Séparation des responsabilités
- ✅ Testabilité facile
- ✅ Réutilisabilité
- ✅ Scalabilité
- ✅ Performance (rebuild minimaux)
