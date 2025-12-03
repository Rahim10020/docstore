import 'package:equatable/equatable.dart';
import '../../data/models/index.dart';

abstract class RessourceState extends Equatable {
  const RessourceState();

  @override
  List<Object?> get props => [];
}

class RessourceInitial extends RessourceState {}

class RessourceLoading extends RessourceState {}

class RessourceLoaded extends RessourceState {
  final List<FileResource> ressources;

  const RessourceLoaded(this.ressources);

  @override
  List<Object?> get props => [ressources];
}

class RessourceEmpty extends RessourceState {}

class RessourceError extends RessourceState {
  final String message;

  const RessourceError(this.message);

  @override
  List<Object?> get props => [message];
}
