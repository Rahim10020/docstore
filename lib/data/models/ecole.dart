import 'package:equatable/equatable.dart';

class Ecole extends Equatable {
  final String id;
  final String nom;
  final String description;
  final String lieu;
  final String? logo;
  final String? couleur;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Ecole({
    required this.id,
    required this.nom,
    required this.description,
    required this.lieu,
    this.logo,
    this.couleur,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ecole.fromJson(Map<String, dynamic> json) {
    return Ecole(
      id: json['\$id'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String? ?? '',
      lieu: json['lieu'] as String? ?? '',
      logo: json['logo'] as String?,
      couleur: json['couleur'] as String?,
      createdAt: json['\$createdAt'] != null
          ? DateTime.parse(json['\$createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['\$updatedAt'] != null
          ? DateTime.parse(json['\$updatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'description': description,
      'lieu': lieu,
      'logo': logo,
      'couleur': couleur,
    };
  }

  @override
  List<Object?> get props => [id, nom, description, lieu];
}
