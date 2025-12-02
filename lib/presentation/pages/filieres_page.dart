import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/app_constants.dart';
import '../../data/models/index.dart';
import '../../data/repositories/index.dart';
import '../bloc/filiere_bloc.dart';
import '../bloc/filiere_event.dart';
import '../bloc/filiere_state.dart';
import '../widgets/custom_error_widget.dart';
import '../widgets/custom_loader.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/filiere_card.dart';

class FiliersPage extends StatelessWidget {
  final String ecoleId;
  final String ecoleName;

  const FiliersPage({
    required this.ecoleId,
    required this.ecoleName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FiliereBloc(context.read<FiliereRepository>())
            ..add(FetchFilieresByEcole(ecoleId)),
      child: Scaffold(
        appBar: AppBar(title: Text(ecoleName), elevation: 0),
        body: BlocBuilder<FiliereBloc, FiliereState>(
          builder: (context, state) {
            if (state is FiliereLoading) {
              return const CustomLoader(message: 'Chargement des filières...');
            } else if (state is FiliereLoaded) {
              return _buildFilieresList(context, state.filieres);
            } else if (state is FiliereEmpty) {
              return const EmptyStateWidget(
                message: 'Aucune filière disponible',
                icon: Icons.folder_open,
              );
            } else if (state is FiliereError) {
              return CustomErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<FiliereBloc>().add(
                    FetchFilieresByEcole(ecoleId),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildFilieresList(BuildContext context, List<Filiere> filieres) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FiliereBloc>().add(FetchFilieresByEcole(ecoleId));
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingDefault),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          mainAxisSpacing: AppConstants.paddingDefault,
          crossAxisSpacing: AppConstants.paddingDefault,
          childAspectRatio: 1.1,
        ),
        itemCount: filieres.length,
        itemBuilder: (context, index) {
          final filiere = filieres[index];
          return FiliereCard(
            filiere: filiere,
            onTap: () {
              // TODO: Navigate to filiere detail page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Filière: ${filiere.nom}')),
              );
            },
          );
        },
      ),
    );
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
