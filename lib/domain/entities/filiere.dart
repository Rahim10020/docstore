import 'package:equatable/equatable.dart';

class Filiere extends Equatable {
  final String id;
  final String nom;
  final String description;
  final String parcours;
  final String idEcole;
  final String? duree;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Filiere({
    required this.id,
    required this.nom,
    required this.description,
    required this.parcours,
    required this.idEcole,
    this.duree,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, nom, description, parcours, idEcole, duree];

  @override
  String toString() => 'Filiere(id: $id, nom: $nom, parcours: $parcours)';
}
