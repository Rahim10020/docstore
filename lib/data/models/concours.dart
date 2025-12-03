import 'package:equatable/equatable.dart';

class Concours extends Equatable {
  final String id;
  final String nom;
  final String annee; // Changed to String to match DB
  final String description;
  final List<String> ressources; // IDs Appwrite ou URLs Google Drive
  final String idEcole; // Changed from ecoleId to match DB
  final List<String> communiques; // IDs Appwrite ou URLs Google Drive
  final DateTime createdAt;
  final DateTime updatedAt;

  const Concours({
    required this.id,
    required this.nom,
    required this.annee,
    required this.description,
    this.ressources = const [],
    required this.idEcole,
    this.communiques = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Concours.fromJson(Map<String, dynamic> json) {
    return Concours(
      id: json['\$id'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      annee: json['annee'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ressources:
          (json['ressources'] as List?)?.map((r) => r.toString()).toList() ??
          [],
      idEcole: json['idEcole'] as String? ?? '',
      communiques:
          (json['communiques'] as List?)?.map((r) => r.toString()).toList() ??
          [],
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
      'annee': annee,
      'description': description,
      'ressources': ressources,
      'idEcole': idEcole,
      'communiques': communiques,
    };
  }

  bool get hasCommunique => communiques.isNotEmpty;
  bool get hasRessources => ressources.isNotEmpty;

  @override
  List<Object?> get props => [id, nom, annee, idEcole];
}
