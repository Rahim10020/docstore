import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/app_constants.dart';
import '../../data/models/index.dart';
import '../../data/repositories/index.dart';
import 'concours_event.dart';
import 'concours_state.dart';

class ConcoursBloc extends Bloc<ConcoursEvent, ConcoursState> {
  final ConcoursRepository _repository;
  int _currentPage = 0;

  ConcoursBloc(this._repository) : super(const ConcoursInitial()) {
    on<FetchConcours>(_onFetchConcours);
    on<FetchConcoursById>(_onFetchConcoursById);
    on<SearchConcours>(_onSearchConcours);
  }

  Future<void> _onFetchConcours(
    FetchConcours event,
    Emitter<ConcoursState> emit,
  ) async {
    if (event.page == 0) {
      emit(const ConcoursLoading());
      _currentPage = 0;
    }

    try {
      final offset = _currentPage * AppConstants.itemsPerPage;
      final concours = await _repository.getConcours(
        limit: AppConstants.itemsPerPage,
        offset: offset,
      );

      if (concours.isEmpty && _currentPage == 0) {
        emit(const ConcoursEmpty());
      } else {
        final previousConcours = state is ConcoursLoaded
            ? (state as ConcoursLoaded).concours
            : <Concours>[];
        final updatedConcours = _currentPage == 0
            ? concours
            : [...previousConcours, ...concours];

        emit(
          ConcoursLoaded(
            concours: updatedConcours,
            hasReachedEnd: concours.length < AppConstants.itemsPerPage,
          ),
        );

        if (concours.length == AppConstants.itemsPerPage) {
          _currentPage++;
        }
      }
    } catch (e) {
      emit(ConcoursError(e.toString()));
    }
  }

  Future<void> _onFetchConcoursById(
    FetchConcoursById event,
    Emitter<ConcoursState> emit,
  ) async {
    emit(const ConcoursLoading());
    try {
      final concours = await _repository.getConcoursById(event.id);
      emit(ConcoursDetailLoaded(concours));
    } catch (e) {
      emit(ConcoursError(e.toString()));
    }
  }

  Future<void> _onSearchConcours(
    SearchConcours event,
    Emitter<ConcoursState> emit,
  ) async {
    emit(const ConcoursLoading());
    try {
      final concours = await _repository.searchConcours(event.query);
      if (concours.isEmpty) {
        emit(const ConcoursEmpty());
      } else {
        emit(ConcoursLoaded(concours: concours));
      }
    } catch (e) {
      emit(ConcoursError(e.toString()));
    }
  }
}
