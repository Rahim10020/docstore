import 'package:equatable/equatable.dart';

abstract class FiliereEvent extends Equatable {
  const FiliereEvent();

  @override
  List<Object> get props => [];
}

class FetchFilieresByEcole extends FiliereEvent {
  final String ecoleId;

  const FetchFilieresByEcole(this.ecoleId);

  @override
  List<Object> get props => [ecoleId];
}
