class Department {
  final String id;
  final String name;
  final List<String> levels; // ['L1', 'L2'...]
  final Map<String, String>? courseFolders; // Map<courseName, driveFolderId>

  Department({
    required this.id,
    required this.name,
    required this.levels,
    this.courseFolders,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'levels': levels,
      'courseFolders': courseFolders,
    };
  }
}

