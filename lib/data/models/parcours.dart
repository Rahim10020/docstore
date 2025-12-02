import 'package:equatable/equatable.dart';

class Parcours extends Equatable {
  final String id;
  final String nom;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Parcours({
    required this.id,
    required this.nom,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Parcours.fromJson(Map<String, dynamic> json) {
    return Parcours(
      id: json['\$id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['\$createdAt'] as String),
      updatedAt: DateTime.parse(json['\$updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'nom': nom, 'description': description};
  }

  @override
  List<Object?> get props => [id, nom];
}
