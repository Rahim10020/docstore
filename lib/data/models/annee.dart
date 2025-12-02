import 'package:equatable/equatable.dart';

class Annee extends Equatable {
  final String id;
  final String nom;
  final int annee;
  final String filiereId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Annee({
    required this.id,
    required this.nom,
    required this.annee,
    required this.filiereId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Annee.fromJson(Map<String, dynamic> json) {
    return Annee(
      id: json['\$id'] as String,
      nom: json['nom'] as String,
      annee: json['annee'] as int,
      filiereId: json['filiereId'] as String,
      createdAt: DateTime.parse(json['\$createdAt'] as String),
      updatedAt: DateTime.parse(json['\$updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'nom': nom, 'annee': annee, 'filiereId': filiereId};
  }

  @override
  List<Object?> get props => [id, nom, annee, filiereId];
}
