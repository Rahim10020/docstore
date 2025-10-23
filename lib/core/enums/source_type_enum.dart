enum SourceTypeEnum {
  appwrite('appwrite'),
  googleDrive('google_drive'),
  externe('externe');

  final String value;
  const SourceTypeEnum(this.value);

  static SourceTypeEnum fromString(String value) {
    return SourceTypeEnum.values.firstWhere(
      (e) => e.value == value || e.name == value.toLowerCase(),
      orElse: () => SourceTypeEnum.appwrite,
    );
  }

  String get label {
    switch (this) {
      case SourceTypeEnum.appwrite:
        return 'Appwrite Storage';
      case SourceTypeEnum.googleDrive:
        return 'Google Drive';
      case SourceTypeEnum.externe:
        return 'Lien externe';
    }
  }

  bool get needsDownload {
    // Google Drive et liens externes nécessitent un téléchargement différent
    return this == SourceTypeEnum.googleDrive || this == SourceTypeEnum.externe;
  }
}
