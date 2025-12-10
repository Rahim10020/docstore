import 'department.dart';

class School {
  final String id;
  final String name;
  final String shortName;
  final String imageAsset; // Chemin local assets/images/...
  final List<Department> departments;

  School({
    required this.id,
    required this.name,
    required this.shortName,
    required this.imageAsset,
    required this.departments,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'imageAsset': imageAsset,
      'departments': departments.map((d) => d.toJson()).toList(),
    };
  }
}

