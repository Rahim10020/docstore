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
    int annee = 0;
    final anneeValue = json['annee'];
    if (anneeValue != null) {
      if (anneeValue is int) {
        annee = anneeValue;
      } else if (anneeValue is String) {
        annee = int.tryParse(anneeValue) ?? 0;
      }
    }

    return Concours(
      id: json['\$id'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String? ?? '',
      annee: annee,
      ecoleId: json['ecoleId'] as String? ?? '',
      communiques:
          (json['communiques'] as List?)?.map((r) => r.toString()).toList() ??
          [],
      ressources:
          (json['ressources'] as List?)?.map((r) => r.toString()).toList() ??
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
