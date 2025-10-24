import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/config/theme.dart';
import 'core/utils/logger.dart';

void main() async {
  // Initialise les bindings Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Configure l'orientation (portrait uniquement)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  AppLogger.info('🚀 Démarrage de DocStore...');

  runApp(const DocStoreApp());
}

class DocStoreApp extends StatelessWidget {
  const DocStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // Configuration de base
      title: 'DocStore',
      debugShowCheckedModeBanner: false,

      // Thème
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Binding initial (services globaux)
      initialBinding: InitialBinding(),

      // Routes
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,

      // Configuration par défaut de GetX
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),

      // Gestion des erreurs
      builder: (context, child) {
        // Force le text scale factor à 1.0
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },

      // Locale
      locale: const Locale('fr', 'FR'),
      fallbackLocale: const Locale('fr', 'FR'),

      // Callback de fermeture
      onDispose: () {
        AppLogger.info('🛑 Fermeture de DocStore');
      },
    );
  }
}
