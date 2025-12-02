# Guide du Développeur - DocStore EPL Mobile

## 🚀 Démarrage Rapide

### Installation
```bash
# 1. Cloner le repo
git clone <repo-url>
cd docstore

# 2. Installer les dépendances Flutter
flutter pub get

# 3. Générer les fichiers nécessaires
flutter pub run build_runner build

# 4. Lancer l'app
flutter run
```

### Configuration Appwrite
1. Voir [APPWRITE_SETUP.md](./APPWRITE_SETUP.md)
2. Mettre à jour `lib/config/app_constants.dart`

## 📁 Structure du Projet

```
lib/
├── config/
│   ├── app_theme.dart          # ThemeData Material
│   ├── app_routes.dart         # Routes nommées
│   └── app_constants.dart      # Constantes globales
│
├── data/
│   ├── models/
│   │   ├── ecole.dart
│   │   ├── filiere.dart
│   │   ├── parcours.dart
│   │   ├── cours.dart
│   │   ├── ressource.dart
│   │   ├── concours.dart
│   │   ├── semestre.dart
│   │   ├── annee.dart
│   │   └── index.dart          # Exports
│   │
│   ├── repositories/
│   │   ├── ecole_repository.dart
│   │   ├── filiere_repository.dart
│   │   ├── parcours_repository.dart
│   │   ├── cours_repository.dart
│   │   ├── concours_repository.dart
│   │   └── index.dart
│   │
│   └── services/
│       ├── appwrite_service.dart
│       ├── download_service.dart
│       ├── connectivity_service.dart
│       └── index.dart
│
├── presentation/
│   ├── bloc/
│   │   ├── ecole_bloc.dart
│   │   ├── ecole_event.dart
│   │   ├── ecole_state.dart
│   │   ├── concours_bloc.dart
│   │   ├── concours_event.dart
│   │   ├── concours_state.dart
│   │   ├── search_bloc.dart
│   │   ├── search_event.dart
│   │   ├── search_state.dart
│   │   └── index.dart
│   │
│   ├── pages/
│   │   ├── home_page.dart
│   │   ├── ecole_detail_page.dart
│   │   ├── concours_detail_page.dart
│   │   ├── cours_detail_page.dart
│   │   ├── pdf_viewer_page.dart
│   │   └── index.dart
│   │
│   └── widgets/
│       ├── custom_loader.dart
│       ├── custom_error_widget.dart
│       ├── empty_state_widget.dart
│       ├── ecole_card.dart
│       ├── cours_card.dart
│       ├── concours_card.dart
│       ├── ressource_card.dart
│       ├── custom_search_bar.dart
│       └── index.dart
│
├── utils/
│   └── (À ajouter: helpers, extensions, etc.)
│
└── main.dart
```

## 🎯 Ajouter une Nouvelle Fonctionnalité

### Exemple: Ajouter une page de Filière

#### 1. Créer le modèle (si nécessaire)
```dart
// lib/data/models/filiere.dart (déjà existe)
```

#### 2. Créer le repository (si nécessaire)
```dart
// lib/data/repositories/filiere_repository.dart (déjà existe)
```

#### 3. Créer le BLoC
```dart
// lib/presentation/bloc/filiere_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class FiliereBloc extends Bloc<FiliereEvent, FiliereState> {
  final FiliereRepository _repository;

  FiliereBloc(this._repository) : super(const FiliereInitial()) {
    on<FetchFilieres>(_onFetchFilieres);
  }

  Future<void> _onFetchFilieres(...) async {
    // Implémentation
  }
}
```

#### 4. Créer la page
```dart
// lib/presentation/pages/filiere_page.dart
class FilierePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FiliereBloc, FiliereState>(
      builder: (context, state) {
        // Implémentation
      },
    );
  }
}
```

#### 5. Enregistrer la page
```dart
// lib/main.dart
routes: {
  '/filieres': (context) => const FilierePage(),
}
```

## 🔍 Patterns Communs

### BlocBuilder avec Refresh
```dart
BlocBuilder<EcoleBloc, EcoleState>(
  builder: (context, state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<EcoleBloc>().add(const FetchEcoles());
      },
      child: ListView(...),
    );
  },
);
```

### Infinite Scroll
```dart
ListView.builder(
  itemBuilder: (context, index) {
    if (index == ecoles.length - 1) {
      // Charger plus
      context.read<EcoleBloc>().add(const FetchEcoles(page: page + 1));
    }
    return EcoleCard(ecole: ecoles[index]);
  },
)
```

### Navigation avec Arguments
```dart
// Aller
Navigator.pushNamed(
  context,
  '/ecole-detail',
  arguments: ecole,
);

// Recevoir
final ecole = ModalRoute.of(context)!.settings.arguments as Ecole;
```

### Debounced Search
```dart
// Dans le BLoC
on<PerformSearch>(_onPerformSearch);

Future<void> _onPerformSearch(...) async {
  if (query.length < AppConstants.minSearchLength) return;
  
  emit(SearchLoading());
  try {
    final results = await _repository.search(query);
    emit(SearchResults(results));
  } catch (e) {
    emit(SearchError(e.toString()));
  }
}
```

## 🧪 Testing

### Test d'un BLoC
```dart
void main() {
  late EcoleBloc ecoleBloc;
  late MockEcoleRepository mockRepository;

  setUp(() {
    mockRepository = MockEcoleRepository();
    ecoleBloc = EcoleBloc(mockRepository);
  });

  test('FetchEcoles emits [Loading, Loaded]', () async {
    when(mockRepository.getEcoles()).thenAnswer(
      (_) async => [Ecole(...)]
    );

    expect(
      ecoleBloc.stream,
      emitsInOrder([
        EcoleLoading(),
        EcoleLoaded(ecoles: [...]),
      ]),
    );

    ecoleBloc.add(const FetchEcoles());
  });
}
```

### Test d'un Widget
```dart
void main() {
  testWidgets('EcoleCard displays school name', (tester) async {
    final ecole = Ecole(...);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EcoleCard(
            ecole: ecole,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text(ecole.nom), findsOneWidget);
  });
}
```

## 🎨 Customization UI

### Ajouter une nouvelle couleur
```dart
// lib/config/app_theme.dart
class AppColors {
  static const Color customColor = Color(0xFFXXXXXX);
}
```

### Ajouter un nouveau style de texte
```dart
// lib/config/app_theme.dart
headlineExtra: GoogleFonts.poppins(
  fontSize: 32,
  fontWeight: FontWeight.w800,
  color: AppColors.textDark,
),
```

### Ajouter une animation
```dart
// Utiliser AppConstants.animationDuration
AnimatedContainer(
  duration: AppConstants.animationDuration,
  curve: Curves.easeInOutCubic,
  // ...
)
```

## 🔧 Debugging

### Logs
```dart
import 'package:logger/logger.dart';

final logger = Logger();

logger.i('Info message');
logger.d('Debug message');
logger.w('Warning message');
logger.e('Error message');
```

### DevTools
```bash
flutter pub global activate devtools
devtools

# Ou directement depuis Flutter
flutter pub global run devtools
```

### BLoC Observer
```dart
// main.dart
void main() {
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}

class MyBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    logger.d('${bloc.runtimeType} $change');
  }
}
```

## 📦 Déploiement

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Build IPA
flutter build ios --release

# Ou via Xcode
open ios/Runner.xcworkspace
# Build → Generic iOS Device → Product → Archive
```

## 🐛 Troubleshooting

### Erreur: "Could not resolve library"
```bash
flutter pub get
flutter pub upgrade
flutter clean
```

### Erreur: "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

### Erreur: "Pod install failed" (iOS)
```bash
cd ios
pod install --repo-update
cd ..
flutter run
```

## 📚 Ressources

- [Flutter Docs](https://flutter.dev/docs)
- [Bloc Library](https://bloclibrary.dev/)
- [Appwrite Docs](https://appwrite.io/docs)
- [Material Design 3](https://m3.material.io/)

## 💡 Tips & Tricks

1. **Hot Reload**: Cmd+S (Mac) ou Ctrl+S (Windows/Linux)
2. **Hot Restart**: Cmd+Shift+R (Mac) ou Ctrl+Shift+R
3. **Frame Stats**: Toggle "Show fps" en tapant "L" dans le terminal
4. **Rebuild Subtree**: Ajouter des keys uniques aux widgets
5. **Responsive Design**: Utiliser `MediaQuery.of(context).size`

## 🤝 Contribution

1. Créer une branche: `git checkout -b feature/nouvelle-feature`
2. Commit avec message clair: `git commit -m "feat: description"`
3. Push: `git push origin feature/nouvelle-feature`
4. Créer une Pull Request

## 📝 Conventions de Code

- **Naming**: camelCase pour variables/fonctions, PascalCase pour classes
- **Imports**: Organiser par groupes (dart, flutter, packages, local)
- **Format**: Utiliser `flutter format .`
- **Lint**: Respecter les règles de `analysis_options.yaml`
- **Comments**: Expliquer le "pourquoi", pas le "quoi"

## 🚨 Checklist avant Déploiement

- [ ] Tous les bugs connus sont fixes
- [ ] Code review complétée
- [ ] Tests unitaires passent
- [ ] Tests d'intégration passent
- [ ] Pas de logs de debug
- [ ] Icônes et assets mises à jour
- [ ] Version bumped
- [ ] Release notes préparées
- [ ] Permissions Android/iOS vérifiées
- [ ] Privacy policy mise à jour

Bon développement! 🎉
