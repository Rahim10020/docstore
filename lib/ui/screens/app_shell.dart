import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../services/notification_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/doc_store_header.dart';
import 'concours_screen.dart';
import 'home_screen.dart';
import 'saved_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class DocStoreAppShell extends ConsumerStatefulWidget {
  const DocStoreAppShell({super.key});

  @override
  ConsumerState<DocStoreAppShell> createState() => _DocStoreAppShellState();
}

class _DocStoreAppShellState extends ConsumerState<DocStoreAppShell> {
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    // Initialize notification service with ref
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().init(ref);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<_PageConfig> _pages = [
    _PageConfig(
      title: 'Etablissements',
      subtitle:
          'Decouvrez toutes les ecoles disponibles\net explorez leurs filieres academiques.',
      body: HomeScreen(),
    ),
    _PageConfig(
      title: "Concours d'entree",
      subtitle:
          'Decouvrez tous les concours d\'entree disponibles pour les differentes ecoles.',
      body: ConcoursScreen(),
    ),
    _PageConfig(
      title: 'Recherche',
      subtitle: 'Rechercher les Ecoles, Facultés, Concours, et UEs',
      body: SearchScreen(),
    ),
    _PageConfig(
      title: 'Sauvegardés',
      subtitle: 'Vos documents sauvegardés pour\nun accès rapide.',
      body: SavedScreen(),
    ),
    _PageConfig(
      title: 'Paramètres',
      subtitle: 'Configurez votre application.',
      body: SettingsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final config = _pages[_currentIndex];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColorLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DocStoreHeader(
                pageTitle: config.title,
                subtitle: config.subtitle,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentIndex = index),
                  children: _pages.map((p) => p.body).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DocStoreBottomNavBar(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 340),
            curve: Curves.easeOutCubic,
          );
        },
      ),
    );
  }
}

class _PageConfig {
  final String title;
  final String? subtitle;
  final Widget body;

  const _PageConfig({
    required this.title,
    this.subtitle,
    required this.body,
  });
}
