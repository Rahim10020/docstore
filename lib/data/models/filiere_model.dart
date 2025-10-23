import 'package:equatable/equatable.dart';
import '../../core/enums/type_licence.dart';

class FiliereModel extends Equatable {
  final String id;
  final String nom;
  final String idEcole;
  final String typeFiliere; // "departement" ou "parcours"
  final TypeLicence typeLicence;
  final int? ordre;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FiliereModel({
    required this.id,
    required this.nom,
    required this.idEcole,
    required this.typeFiliere,
    required this.typeLicence,
    this.ordre,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  // Factory depuis JSON Appwrite
  factory FiliereModel.fromJson(Map<String, dynamic> json) {
    return FiliereModel(
      id: json['\$id'] ?? json['id'] ?? '',
      nom: json['nom'] ?? '',
      idEcole: json['idEcole'] ?? '',
      typeFiliere: json['typeFiliere'] ?? 'departement',
      typeLicence: TypeLicence.fromString(json['typeLicence'] ?? 'Département'),
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
      'idEcole': idEcole,
      'typeFiliere': typeFiliere,
      'typeLicence': typeLicence.label,
      'ordre': ordre,
      'isActive': isActive,
    };
  }

  // CopyWith
  FiliereModel copyWith({
    String? id,
    String? nom,
    String? idEcole,
    String? typeFiliere,
    TypeLicence? typeLicence,
    int? ordre,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FiliereModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      idEcole: idEcole ?? this.idEcole,
      typeFiliere: typeFiliere ?? this.typeFiliere,
      typeLicence: typeLicence ?? this.typeLicence,
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
    idEcole,
    typeFiliere,
    typeLicence,
    ordre,
    isActive,
  ];

  @override
  bool get stringify => true;
}
