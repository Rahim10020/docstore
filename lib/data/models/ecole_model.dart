import '../../domain/entities/ecole.dart';

class EcoleModel extends Ecole {
  const EcoleModel({
    required super.id,
    required super.nom,
    required super.description,
    super.lieu,
    super.logo,
    super.createdAt,
    super.updatedAt,
  });

  // From JSON (Appwrite Document)
  factory EcoleModel.fromJson(Map<String, dynamic> json) {
    return EcoleModel(
      id: json['\$id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String,
      lieu: json['lieu'] as String?,
      logo: json['logo'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // To JSON (pour Appwrite)
  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'description': description,
      if (lieu != null) 'lieu': lieu,
      if (logo != null) 'logo': logo,
    };
  }

  // To Map (pour Hive cache)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'lieu': lieu,
      'logo': logo,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // From Map (depuis Hive cache)
  factory EcoleModel.fromMap(Map<String, dynamic> map) {
    return EcoleModel(
      id: map['id'] as String,
      nom: map['nom'] as String,
      description: map['description'] as String,
      lieu: map['lieu'] as String?,
      logo: map['logo'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  // Copy with
  EcoleModel copyWith({
    String? id,
    String? nom,
    String? description,
    String? lieu,
    String? logo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EcoleModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      lieu: lieu ?? this.lieu,
      logo: logo ?? this.logo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
