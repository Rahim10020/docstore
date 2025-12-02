import 'package:equatable/equatable.dart';
import '../../data/models/index.dart';

abstract class ConcoursState extends Equatable {
  const ConcoursState();

  @override
  List<Object?> get props => [];
}

class ConcoursInitial extends ConcoursState {
  const ConcoursInitial();
}

class ConcoursLoading extends ConcoursState {
  const ConcoursLoading();
}

class ConcoursLoaded extends ConcoursState {
  final List<Concours> concours;
  final bool hasReachedEnd;

  const ConcoursLoaded({required this.concours, this.hasReachedEnd = false});

  @override
  List<Object?> get props => [concours, hasReachedEnd];
}

class ConcoursDetailLoaded extends ConcoursState {
  final Concours concours;

  const ConcoursDetailLoaded(this.concours);

  @override
  List<Object?> get props => [concours];
}

class ConcoursError extends ConcoursState {
  final String message;

  const ConcoursError(this.message);

  @override
  List<Object?> get props => [message];
}

class ConcoursEmpty extends ConcoursState {
  const ConcoursEmpty();
}
