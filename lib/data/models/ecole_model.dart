import 'package:equatable/equatable.dart';
import '../../core/enums/ecole_type.dart';

class EcoleModel extends Equatable {
  final String id;
  final String nom;
  final String nomComplet;
  final EcoleType type;
  final String typeFiliere; // "departement" ou "parcours"
  final bool hasConcours;
  final bool hasDevoirs;
  final int? ordre;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EcoleModel({
    required this.id,
    required this.nom,
    required this.nomComplet,
    required this.type,
    required this.typeFiliere,
    required this.hasConcours,
    required this.hasDevoirs,
    this.ordre,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  // Factory depuis JSON Appwrite
  factory EcoleModel.fromJson(Map<String, dynamic> json) {
    return EcoleModel(
      id: json['\$id'] ?? json['id'] ?? '',
      nom: json['nom'] ?? '',
      nomComplet: json['nomComplet'] ?? '',
      type: EcoleType.fromString(json['type'] ?? 'ecole'),
      typeFiliere: json['typeFiliere'] ?? 'departement',
      hasConcours: json['hasConcours'] ?? false,
      hasDevoirs: json['hasDevoirs'] ?? false,
      ordre: json['ordre'],
      isActive: json['isActive'] ?? true,
      createdAt: json['\$createdAt'] != null
          ? DateTime.parse(json['\$createdAt'])
          : null,
      updatedAt: json['\$updatedAt'] != null
          ? DateTime.parse(json['\$updatedAt'])
          : null,
    );
  }

  // Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'nomComplet': nomComplet,
      'type': type.name,
      'typeFiliere': typeFiliere,
      'hasConcours': hasConcours,
      'hasDevoirs': hasDevoirs,
      'ordre': ordre,
      'isActive': isActive,
    };
  }

  // CopyWith pour immutabilité
  EcoleModel copyWith({
    String? id,
    String? nom,
    String? nomComplet,
    EcoleType? type,
    String? typeFiliere,
    bool? hasConcours,
    bool? hasDevoirs,
    int? ordre,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EcoleModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      nomComplet: nomComplet ?? this.nomComplet,
      type: type ?? this.type,
      typeFiliere: typeFiliere ?? this.typeFiliere,
      hasConcours: hasConcours ?? this.hasConcours,
      hasDevoirs: hasDevoirs ?? this.hasDevoirs,
      ordre: ordre ?? this.ordre,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nom,
    nomComplet,
    type,
    typeFiliere,
    hasConcours,
    hasDevoirs,
    ordre,
    isActive,
  ];

  @override
  bool get stringify => true;
}
