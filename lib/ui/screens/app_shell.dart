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

class DocStoreAppShell extends ConsumerStatefulWidget {
  const DocStoreAppShell({super.key});

  @override
  ConsumerState<DocStoreAppShell> createState() => _DocStoreAppShellState();
}

class _DocStoreAppShellState extends ConsumerState<DocStoreAppShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize notification service with ref
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().init(ref);
    });
  }

  final List<_PageConfig> _pages = const [
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
      trailing: _ConcoursFilterButton(),
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
                trailing: config.trailing,
              ),
              const SizedBox(height: 24),
              Expanded(child: config.body),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DocStoreBottomNavBar(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _PageConfig {
  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? trailing;

  const _PageConfig({
    required this.title,
    this.subtitle,
    required this.body,
    this.trailing,
  });
}

class _ConcoursFilterButton extends StatelessWidget {
  const _ConcoursFilterButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.mutedText.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Tous',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 18),
        ],
      ),
    );
  }
}
