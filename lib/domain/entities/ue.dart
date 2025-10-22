import 'package:equatable/equatable.dart';

class UE extends Equatable {
  final String id;
  final String nom;
  final String description;
  final String idFiliere;
  final List<String> anneeEnseignement;
  final List<String> ressources;
  final int? credits;
  final String? semestre;
  final String? enseignant;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UE({
    required this.id,
    required this.nom,
    required this.description,
    required this.idFiliere,
    required this.anneeEnseignement,
    this.ressources = const [],
    this.credits,
    this.semestre,
    this.enseignant,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    nom,
    description,
    idFiliere,
    anneeEnseignement,
    ressources,
    credits,
    semestre,
    enseignant,
  ];

  @override
  String toString() => 'UE(id: $id, nom: $nom, credits: $credits)';
}
