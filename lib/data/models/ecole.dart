import 'package:equatable/equatable.dart';

class Ecole extends Equatable {
  final String id;
  final String title; // Changed from nom to match DB
  final String description;
  final List<String> fileIds; // Changed to match DB column name
  final DateTime createdAt;
  final DateTime updatedAt;

  const Ecole({
    required this.id,
    required this.title,
    required this.description,
    this.fileIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ecole.fromJson(Map<String, dynamic> json) {
    return Ecole(
      id: json['\$id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      fileIds:
          (json['fileIds'] as List?)?.map((r) => r.toString()).toList() ?? [],
      createdAt: json['\$createdAt'] != null
          ? DateTime.parse(json['\$createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['\$updatedAt'] != null
          ? DateTime.parse(json['\$updatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description, 'fileIds': fileIds};
  }

  @override
  List<Object?> get props => [id, title, description];
}
