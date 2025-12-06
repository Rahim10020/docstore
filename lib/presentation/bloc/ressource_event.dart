import 'package:equatable/equatable.dart';

abstract class RessourceEvent extends Equatable {
  const RessourceEvent();

  @override
  List<Object?> get props => [];
}

class FetchRessourcesByType extends RessourceEvent {
  final String coursId;
  final String type;

  const FetchRessourcesByType(this.coursId, this.type);

  @override
  List<Object?> get props => [coursId, type];
}

class SearchRessources extends RessourceEvent {
  final String filiereId;
  final String query;

  const SearchRessources(this.filiereId, this.query);

  @override
  List<Object?> get props => [filiereId, query];
}
