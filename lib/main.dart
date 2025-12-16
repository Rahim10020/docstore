import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/appwrite_config.dart';
import 'services/appwrite_service.dart';
import 'core/theme.dart';
import 'ui/screens/app_shell.dart';
import 'ui/screens/launch_screen.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Appwrite
  AppwriteConfig().init();
  AppwriteService().init();

  // Précharger les métadonnées des fichiers
  await AppwriteService().preloadFileMetadata();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'DocStore',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const DocStoreAppShell(),
    );
  }
}
