import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/appwrite_config.dart';
import 'services/appwrite_service.dart';
import 'core/theme.dart';
import 'ui/screens/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Appwrite
  AppwriteConfig().init();
  AppwriteService().init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocStore EPL',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const DocStoreAppShell(),
    );
  }
}
