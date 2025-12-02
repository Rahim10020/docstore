import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/index.dart';
import 'ressource_event.dart';
import 'ressource_state.dart';

class RessourceBloc extends Bloc<RessourceEvent, RessourceState> {
  final RessourceRepository ressourceRepository;

  RessourceBloc(this.ressourceRepository) : super(RessourceInitial()) {
    on<FetchRessourcesByFiliere>(_onFetchRessourcesByFiliere);
    on<FetchRessourcesByType>(_onFetchRessourcesByType);
    on<SearchRessources>(_onSearchRessources);
  }

  Future<void> _onFetchRessourcesByFiliere(
    FetchRessourcesByFiliere event,
    Emitter<RessourceState> emit,
  ) async {
    emit(RessourceLoading());
    try {
      final ressources = await ressourceRepository.getRessourcesByFiliere(
        event.filiereId,
      );
      if (ressources.isEmpty) {
        emit(RessourceEmpty());
      } else {
        emit(RessourceLoaded(ressources));
      }
    } catch (e) {
      emit(RessourceError('Erreur lors du chargement des ressources: $e'));
    }
  }

  Future<void> _onFetchRessourcesByType(
    FetchRessourcesByType event,
    Emitter<RessourceState> emit,
  ) async {
    emit(RessourceLoading());
    try {
      final ressources = await ressourceRepository.getRessourcesByType(
        event.filiereId,
        event.type,
      );
      if (ressources.isEmpty) {
        emit(RessourceEmpty());
      } else {
        emit(RessourceLoaded(ressources));
      }
    } catch (e) {
      emit(RessourceError('Erreur lors du chargement des ressources: $e'));
    }
  }

  Future<void> _onSearchRessources(
    SearchRessources event,
    Emitter<RessourceState> emit,
  ) async {
    emit(RessourceLoading());
    try {
      final ressources = await ressourceRepository.searchRessources(
        event.filiereId,
        event.query,
      );
      if (ressources.isEmpty) {
        emit(RessourceEmpty());
      } else {
        emit(RessourceLoaded(ressources));
      }
    } catch (e) {
      emit(RessourceError('Erreur lors de la recherche: $e'));
    }
  }
}
