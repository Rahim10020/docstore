import 'package:equatable/equatable.dart';
import 'ressource.dart';

class Cours extends Equatable {
  final String id;
  final String titre;
  final String description;
  final String semesterId;
  final List<Ressource> ressources;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Cours({
    required this.id,
    required this.titre,
    required this.description,
    required this.semesterId,
    this.ressources = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cours.fromJson(Map<String, dynamic> json) {
    return Cours(
      id: json['\$id'] as String,
      titre: json['titre'] as String,
      description: json['description'] as String? ?? '',
      semesterId: json['semesterId'] as String,
      ressources:
          (json['ressources'] as List?)
              ?.map((r) => Ressource.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['\$createdAt'] as String),
      updatedAt: DateTime.parse(json['\$updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'description': description,
      'semesterId': semesterId,
    };
  }

  @override
  List<Object?> get props => [id, titre, semesterId, ressources];
}
