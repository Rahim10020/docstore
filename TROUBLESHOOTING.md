# Guide Résolution des Erreurs - DocStore EPL

## Erreurs Courantes et Solutions

### 1. "Target of URI doesn't exist: 'package:...'

**Cause**: Dépendances non installées

**Solution**:
```bash
flutter pub get
flutter pub upgrade
flutter pub cache repair
flutter clean
flutter pub get
```

### 2. "Undefined class 'Equatable'"

**Cause**: Package equatable non disponible

**Solution**:
```bash
# Vérifier que equatable est dans pubspec.yaml
# dependencies:
#   equatable: ^2.0.5

flutter pub get
```

### 3. "The argument type 'CardTheme' can't be assigned to the parameter type 'CardThemeData?'"

**Cause**: API change de Flutter

**Solution**: 
```dart
// ❌ Avant
cardTheme: CardTheme(...)

// ✅ Après
cardTheme: CardThemeData(
  color: AppColors.white,
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
)
```

### 4. "Appwrite connection failed"

**Cause**: Endpoint ou configuration incorrecte

**Solution**:
```dart
// lib/config/app_constants.dart
// Vérifier:
// 1. appwriteEndpoint est valide
// 2. appwriteProjectId existe
// 3. appwriteApiKey a les bons scopes
// 4. Appwrite est en cours d'exécution
// 5. Firewall/proxy autorise la connexion
```

### 5. "Permission denied: WRITE_EXTERNAL_STORAGE"

**Cause**: Permissions Android manquantes

**Solution**:
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

Et demander à l'exécution:
```dart
// lib/data/services/download_service.dart
final status = await Permission.storage.request();
if (!status.isGranted) return null;
```

### 6. "MissingPluginException"

**Cause**: Plugins pas compilés

**Solution**:
```bash
flutter pub get
flutter pub upgrade
flutter clean
cd ios && pod install --repo-update && cd ..
flutter run
```

### 7. "Gradle failed with error code 1"

**Cause**: Version Android ou Gradle incompatible

**Solution**:
```bash
# Nettoyer
cd android
./gradlew clean
cd ..

# Ou réinitialiser
flutter clean
flutter pub get
flutter run
```

### 8. "PodFile ERROR" (iOS)

**Cause**: CocoaPods cache corrompu

**Solution**:
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install --repo-update
cd ..
flutter run
```

### 9. "MissingMethodException: The getter 'isEmpty' was called on null"

**Cause**: Null safety - valeur null non gérée

**Solution**:
```dart
// ❌ Avant
final items = state.ecoles;
if (items.isEmpty) // Erreur si items est null

// ✅ Après
final items = state.ecoles ?? [];
if (items.isEmpty)

// Ou avec null-coalescing
final items = state.ecoles ?? const [];
```

### 10. "Duplicate class found" (Android)

**Cause**: Dépendances conflictuelles

**Solution**:
```bash
# Exclure les conflits
# android/app/build.gradle

dependencies {
  implementation(...) {
    exclude group: 'com.android.support'
  }
}
```

## Erreurs BLoC

### "No BlocProvider found"

**Cause**: BLoC non enregistré dans MultiBlocProvider

**Solution**:
```dart
// main.dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => EcoleBloc(ecoleRepository)),
    // Ajouter le nouveau BLoC ici
  ],
  child: MyApp(),
)
```

### "State not updating"

**Cause**: State est mutable

**Solution**:
```dart
// ❌ Avant
class EcoleLoaded {
  List<Ecole> ecoles = []; // Mutable!
}

// ✅ Après
class EcoleLoaded extends EcoleState {
  final List<Ecole> ecoles;
  const EcoleLoaded({required this.ecoles});
}
```

## Erreurs PDF

### "PDF not rendering"

**Cause**: URL invalide ou non accessible

**Solution**:
```dart
// Vérifier l'URL
print('PDF URL: $url'); // Vérifier dans les logs

// Tester manuelle ment
// Ouvrir l'URL dans le navigateur

// Vérifier les permissions
// Vérifier le certificat SSL
```

## Erreurs Réseau

### "No internet"

**Cause**: Connectivité perdue

**Solution**:
```dart
final isOnline = await ConnectivityService().isConnected();
if (!isOnline) {
  // Afficher offline mode
}
```

### "Timeout"

**Cause**: Serveur lent ou offline

**Solution**:
```dart
// Augmenter timeout dans Dio
final dio = Dio();
dio.options.connectTimeout = const Duration(seconds: 30);
dio.options.receiveTimeout = const Duration(seconds: 30);
```

## Debugging

### Activer les logs verbose
```bash
flutter run -v
# Voir tous les logs détaillés
```

### Utiliser DevTools
```bash
flutter pub global activate devtools
devtools
# Ouvrir http://localhost:9100
```

### Logger custom
```dart
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
  ),
);

logger.d('Debug message');
logger.e('Error: $error');
```

### Breakpoints
- Clic sur le numéro de ligne dans VS Code
- Exécuter `flutter run`
- Débugger s'arrête au breakpoint

## Performance

### Optimiser UI
```dart
// Utiliser const
const Text('Texte') // vs Text('Texte')

// Utiliser Keys
ListView(
  key: PageStorageKey('ecoles'),
)

// Lazy loading
ListView.builder(...) // vs ListView(...)

// Image caching
Image.network(
  url,
  cacheWidth: 400,
  cacheHeight: 400,
)
```

### Profiler l'app
```bash
flutter run --profile
# Ou dans DevTools: Performance tab
```

## Ressources

- [Flutter Troubleshooting](https://flutter.dev/docs/testing/troubleshooting)
- [Dart Null Safety](https://dart.dev/null-safety)
- [BLoC Troubleshooting](https://bloclibrary.dev/troubleshooting/)
- [Appwrite Issues](https://github.com/appwrite/appwrite/issues)

## Quand tout échoue

1. **Clean**: `flutter clean && flutter pub get`
2. **Cache**: `flutter pub cache clean && flutter pub get`
3. **Réinstall**: Supprimer `.dart_tool` et `pubspec.lock`
4. **Reset**: `flutter channel stable && flutter upgrade`
5. **Stackoverflow**: Chercher le message d'erreur exact
6. **Issues Github**: Vérifier les repos des packages
7. **Forum Flutter**: Poser une question avec tous les logs

## Support

En cas d'erreur non listée:
1. Lire le full stack trace
2. Chercher le message exact
3. Vérifier les versions des packages
4. Consulter la documentation
5. Ouvrir une issue sur Github

Bonne chance! 🍀
