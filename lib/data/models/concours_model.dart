import '../../domain/entities/concours.dart';

class ConcoursModel extends Concours {
  const ConcoursModel({
    required super.id,
    required super.nom,
    required super.description,
    required super.idEcole,
    required super.annee,
    super.communiques = const [],
    super.ressources = const [],
    super.dateDebut,
    super.dateFin,
    super.lienInscription,
    super.createdAt,
    super.updatedAt,
  });

  factory ConcoursModel.fromJson(Map<String, dynamic> json) {
    return ConcoursModel(
      id: json['\$id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String,
      idEcole: json['idEcole'] as String,
      annee: json['annee'] as String,
      communiques: List<String>.from(json['communiques'] ?? []),
      ressources: List<String>.from(json['ressources'] ?? []),
      dateDebut: json['dateDebut'] != null
          ? DateTime.parse(json['dateDebut'] as String)
          : null,
      dateFin: json['dateFin'] != null
          ? DateTime.parse(json['dateFin'] as String)
          : null,
      lienInscription: json['lienInscription'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'description': description,
      'idEcole': idEcole,
      'annee': annee,
      'communiques': communiques,
      'ressources': ressources,
      if (dateDebut != null) 'dateDebut': dateDebut!.toIso8601String(),
      if (dateFin != null) 'dateFin': dateFin!.toIso8601String(),
      if (lienInscription != null) 'lienInscription': lienInscription,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'idEcole': idEcole,
      'annee': annee,
      'communiques': communiques,
      'ressources': ressources,
      'dateDebut': dateDebut?.toIso8601String(),
      'dateFin': dateFin?.toIso8601String(),
      'lienInscription': lienInscription,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ConcoursModel.fromMap(Map<String, dynamic> map) {
    return ConcoursModel(
      id: map['id'] as String,
      nom: map['nom'] as String,
      description: map['description'] as String,
      idEcole: map['idEcole'] as String,
      annee: map['annee'] as String,
      communiques: List<String>.from(map['communiques'] ?? []),
      ressources: List<String>.from(map['ressources'] ?? []),
      dateDebut: map['dateDebut'] != null
          ? DateTime.parse(map['dateDebut'] as String)
          : null,
      dateFin: map['dateFin'] != null
          ? DateTime.parse(map['dateFin'] as String)
          : null,
      lienInscription: map['lienInscription'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  ConcoursModel copyWith({
    String? id,
    String? nom,
    String? description,
    String? idEcole,
    String? annee,
    List<String>? communiques,
    List<String>? ressources,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? lienInscription,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConcoursModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      idEcole: idEcole ?? this.idEcole,
      annee: annee ?? this.annee,
      communiques: communiques ?? this.communiques,
      ressources: ressources ?? this.ressources,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      lienInscription: lienInscription ?? this.lienInscription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
