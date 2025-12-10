class Filiere {
  final String id;
  final String nom;
  final String? description;
  final String parcours;
  final String idEcole;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Filiere({
    required this.id,
    required this.nom,
    this.description,
    required this.parcours,
    required this.idEcole,
    this.createdAt,
    this.updatedAt,
  });

  factory Filiere.fromMap(Map<String, dynamic> map) {
    return Filiere(
      id: map['\$id'] ?? map['id'] ?? '',
      nom: map['nom'] ?? '',
      description: map['description'],
      parcours: map['parcours'] ?? '',
      idEcole: map['idEcole'] ?? '',
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
      'parcours': parcours,
      'idEcole': idEcole,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Filiere.fromJson(Map<String, dynamic> json) => Filiere.fromMap(json);
}

