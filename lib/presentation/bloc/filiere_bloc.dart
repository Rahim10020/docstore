import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/index.dart';
import 'filiere_event.dart';
import 'filiere_state.dart';

class FiliereBloc extends Bloc<FiliereEvent, FiliereState> {
  final FiliereRepository filiereRepository;

  FiliereBloc(this.filiereRepository) : super(const FiliereInitial()) {
    on<FetchFilieresByEcole>(_onFetchFilieresByEcole);
  }

  Future<void> _onFetchFilieresByEcole(
    FetchFilieresByEcole event,
    Emitter<FiliereState> emit,
  ) async {
    emit(const FiliereLoading());
    try {
      final filieres = await filiereRepository.getFilieresByEcole(
        event.ecoleId,
      );
      if (filieres.isEmpty) {
        emit(const FiliereEmpty());
      } else {
        emit(FiliereLoaded(filieres: filieres));
      }
    } catch (e) {
      emit(FiliereError(message: e.toString()));
    }
  }
}
