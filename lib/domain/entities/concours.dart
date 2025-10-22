import 'package:equatable/equatable.dart';

class Concours extends Equatable {
  final String id;
  final String nom;
  final String description;
  final String idEcole;
  final String annee;
  final List<String> communiques;
  final List<String> ressources;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final String? lienInscription;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Concours({
    required this.id,
    required this.nom,
    required this.description,
    required this.idEcole,
    required this.annee,
    this.communiques = const [],
    this.ressources = const [],
    this.dateDebut,
    this.dateFin,
    this.lienInscription,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive {
    if (dateDebut == null || dateFin == null) return true;
    final now = DateTime.now();
    return now.isAfter(dateDebut!) && now.isBefore(dateFin!);
  }

  @override
  List<Object?> get props => [
    id,
    nom,
    description,
    idEcole,
    annee,
    communiques,
    ressources,
    dateDebut,
    dateFin,
    lienInscription,
  ];

  @override
  String toString() => 'Concours(id: $id, nom: $nom, annee: $annee)';
}
