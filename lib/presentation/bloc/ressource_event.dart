import 'package:equatable/equatable.dart';

abstract class RessourceEvent extends Equatable {
  const RessourceEvent();

  @override
  List<Object?> get props => [];
}

class FetchRessourcesByFiliere extends RessourceEvent {
  final String filiereId;

  const FetchRessourcesByFiliere(this.filiereId);

  @override
  List<Object?> get props => [filiereId];
}

class FetchRessourcesByType extends RessourceEvent {
  final String filiereId;
  final String type;

  const FetchRessourcesByType(this.filiereId, this.type);

  @override
  List<Object?> get props => [filiereId, type];
}

class SearchRessources extends RessourceEvent {
  final String filiereId;
  final String query;

  const SearchRessources(this.filiereId, this.query);

  @override
  List<Object?> get props => [filiereId, query];
}
