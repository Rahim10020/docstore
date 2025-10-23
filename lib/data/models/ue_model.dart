import 'package:equatable/equatable.dart';
import '../../core/enums/annee_enum.dart';
import '../../core/enums/semestre_enum.dart';
import '../../core/enums/ecole_type.dart';

class UeModel extends Equatable {
  final String id;
  final String code;
  final String nom;
  final String idFiliere;
  final EcoleType typeEtablissement;
  final AnneeEnum annee;
  final SemestreEnum? semestre;
  final int? credits;
  final int? ordre;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UeModel({
    required this.id,
    required this.code,
    required this.nom,
    required this.idFiliere,
    required this.typeEtablissement,
    required this.annee,
    this.semestre,
    this.credits,
    this.ordre,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  // Factory depuis JSON Appwrite
  factory UeModel.fromJson(Map<String, dynamic> json) {
    return UeModel(
      id: json['\$id'] ?? json['id'] ?? '',
      code: json['code'] ?? '',
      nom: json['nom'] ?? '',
      idFiliere: json['idFiliere'] ?? '',
      typeEtablissement: EcoleType.fromString(
        json['typeEtablissement'] ?? 'ecole',
      ),
      annee: AnneeEnum.fromString(json['annee'] ?? 'Année 1'),
      semestre: SemestreEnum.fromString(json['semestre']),
      credits: json['credits'],
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
      'code': code,
      'nom': nom,
      'idFiliere': idFiliere,
      'typeEtablissement': typeEtablissement.name,
      'annee': annee.label,
      'semestre': semestre?.label,
      'credits': credits,
      'ordre': ordre,
      'isActive': isActive,
    };
  }

  // CopyWith
  UeModel copyWith({
    String? id,
    String? code,
    String? nom,
    String? idFiliere,
    EcoleType? typeEtablissement,
    AnneeEnum? annee,
    SemestreEnum? semestre,
    int? credits,
    int? ordre,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UeModel(
      id: id ?? this.id,
      code: code ?? this.code,
      nom: nom ?? this.nom,
      idFiliere: idFiliere ?? this.idFiliere,
      typeEtablissement: typeEtablissement ?? this.typeEtablissement,
      annee: annee ?? this.annee,
      semestre: semestre ?? this.semestre,
      credits: credits ?? this.credits,
      ordre: ordre ?? this.ordre,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    code,
    nom,
    idFiliere,
    typeEtablissement,
    annee,
    semestre,
    credits,
    ordre,
    isActive,
  ];

  @override
  bool get stringify => true;
}
