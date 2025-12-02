import 'package:equatable/equatable.dart';

enum SemestreType { harmattan, mousson }

class Semestre extends Equatable {
  final String id;
  final String nom;
  final SemestreType type; // Harmattan ou Mousson
  final String anneeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Semestre({
    required this.id,
    required this.nom,
    required this.type,
    required this.anneeId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Semestre.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'harmattan';
    return Semestre(
      id: json['\$id'] as String,
      nom: json['nom'] as String,
      type: typeStr.toLowerCase() == 'mousson'
          ? SemestreType.mousson
          : SemestreType.harmattan,
      anneeId: json['anneeId'] as String,
      createdAt: DateTime.parse(json['\$createdAt'] as String),
      updatedAt: DateTime.parse(json['\$updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'type': type == SemestreType.harmattan ? 'harmattan' : 'mousson',
      'anneeId': anneeId,
    };
  }

  @override
  List<Object?> get props => [id, nom, type, anneeId];
}
