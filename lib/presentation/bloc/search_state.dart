import 'package:equatable/equatable.dart';
import '../../data/models/index.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  final List<String> history;

  const SearchInitial({this.history = const []});

  @override
  List<Object?> get props => [history];
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchResults extends SearchState {
  final List<Ecole> ecoles;
  final List<Filiere> filieres;
  final List<Cours> cours;
  final List<Concours> concours;
  final List<String> history;

  const SearchResults({
    this.ecoles = const [],
    this.filieres = const [],
    this.cours = const [],
    this.concours = const [],
    this.history = const [],
  });

  bool get isEmpty =>
      ecoles.isEmpty && filieres.isEmpty && cours.isEmpty && concours.isEmpty;

  @override
  List<Object?> get props => [ecoles, filieres, cours, concours, history];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
