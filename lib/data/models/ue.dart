import 'package:equatable/equatable.dart';
import 'file_resource.dart';

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
  // Liste des fichiers résolus (Google Drive ou Appwrite)
  final List<FileResource>? files;

  const UE({
    required this.id,
    required this.nom,
    required this.description,
    this.anneeEnseignement,
    this.ressources = const [],
    required this.idFiliere,
    required this.createdAt,
    required this.updatedAt,
    this.files,
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

  /// Crée une copie de l'UE avec les fichiers résolus
  UE copyWith({List<FileResource>? files}) {
    return UE(
      id: id,
      nom: nom,
      description: description,
      anneeEnseignement: anneeEnseignement,
      ressources: ressources,
      idFiliere: idFiliere,
      createdAt: createdAt,
      updatedAt: updatedAt,
      files: files ?? this.files,
    );
  }

  @override
  List<Object?> get props => [id, nom, idFiliere, files];
}
