import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/app_constants.dart';
import '../../config/app_theme.dart';
import '../../data/models/index.dart';
import '../../presentation/bloc/index.dart';
import '../../presentation/widgets/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _ecoleSearchQuery = '';
  String _concoursSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Load initial data
    context.read<EcoleBloc>().add(const FetchEcoles());
    context.read<ConcoursBloc>().add(const FetchConcours());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      // Tab changed - rebuild the UI
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DocStore EPL'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryIndigo,
          labelColor: AppColors.primaryIndigo,
          unselectedLabelColor: AppColors.textLight,
          tabs: const [
            Tab(icon: Icon(Icons.school), text: 'Écoles'),
            Tab(icon: Icon(Icons.workspace_premium), text: 'Concours'),
            Tab(icon: Icon(Icons.search), text: 'Recherche'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildEcolesTab(), _buildConcoursTab(), _buildSearchTab()],
      ),
    );
  }

  Widget _buildEcolesTab() {
    return BlocBuilder<EcoleBloc, EcoleState>(
      builder: (context, state) {
        if (state is EcoleLoading) {
          return const CustomLoader(message: 'Chargement des écoles...');
        } else if (state is EcoleLoaded) {
          return _buildEcolesList(context, state.ecoles);
        } else if (state is EcoleEmpty) {
          return const EmptyStateWidget(
            message: 'Aucune école disponible',
            icon: Icons.school,
          );
        } else if (state is EcoleError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<EcoleBloc>().add(const FetchEcoles());
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEcolesList(BuildContext context, List<Ecole> ecoles) {
    // Filtrer les écoles selon la recherche
    final filteredEcoles = _ecoleSearchQuery.isEmpty
        ? ecoles
        : ecoles.where((ecole) {
            final query = _ecoleSearchQuery.toLowerCase();
            return ecole.nom.toLowerCase().contains(query) ||
                ecole.description.toLowerCase().contains(query) ||
                ecole.lieu.toLowerCase().contains(query);
          }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppConstants.paddingDefault),
          child: CustomSearchBar(
            onChanged: (query) {
              setState(() {
                _ecoleSearchQuery = query;
              });
            },
            hintText: 'Rechercher une école...',
          ),
        ),
        Expanded(
          child: filteredEcoles.isEmpty
              ? const EmptyStateWidget(
                  message: 'Aucune école trouvée',
                  icon: Icons.search_off,
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<EcoleBloc>().add(const FetchEcoles());
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingDefault),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(context),
                      mainAxisSpacing: AppConstants.paddingDefault,
                      crossAxisSpacing: AppConstants.paddingDefault,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: filteredEcoles.length,
                    itemBuilder: (context, index) {
                      final ecole = filteredEcoles[index];
                      return EcoleCard(
                        ecole: ecole,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/ecole-detail',
                            arguments: ecole,
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildConcoursTab() {
    return BlocBuilder<ConcoursBloc, ConcoursState>(
      builder: (context, state) {
        if (state is ConcoursLoading) {
          return const CustomLoader(message: 'Chargement des concours...');
        } else if (state is ConcoursLoaded) {
          return _buildConcoursList(context, state.concours);
        } else if (state is ConcoursEmpty) {
          return const EmptyStateWidget(
            message: 'Aucun concours disponible',
            icon: Icons.workspace_premium,
          );
        } else if (state is ConcoursError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<ConcoursBloc>().add(const FetchConcours());
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildConcoursList(BuildContext context, List<Concours> concours) {
    // Filtrer les concours selon la recherche
    final filteredConcours = _concoursSearchQuery.isEmpty
        ? concours
        : concours.where((c) {
            final query = _concoursSearchQuery.toLowerCase();
            return c.nom.toLowerCase().contains(query) ||
                c.description.toLowerCase().contains(query) ||
                c.annee.toString().contains(query);
          }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppConstants.paddingDefault),
          child: CustomSearchBar(
            onChanged: (query) {
              setState(() {
                _concoursSearchQuery = query;
              });
            },
            hintText: 'Rechercher un concours...',
          ),
        ),
        Expanded(
          child: filteredConcours.isEmpty
              ? const EmptyStateWidget(
                  message: 'Aucun concours trouvé',
                  icon: Icons.search_off,
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<ConcoursBloc>().add(const FetchConcours());
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingDefault),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(context),
                      mainAxisSpacing: AppConstants.paddingDefault,
                      crossAxisSpacing: AppConstants.paddingDefault,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: filteredConcours.length,
                    itemBuilder: (context, index) {
                      final c = filteredConcours[index];
                      return ConcoursCard(
                        concours: c,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/concours-detail',
                            arguments: c,
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingDefault),
      child: Column(
        children: [
          CustomSearchBar(
            onChanged: (query) {
              if (query.isNotEmpty) {
                context.read<SearchBloc>().add(PerformSearch(query));
              }
            },
            hintText: 'Écoles, filières, cours, concours...',
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is SearchInitial) {
                if (state.history.isNotEmpty) {
                  return _buildSearchHistory(context, state.history);
                }
                return const EmptyStateWidget(
                  message: 'Commencez à rechercher',
                  subMessage:
                      'Tapez au moins 2 caractères pour trouver des écoles, filières, cours ou concours',
                );
              } else if (state is SearchLoading) {
                return const CustomLoader(message: 'Recherche...');
              } else if (state is SearchResults) {
                if (state.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'Aucun résultat trouvé',
                  );
                }
                return _buildSearchResults(context, state);
              } else if (state is SearchError) {
                return CustomErrorWidget(message: state.message);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(BuildContext context, List<String> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Historique de recherche',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () {
                context.read<SearchBloc>().add(const ClearHistory());
              },
              child: const Text('Effacer'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: history
              .map(
                (query) => InputChip(
                  label: Text(query),
                  onPressed: () {
                    context.read<SearchBloc>().add(PerformSearch(query));
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context, SearchResults state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.ecoles.isNotEmpty) ...[
          _buildSearchCategory(context, 'Écoles', state.ecoles.length),
          const SizedBox(height: AppConstants.paddingSmall),
          ..._buildEcoleChips(context, state.ecoles),
          const SizedBox(height: AppConstants.paddingLarge),
        ],
        if (state.filieres.isNotEmpty) ...[
          _buildSearchCategory(context, 'Filières', state.filieres.length),
          const SizedBox(height: AppConstants.paddingSmall),
          ..._buildFiliereChips(context, state.filieres),
          const SizedBox(height: AppConstants.paddingLarge),
        ],
        if (state.cours.isNotEmpty) ...[
          _buildSearchCategory(context, 'Cours', state.cours.length),
          const SizedBox(height: AppConstants.paddingSmall),
          ..._buildCoursChips(context, state.cours),
          const SizedBox(height: AppConstants.paddingLarge),
        ],
        if (state.concours.isNotEmpty) ...[
          _buildSearchCategory(context, 'Concours', state.concours.length),
          const SizedBox(height: AppConstants.paddingSmall),
          ..._buildConcoursChips(context, state.concours),
        ],
      ],
    );
  }

  Widget _buildSearchCategory(BuildContext context, String title, int count) {
    return Text(
      '$title ($count)',
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(color: AppColors.primaryIndigo),
    );
  }

  List<Widget> _buildEcoleChips(BuildContext context, List<Ecole> ecoles) {
    return ecoles
        .map(
          (ecole) => ActionChip(
            label: Text(ecole.nom),
            onPressed: () {
              Navigator.pushNamed(context, '/ecole-detail', arguments: ecole);
            },
          ),
        )
        .toList();
  }

  List<Widget> _buildFiliereChips(
    BuildContext context,
    List<Filiere> filieres,
  ) {
    return filieres
        .map(
          (filiere) => ActionChip(
            label: Text(filiere.nom),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/filiere-detail',
                arguments: filiere,
              );
            },
          ),
        )
        .toList();
  }

  List<Widget> _buildCoursChips(BuildContext context, List<Cours> cours) {
    return cours
        .map(
          (c) => ActionChip(
            label: Text(c.titre),
            onPressed: () {
              Navigator.pushNamed(context, '/cours-detail', arguments: c);
            },
          ),
        )
        .toList();
  }

  List<Widget> _buildConcoursChips(
    BuildContext context,
    List<Concours> concours,
  ) {
    return concours
        .map(
          (c) => ActionChip(
            label: Text(c.nom),
            onPressed: () {
              Navigator.pushNamed(context, '/concours-detail', arguments: c);
            },
          ),
        )
        .toList();
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 900) {
      return 3;
    } else if (width > 600) {
      return 2;
    }
    return 1;
  }
}
