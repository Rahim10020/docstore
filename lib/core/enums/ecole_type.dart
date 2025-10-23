enum EcoleType {
  ecole,
  faculte,
  institut;

  String get label {
    switch (this) {
      case EcoleType.ecole:
        return 'École';
      case EcoleType.faculte:
        return 'Faculté';
      case EcoleType.institut:
        return 'Institut';
    }
  }

  String get icon {
    switch (this) {
      case EcoleType.ecole:
        return '🏫';
      case EcoleType.faculte:
        return '🎓';
      case EcoleType.institut:
        return '🔬';
    }
  }

  static EcoleType fromString(String value) {
    return EcoleType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => EcoleType.ecole,
    );
  }
}
