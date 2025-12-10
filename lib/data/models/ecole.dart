class Ecole {
  final String id;
  final String nom;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Ecole({
    required this.id,
    required this.nom,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Ecole.fromMap(Map<String, dynamic> map) {
    return Ecole(
      id: map['\$id'] ?? map['id'] ?? '',
      nom: map['nom'] ?? '',
      description: map['description'],
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
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Ecole.fromJson(Map<String, dynamic> json) => Ecole.fromMap(json);
}

