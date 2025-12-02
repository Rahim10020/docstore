import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/app_constants.dart';
import '../../data/models/index.dart';
import '../../data/repositories/index.dart';
import 'ecole_event.dart';
import 'ecole_state.dart';

class EcoleBloc extends Bloc<EcoleEvent, EcoleState> {
  final EcoleRepository _repository;
  int _currentPage = 0;

  EcoleBloc(this._repository) : super(const EcoleInitial()) {
    on<FetchEcoles>(_onFetchEcoles);
    on<FetchEcoleById>(_onFetchEcoleById);
    on<SearchEcoles>(_onSearchEcoles);
  }

  Future<void> _onFetchEcoles(
    FetchEcoles event,
    Emitter<EcoleState> emit,
  ) async {
    if (event.page == 0) {
      emit(const EcoleLoading());
      _currentPage = 0;
    }

    try {
      final offset = _currentPage * AppConstants.itemsPerPage;
      final ecoles = await _repository.getEcoles(
        limit: AppConstants.itemsPerPage,
        offset: offset,
      );

      if (ecoles.isEmpty && _currentPage == 0) {
        emit(const EcoleEmpty());
      } else {
        final previousEcoles = state is EcoleLoaded
            ? (state as EcoleLoaded).ecoles
            : <Ecole>[];
        final updatedEcoles = _currentPage == 0
            ? ecoles
            : [...previousEcoles, ...ecoles];

        emit(
          EcoleLoaded(
            ecoles: updatedEcoles,
            hasReachedEnd: ecoles.length < AppConstants.itemsPerPage,
          ),
        );

        if (ecoles.length == AppConstants.itemsPerPage) {
          _currentPage++;
        }
      }
    } catch (e) {
      emit(EcoleError(e.toString()));
    }
  }

  Future<void> _onFetchEcoleById(
    FetchEcoleById event,
    Emitter<EcoleState> emit,
  ) async {
    emit(const EcoleLoading());
    try {
      final ecole = await _repository.getEcoleById(event.id);
      emit(EcoleDetailLoaded(ecole));
    } catch (e) {
      emit(EcoleError(e.toString()));
    }
  }

  Future<void> _onSearchEcoles(
    SearchEcoles event,
    Emitter<EcoleState> emit,
  ) async {
    emit(const EcoleLoading());
    try {
      final ecoles = await _repository.searchEcoles(event.query);
      if (ecoles.isEmpty) {
        emit(const EcoleEmpty());
      } else {
        emit(EcoleLoaded(ecoles: ecoles));
      }
    } catch (e) {
      emit(EcoleError(e.toString()));
    }
  }
}
