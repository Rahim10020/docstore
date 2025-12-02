import 'package:equatable/equatable.dart';

class Cours extends Equatable {
  final String id;
  final String titre;
  final String description;
  final String semesterId;
  final List<String> ressources; // IDs Appwrite ou URLs Google Drive
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
          (json['ressources'] as List?)?.map((r) => r.toString()).toList() ??
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
      'ressources': ressources,
    };
  }

  @override
  List<Object?> get props => [id, titre, semesterId, ressources];
}
