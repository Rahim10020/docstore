enum StatutConcours {
  aVenir('A venir'),
  enCours('En cours'),
  termine('Terminé');

  final String label;
  const StatutConcours(this.label);

  static StatutConcours fromString(String value) {
    return StatutConcours.values.firstWhere(
      (e) =>
          e.label == value || e.name == value.toLowerCase().replaceAll(' ', ''),
      orElse: () => StatutConcours.aVenir,
    );
  }

  String get color {
    switch (this) {
      case StatutConcours.aVenir:
        return '#FFA726'; // Orange
      case StatutConcours.enCours:
        return '#66BB6A'; // Vert
      case StatutConcours.termine:
        return '#9E9E9E'; // Gris
    }
  }

  String get emoji {
    switch (this) {
      case StatutConcours.aVenir:
        return '⏳';
      case StatutConcours.enCours:
        return '🔥';
      case StatutConcours.termine:
        return '✅';
    }
  }
}
