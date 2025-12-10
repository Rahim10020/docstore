class Ue {
  final String id;
  final String nom;
  final String? description;
  final String? anneeEnseignement;
  final List<String> ressources;
  final String idFiliere;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Ue({
    required this.id,
    required this.nom,
    this.description,
    this.anneeEnseignement,
    this.ressources = const [],
    required this.idFiliere,
    this.createdAt,
    this.updatedAt,
  });

  factory Ue.fromMap(Map<String, dynamic> map) {
    return Ue(
      id: map['\$id'] ?? map['id'] ?? '',
      nom: map['nom'] ?? '',
      description: map['description'],
      anneeEnseignement: map['anneeEnseignement'],
      ressources: map['ressources'] != null 
          ? List<String>.from(map['ressources']) 
          : [],
      idFiliere: map['idFiliere'] ?? '',
      createdAt: map['\$createdAt'] != null 
          ? DateTime.parse(map['\$createdAt']) 
          : null,
      updatedAt: map['\$updatedAt'] != null 
          ? DateTime.parse(map['\$updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      if (description != null) 'description': description,
      if (anneeEnseignement != null) 'anneeEnseignement': anneeEnseignement,
      'ressources': ressources,
      'idFiliere': idFiliere,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Ue.fromJson(Map<String, dynamic> json) => Ue.fromMap(json);
}

