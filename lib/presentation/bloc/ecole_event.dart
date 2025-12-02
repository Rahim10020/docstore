import 'package:equatable/equatable.dart';

abstract class EcoleEvent extends Equatable {
  const EcoleEvent();

  @override
  List<Object?> get props => [];
}

class FetchEcoles extends EcoleEvent {
  final int page;

  const FetchEcoles({this.page = 0});

  @override
  List<Object?> get props => [page];
}

class FetchEcoleById extends EcoleEvent {
  final String id;

  const FetchEcoleById(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchEcoles extends EcoleEvent {
  final String query;

  const SearchEcoles(this.query);

  @override
  List<Object?> get props => [query];
}
