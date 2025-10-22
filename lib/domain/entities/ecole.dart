import 'package:equatable/equatable.dart';

class Ecole extends Equatable {
  final String id;
  final String nom;
  final String description;
  final String? lieu;
  final String? logo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Ecole({
    required this.id,
    required this.nom,
    required this.description,
    this.lieu,
    this.logo,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    nom,
    description,
    lieu,
    logo,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() => 'Ecole(id: $id, nom: $nom)';
}
