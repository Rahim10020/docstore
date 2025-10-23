import 'package:equatable/equatable.dart';
import '../../core/enums/source_type_enum.dart';
import '../../core/enums/ecole_type.dart';

class FileModel extends Equatable {
  final String id;
  final String nom;
  final String type; // "ressource", "communique", "epreuve", "devoir"
  final SourceTypeEnum sourceType;
  final String fileId; // ID Appwrite ou URL
  final String? extension;
  final EcoleType typeEtablissement;
  final String parentType; // "ue" ou "concours"
  final String parentId;
  final String? annee;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FileModel({
    required this.id,
    required this.nom,
    required this.type,
    required this.sourceType,
    required this.fileId,
    this.extension,
    required this.typeEtablissement,
    required this.parentType,
    required this.parentId,
    this.annee,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  // Factory depuis JSON Appwrite
  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['\$id'] ?? json['id'] ?? '',
      nom: json['nom'] ?? '',
      type: json['type'] ?? 'ressource',
      sourceType: SourceTypeEnum.fromString(json['sourceType'] ?? 'appwrite'),
      fileId: json['fileId'] ?? '',
      extension: json['extension'],
      typeEtablissement: EcoleType.fromString(
        json['typeEtablissement'] ?? 'ecole',
      ),
      parentType: json['parentType'] ?? 'ue',
      parentId: json['parentId'] ?? '',
      annee: json['annee'],
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
      'type': type,
      'sourceType': sourceType.value,
      'fileId': fileId,
      'extension': extension,
      'typeEtablissement': typeEtablissement.name,
      'parentType': parentType,
      'parentId': parentId,
      'annee': annee,
      'isActive': isActive,
    };
  }

  // CopyWith
  FileModel copyWith({
    String? id,
    String? nom,
    String? type,
    SourceTypeEnum? sourceType,
    String? fileId,
    String? extension,
    EcoleType? typeEtablissement,
    String? parentType,
    String? parentId,
    String? annee,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FileModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      type: type ?? this.type,
      sourceType: sourceType ?? this.sourceType,
      fileId: fileId ?? this.fileId,
      extension: extension ?? this.extension,
      typeEtablissement: typeEtablissement ?? this.typeEtablissement,
      parentType: parentType ?? this.parentType,
      parentId: parentId ?? this.parentId,
      annee: annee ?? this.annee,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper: Est-ce un PDF?
  bool get isPdf => extension?.toLowerCase() == 'pdf';

  // Helper: Icône selon le type
  String get typeIcon {
    switch (type) {
      case 'ressource':
        return '📚';
      case 'communique':
        return '📢';
      case 'epreuve':
        return '📝';
      case 'devoir':
        return '✍️';
      default:
        return '📄';
    }
  }

  // Helper: Label du type
  String get typeLabel {
    switch (type) {
      case 'ressource':
        return 'Ressource';
      case 'communique':
        return 'Communiqué';
      case 'epreuve':
        return 'Épreuve';
      case 'devoir':
        return 'Devoir';
      default:
        return 'Document';
    }
  }

  @override
  List<Object?> get props => [
    id,
    nom,
    type,
    sourceType,
    fileId,
    extension,
    typeEtablissement,
    parentType,
    parentId,
    annee,
    isActive,
  ];

  @override
  bool get stringify => true;
}
