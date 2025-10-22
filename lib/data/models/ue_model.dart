import '../../domain/entities/ue.dart';

class UEModel extends UE {
  const UEModel({
    required super.id,
    required super.nom,
    required super.description,
    required super.idFiliere,
    required super.anneeEnseignement,
    super.ressources = const [],
    super.credits,
    super.semestre,
    super.enseignant,
    super.createdAt,
    super.updatedAt,
  });

  factory UEModel.fromJson(Map<String, dynamic> json) {
    return UEModel(
      id: json['\$id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String,
      idFiliere: json['idFiliere'] as String,
      anneeEnseignement: List<String>.from(json['anneeEnseignement'] ?? []),
      ressources: List<String>.from(json['ressources'] ?? []),
      credits: json['credits'] as int?,
      semestre: json['semestre'] as String?,
      enseignant: json['enseignant'] as String?,
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
      'idFiliere': idFiliere,
      'anneeEnseignement': anneeEnseignement,
      'ressources': ressources,
      if (credits != null) 'credits': credits,
      if (semestre != null) 'semestre': semestre,
      if (enseignant != null) 'enseignant': enseignant,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'idFiliere': idFiliere,
      'anneeEnseignement': anneeEnseignement,
      'ressources': ressources,
      'credits': credits,
      'semestre': semestre,
      'enseignant': enseignant,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UEModel.fromMap(Map<String, dynamic> map) {
    return UEModel(
      id: map['id'] as String,
      nom: map['nom'] as String,
      description: map['description'] as String,
      idFiliere: map['idFiliere'] as String,
      anneeEnseignement: List<String>.from(map['anneeEnseignement'] ?? []),
      ressources: List<String>.from(map['ressources'] ?? []),
      credits: map['credits'] as int?,
      semestre: map['semestre'] as String?,
      enseignant: map['enseignant'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  UEModel copyWith({
    String? id,
    String? nom,
    String? description,
    String? idFiliere,
    List<String>? anneeEnseignement,
    List<String>? ressources,
    int? credits,
    String? semestre,
    String? enseignant,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UEModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      idFiliere: idFiliere ?? this.idFiliere,
      anneeEnseignement: anneeEnseignement ?? this.anneeEnseignement,
      ressources: ressources ?? this.ressources,
      credits: credits ?? this.credits,
      semestre: semestre ?? this.semestre,
      enseignant: enseignant ?? this.enseignant,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
