import 'package:equatable/equatable.dart';

abstract class ConcoursEvent extends Equatable {
  const ConcoursEvent();

  @override
  List<Object?> get props => [];
}

class FetchConcours extends ConcoursEvent {
  final int page;

  const FetchConcours({this.page = 0});

  @override
  List<Object?> get props => [page];
}

class FetchConcoursById extends ConcoursEvent {
  final String id;

  const FetchConcoursById(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterConcoursById extends ConcoursEvent {
  final String ecoleId;

  const FilterConcoursById(this.ecoleId);

  @override
  List<Object?> get props => [ecoleId];
}

class FilterConcourssByYear extends ConcoursEvent {
  final int year;

  const FilterConcourssByYear(this.year);

  @override
  List<Object?> get props => [year];
}

class SearchConcours extends ConcoursEvent {
  final String query;

  const SearchConcours(this.query);

  @override
  List<Object?> get props => [query];
}
