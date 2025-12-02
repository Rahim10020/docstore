import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class PerformSearch extends SearchEvent {
  final String query;

  const PerformSearch(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends SearchEvent {
  const ClearSearch();
}

class AddToHistory extends SearchEvent {
  final String query;

  const AddToHistory(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearHistory extends SearchEvent {
  const ClearHistory();
}
