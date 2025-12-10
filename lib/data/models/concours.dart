class Concours {
  final String id;
  final String? nom;
  final String? annee;
  final String? description;
  final List<String> ressources;
  final String? idEcole;
  final List<String> communiques;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Concours({
    required this.id,
    this.nom,
    this.annee,
    this.description,
    this.ressources = const [],
    this.idEcole,
    this.communiques = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Concours.fromMap(Map<String, dynamic> map) {
    return Concours(
      id: map['\$id'] ?? map['id'] ?? '',
      nom: map['nom'],
      annee: map['annee'],
      description: map['description'],
      ressources: map['ressources'] != null 
          ? List<String>.from(map['ressources']) 
          : [],
      idEcole: map['idEcole'],
      communiques: map['communiques'] != null 
          ? List<String>.from(map['communiques']) 
          : [],
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
      if (nom != null) 'nom': nom,
      if (annee != null) 'annee': annee,
      if (description != null) 'description': description,
      'ressources': ressources,
      if (idEcole != null) 'idEcole': idEcole,
      'communiques': communiques,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Concours.fromJson(Map<String, dynamic> json) => Concours.fromMap(json);
}

