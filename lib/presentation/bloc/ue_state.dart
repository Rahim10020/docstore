import 'package:equatable/equatable.dart';
import '../../data/models/index.dart';

abstract class UEState extends Equatable {
  const UEState();

  @override
  List<Object?> get props => [];
}

class UEInitial extends UEState {}

class UELoading extends UEState {}

class UELoaded extends UEState {
  final List<UE> ues;

  const UELoaded(this.ues);

  @override
  List<Object?> get props => [ues];
}

class UEEmpty extends UEState {}

class UEError extends UEState {
  final String message;

  const UEError(this.message);

  @override
  List<Object?> get props => [message];
}

