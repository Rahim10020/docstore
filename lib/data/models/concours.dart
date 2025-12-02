import 'package:equatable/equatable.dart';

class Concours extends Equatable {
  final String id;
  final String nom;
  final String description;
  final int annee;
  final String ecoleId;
  final List<String> communiques; // IDs Appwrite ou URLs Google Drive
  final List<String> ressources; // IDs Appwrite ou URLs Google Drive
  final DateTime createdAt;
  final DateTime updatedAt;

  const Concours({
    required this.id,
    required this.nom,
    required this.description,
    required this.annee,
    required this.ecoleId,
    this.communiques = const [],
    this.ressources = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Concours.fromJson(Map<String, dynamic> json) {
    return Concours(
      id: json['\$id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String? ?? '',
      annee: json['annee'] as int,
      ecoleId: json['ecoleId'] as String,
      communiques:
          (json['communiques'] as List?)?.map((r) => r.toString()).toList() ??
          [],
      ressources:
          (json['ressources'] as List?)?.map((r) => r.toString()).toList() ??
          [],
      createdAt: DateTime.parse(json['\$createdAt'] as String),
      updatedAt: DateTime.parse(json['\$updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'description': description,
      'annee': annee,
      'ecoleId': ecoleId,
      'communiques': communiques,
      'ressources': ressources,
    };
  }

  bool get hasCommunique => communiques.isNotEmpty;
  bool get hasRessources => ressources.isNotEmpty;

  @override
  List<Object?> get props => [id, nom, annee, ecoleId];
}
