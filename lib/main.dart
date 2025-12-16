import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/appwrite_config.dart';
import 'services/appwrite_service.dart';
import 'core/theme.dart';
import 'ui/screens/app_shell.dart';
import 'ui/screens/launch_screen.dart';

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
    return MaterialApp(
      title: 'DocStore',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const DocStoreAppShell(),
    );
  }
}
