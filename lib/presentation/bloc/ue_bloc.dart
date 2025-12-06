import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/index.dart';
import 'ue_event.dart';
import 'ue_state.dart';

class UEBloc extends Bloc<UEEvent, UEState> {
  final UERepository ueRepository;

  UEBloc(this.ueRepository) : super(UEInitial()) {
    on<FetchUEsByFiliere>(_onFetchUEsByFiliere);
    on<SearchUEs>(_onSearchUEs);
  }

  Future<void> _onFetchUEsByFiliere(
    FetchUEsByFiliere event,
    Emitter<UEState> emit,
  ) async {
    emit(UELoading());
    try {
      final ues = await ueRepository.getUEsByFiliereWithResources(
        event.filiereId,
      );
      if (ues.isEmpty) {
        emit(UEEmpty());
      } else {
        emit(UELoaded(ues));
      }
    } catch (e) {
      emit(UEError('Erreur lors du chargement des UEs: $e'));
    }
  }

  Future<void> _onSearchUEs(
    SearchUEs event,
    Emitter<UEState> emit,
  ) async {
    emit(UELoading());
    try {
      final ues = await ueRepository.searchUEsWithResources(
        event.filiereId,
        event.query,
      );
      if (ues.isEmpty) {
        emit(UEEmpty());
      } else {
        emit(UELoaded(ues));
      }
    } catch (e) {
      emit(UEError('Erreur lors de la recherche: $e'));
    }
  }
}

