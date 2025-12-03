import 'package:equatable/equatable.dart';

/// Modèle pour la table "ues" (Unités d'Enseignement)
class UE extends Equatable {
  final String id; // required in DB
  final String nom; // required in DB
  final String description;
  final String? anneeEnseignement;
  final List<String> ressources;
  final String idFiliere; // required in DB
  final DateTime createdAt;
  final DateTime updatedAt;

  const UE({
    required this.id,
    required this.nom,
    required this.description,
    this.anneeEnseignement,
    this.ressources = const [],
    required this.idFiliere,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UE.fromJson(Map<String, dynamic> json) {
    return UE(
      id: json['id'] as String? ?? json['\$id'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String? ?? '',
      anneeEnseignement: json['anneeEnseignement'] as String?,
      ressources:
          (json['ressources'] as List?)?.map((r) => r.toString()).toList() ??
          [],
      idFiliere: json['idFiliere'] as String? ?? '',
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
      'id': id,
      'nom': nom,
      'description': description,
      'anneeEnseignement': anneeEnseignement,
      'ressources': ressources,
      'idFiliere': idFiliere,
    };
  }

  @override
  List<Object?> get props => [id, nom, idFiliere];
}
