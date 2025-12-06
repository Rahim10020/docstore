import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/app_theme.dart';
import 'data/models/index.dart';
import 'data/repositories/index.dart';
import 'data/services/index.dart';
import 'presentation/bloc/index.dart';
import 'presentation/pages/index.dart';

void main() {
  // Workaround for device_info_plus compatibility issue
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final appwriteService = AppwriteService();
    final downloadService = DownloadService();
    final connectivityService = ConnectivityService();

    // Initialize repositories
    final ecoleRepository = EcoleRepository(appwriteService);
    final filiereRepository = FiliereRepository(appwriteService);
    final coursRepository = CoursRepository(appwriteService);
    final concoursRepository = ConcoursRepository(appwriteService);
    final ressourceRepository = RessourceRepository(appwriteService);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppwriteService>(create: (_) => appwriteService),
        RepositoryProvider<DownloadService>(create: (_) => downloadService),
        RepositoryProvider<ConnectivityService>(
          create: (_) => connectivityService,
        ),
        RepositoryProvider<EcoleRepository>(create: (_) => ecoleRepository),
        RepositoryProvider<FiliereRepository>(create: (_) => filiereRepository),
        RepositoryProvider<CoursRepository>(create: (_) => coursRepository),
        RepositoryProvider<ConcoursRepository>(
          create: (_) => concoursRepository,
        ),
        RepositoryProvider<RessourceRepository>(
          create: (_) => ressourceRepository,
        ),
      ],
      child: MultiBlocProvider(
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
        child: MaterialApp(
          title: 'DocStore EPL',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: const HomePage(),
          routes: {
            '/ecole-detail': (context) {
              final ecole = ModalRoute.of(context)!.settings.arguments as Ecole;
              return EcoleDetailPage(ecole: ecole);
            },
            '/filieres': (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>;
              return FiliersPage(
                ecoleId: args['ecoleId'],
                ecoleName: args['ecoleName'],
              );
            },
            '/concours-detail': (context) {
              final concours =
                  ModalRoute.of(context)!.settings.arguments as Concours;
              return ConcoursDetailPage(concours: concours);
            },
            '/cours-detail': (context) {
              final cours = ModalRoute.of(context)!.settings.arguments as Cours;
              return CoursDetailPage(cours: cours);
            },
            '/pdf-viewer': (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>;
              return PdfViewerPage(
                url: args['url'],
                title: args['title'],
                downloadUrl: args['downloadUrl'],
              );
            },
          },
        ),
      ),
    );
  }
}
