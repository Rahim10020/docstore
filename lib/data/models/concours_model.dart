import 'package:equatable/equatable.dart';
import '../../core/enums/ecole_type.dart';
import '../../core/enums/statut_concours.dart';

class ConcoursModel extends Equatable {
  final String id;
  final String nom;
  final String idEcole;
  final EcoleType typeEtablissement;
  final String annee;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final String? lienInscription;
  final StatutConcours statut;
  final int? ordre;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ConcoursModel({
    required this.id,
    required this.nom,
    required this.idEcole,
    required this.typeEtablissement,
    required this.annee,
    this.dateDebut,
    this.dateFin,
    this.lienInscription,
    required this.statut,
    this.ordre,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  // Factory depuis JSON Appwrite
  factory ConcoursModel.fromJson(Map<String, dynamic> json) {
    return ConcoursModel(
      id: json['\$id'] ?? json['id'] ?? '',
      nom: json['nom'] ?? '',
      idEcole: json['idEcole'] ?? '',
      typeEtablissement: EcoleType.fromString(
        json['typeEtablissement'] ?? 'ecole',
      ),
      annee: json['annee'] ?? DateTime.now().year.toString(),
      dateDebut: json['dateDebut'] != null
          ? DateTime.parse(json['dateDebut'])
          : null,
      dateFin: json['dateFin'] != null ? DateTime.parse(json['dateFin']) : null,
      lienInscription: json['lienInscription'],
      statut: StatutConcours.fromString(json['statut'] ?? 'A venir'),
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
      'typeEtablissement': typeEtablissement.name,
      'annee': annee,
      'dateDebut': dateDebut?.toIso8601String(),
      'dateFin': dateFin?.toIso8601String(),
      'lienInscription': lienInscription,
      'statut': statut.label,
      'ordre': ordre,
      'isActive': isActive,
    };
  }

  // CopyWith
  ConcoursModel copyWith({
    String? id,
    String? nom,
    String? idEcole,
    EcoleType? typeEtablissement,
    String? annee,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? lienInscription,
    StatutConcours? statut,
    int? ordre,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConcoursModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      idEcole: idEcole ?? this.idEcole,
      typeEtablissement: typeEtablissement ?? this.typeEtablissement,
      annee: annee ?? this.annee,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      lienInscription: lienInscription ?? this.lienInscription,
      statut: statut ?? this.statut,
      ordre: ordre ?? this.ordre,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper: Est-ce que le concours est encore ouvert?
  bool get isOpen {
    if (statut != StatutConcours.enCours) return false;
    if (dateFin == null) return true;
    return DateTime.now().isBefore(dateFin!);
  }

  // Helper: Nombre de jours restants
  int? get joursRestants {
    if (dateFin == null) return null;
    final diff = dateFin!.difference(DateTime.now());
    return diff.isNegative ? 0 : diff.inDays;
  }

  @override
  List<Object?> get props => [
    id,
    nom,
    idEcole,
    typeEtablissement,
    annee,
    dateDebut,
    dateFin,
    lienInscription,
    statut,
    ordre,
    isActive,
  ];

  @override
  bool get stringify => true;
}
