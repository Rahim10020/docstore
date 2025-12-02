import 'package:equatable/equatable.dart';

class Filiere extends Equatable {
  final String id;
  final String nom;
  final String parcoursId;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Filiere({
    required this.id,
    required this.nom,
    required this.parcoursId,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Filiere.fromJson(Map<String, dynamic> json) {
    return Filiere(
      id: json['\$id'] as String,
      nom: json['nom'] as String,
      parcoursId: json['parcoursId'] as String,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['\$createdAt'] as String),
      updatedAt: DateTime.parse(json['\$updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'nom': nom, 'parcoursId': parcoursId, 'description': description};
  }

  @override
  List<Object?> get props => [id, nom, parcoursId];
}
