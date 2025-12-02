import 'package:equatable/equatable.dart';

class Ressource extends Equatable {
  final String id;
  final String nom;
  final String type; // Cours, Exercices, TD, TP, Communiqué
  final String url;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Ressource({
    required this.id,
    required this.nom,
    required this.type,
    required this.url,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ressource.fromJson(Map<String, dynamic> json) {
    return Ressource(
      id: json['\$id'] as String,
      nom: json['nom'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['\$createdAt'] as String),
      updatedAt: DateTime.parse(json['\$updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'nom': nom, 'type': type, 'url': url, 'description': description};
  }

  @override
  List<Object?> get props => [id, nom, type, url];
}
