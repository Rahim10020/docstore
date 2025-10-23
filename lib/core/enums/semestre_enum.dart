enum SemestreEnum {
  harmattan('Harmattan'),
  mousson('Mousson');

  final String label;
  const SemestreEnum(this.label);

  static SemestreEnum? fromString(String? value) {
    if (value == null || value.isEmpty) return null;

    return SemestreEnum.values.firstWhere(
      (e) => e.label == value || e.name == value.toLowerCase(),
      orElse: () => SemestreEnum.harmattan,
    );
  }

  String get emoji {
    switch (this) {
      case SemestreEnum.harmattan:
        return '🌤️'; // Saison sèche
      case SemestreEnum.mousson:
        return '🌧️'; // Saison des pluies
    }
  }
}
