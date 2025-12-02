import 'package:equatable/equatable.dart';
import '../../data/models/index.dart';

abstract class EcoleState extends Equatable {
  const EcoleState();

  @override
  List<Object?> get props => [];
}

class EcoleInitial extends EcoleState {
  const EcoleInitial();
}

class EcoleLoading extends EcoleState {
  const EcoleLoading();
}

class EcoleLoaded extends EcoleState {
  final List<Ecole> ecoles;
  final bool hasReachedEnd;

  const EcoleLoaded({required this.ecoles, this.hasReachedEnd = false});

  @override
  List<Object?> get props => [ecoles, hasReachedEnd];
}

class EcoleDetailLoaded extends EcoleState {
  final Ecole ecole;

  const EcoleDetailLoaded(this.ecole);

  @override
  List<Object?> get props => [ecole];
}

class EcoleError extends EcoleState {
  final String message;

  const EcoleError(this.message);

  @override
  List<Object?> get props => [message];
}

class EcoleEmpty extends EcoleState {
  const EcoleEmpty();
}
