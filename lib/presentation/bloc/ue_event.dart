import 'package:equatable/equatable.dart';

abstract class UEEvent extends Equatable {
  const UEEvent();

  @override
  List<Object?> get props => [];
}

/// Événement pour charger les UEs d'une filière avec leurs ressources résolues
class FetchUEsByFiliere extends UEEvent {
  final String filiereId;

  const FetchUEsByFiliere(this.filiereId);

  @override
  List<Object?> get props => [filiereId];
}

/// Événement pour rechercher des UEs
class SearchUEs extends UEEvent {
  final String filiereId;
  final String query;

  const SearchUEs(this.filiereId, this.query);

  @override
  List<Object?> get props => [filiereId, query];
}

