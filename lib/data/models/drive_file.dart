class DriveFile {
  final String id;
  final String name;
  final String mimeType;
  final String? webViewLink;
  final String? webContentLink;

  DriveFile({
    required this.id,
    required this.name,
    required this.mimeType,
    this.webViewLink,
    this.webContentLink,
  });

  factory DriveFile.fromJson(Map<String, dynamic> json) {
    return DriveFile(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Sans titre',
      mimeType: json['mimeType'] ?? '',
      webViewLink: json['webViewLink'],
      webContentLink: json['webContentLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mimeType': mimeType,
      'webViewLink': webViewLink,
      'webContentLink': webContentLink,
    };
  }
}

