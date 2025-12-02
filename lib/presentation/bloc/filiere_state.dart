import 'package:equatable/equatable.dart';
import '../../data/models/index.dart';

abstract class FiliereState extends Equatable {
  const FiliereState();

  @override
  List<Object> get props => [];
}

class FiliereInitial extends FiliereState {
  const FiliereInitial();
}

class FiliereLoading extends FiliereState {
  const FiliereLoading();
}

class FiliereLoaded extends FiliereState {
  final List<Filiere> filieres;

  const FiliereLoaded({required this.filieres});

  @override
  List<Object> get props => [filieres];
}

class FiliereEmpty extends FiliereState {
  const FiliereEmpty();
}

class FiliereError extends FiliereState {
  final String message;

  const FiliereError({required this.message});

  @override
  List<Object> get props => [message];
}
