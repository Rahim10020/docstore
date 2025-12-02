import 'package:equatable/equatable.dart';

class Concours extends Equatable {
  final String id;
  final String nom;
  final String description;
  final int annee;
  final String ecoleId;
  final String? communiquePdfUrl;
  final String? communiquePdfNom;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Concours({
    required this.id,
    required this.nom,
    required this.description,
    required this.annee,
    required this.ecoleId,
    this.communiquePdfUrl,
    this.communiquePdfNom,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Concours.fromJson(Map<String, dynamic> json) {
    return Concours(
      id: json['\$id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String? ?? '',
      annee: json['annee'] as int,
      ecoleId: json['ecoleId'] as String,
      communiquePdfUrl: json['communiquePdfUrl'] as String?,
      communiquePdfNom: json['communiquePdfNom'] as String?,
      createdAt: DateTime.parse(json['\$createdAt'] as String),
      updatedAt: DateTime.parse(json['\$updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'description': description,
      'annee': annee,
      'ecoleId': ecoleId,
      'communiquePdfUrl': communiquePdfUrl,
      'communiquePdfNom': communiquePdfNom,
    };
  }

  bool get hasCommunique =>
      communiquePdfUrl != null && communiquePdfUrl!.isNotEmpty;

  @override
  List<Object?> get props => [id, nom, annee, ecoleId];
}
