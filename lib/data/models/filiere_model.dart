import '../../domain/entities/filiere.dart';

class FiliereModel extends Filiere {
  const FiliereModel({
    required super.id,
    required super.nom,
    required super.description,
    required super.parcours,
    required super.idEcole,
    super.duree,
    super.createdAt,
    super.updatedAt,
  });

  factory FiliereModel.fromJson(Map<String, dynamic> json) {
    return FiliereModel(
      id: json['\$id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String,
      parcours: json['parcours'] as String,
      idEcole: json['idEcole'] as String,
      duree: json['duree'] as String?,
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
      'parcours': parcours,
      'idEcole': idEcole,
      if (duree != null) 'duree': duree,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'parcours': parcours,
      'idEcole': idEcole,
      'duree': duree,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory FiliereModel.fromMap(Map<String, dynamic> map) {
    return FiliereModel(
      id: map['id'] as String,
      nom: map['nom'] as String,
      description: map['description'] as String,
      parcours: map['parcours'] as String,
      idEcole: map['idEcole'] as String,
      duree: map['duree'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  FiliereModel copyWith({
    String? id,
    String? nom,
    String? description,
    String? parcours,
    String? idEcole,
    String? duree,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FiliereModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      parcours: parcours ?? this.parcours,
      idEcole: idEcole ?? this.idEcole,
      duree: duree ?? this.duree,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
