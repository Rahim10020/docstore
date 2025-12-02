import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/app_constants.dart';
import '../../data/repositories/index.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final EcoleRepository _ecoleRepository;
  final FiliereRepository _filiereRepository;
  final CoursRepository _coursRepository;
  final ConcoursRepository _concoursRepository;

  final List<String> _searchHistory = [];

  SearchBloc(
    this._ecoleRepository,
    this._filiereRepository,
    this._coursRepository,
    this._concoursRepository,
  ) : super(const SearchInitial()) {
    on<PerformSearch>(_onPerformSearch);
    on<ClearSearch>(_onClearSearch);
    on<AddToHistory>(_onAddToHistory);
    on<ClearHistory>(_onClearHistory);
  }

  Future<void> _onPerformSearch(
    PerformSearch event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.length < AppConstants.minSearchLength) {
      emit(SearchInitial(history: _searchHistory));
      return;
    }

    emit(const SearchLoading());

    try {
      final ecoles = await _ecoleRepository.searchEcoles(event.query);
      final filieres = await _filiereRepository.searchFilieres(event.query);
      final cours = await _coursRepository.searchCours(event.query);
      final concours = await _concoursRepository.searchConcours(event.query);

      emit(
        SearchResults(
          ecoles: ecoles,
          filieres: filieres,
          cours: cours,
          concours: concours,
          history: _searchHistory,
        ),
      );

      // Add to history
      add(AddToHistory(event.query));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    emit(SearchInitial(history: _searchHistory));
  }

  void _onAddToHistory(AddToHistory event, Emitter<SearchState> emit) {
    if (!_searchHistory.contains(event.query)) {
      _searchHistory.insert(0, event.query);
      if (_searchHistory.length > AppConstants.maxSearchHistory) {
        _searchHistory.removeLast();
      }
    }
  }

  void _onClearHistory(ClearHistory event, Emitter<SearchState> emit) {
    _searchHistory.clear();
    emit(SearchInitial(history: _searchHistory));
  }
}
