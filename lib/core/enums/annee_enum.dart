enum AnneeEnum {
  annee1('Année 1'),
  annee2('Année 2'),
  annee3('Année 3'),
  annee4('Année 4'),
  annee5('Année 5'),
  tronc_commun('Tronc Commun'),
  master1('Master 1'),
  master2('Master 2');

  final String label;
  const AnneeEnum(this.label);

  static AnneeEnum fromString(String value) {
    return AnneeEnum.values.firstWhere(
      (e) =>
          e.label == value ||
          e.name == value.toLowerCase().replaceAll(' ', '_'),
      orElse: () => AnneeEnum.annee1,
    );
  }

  int? get numero {
    switch (this) {
      case AnneeEnum.annee1:
        return 1;
      case AnneeEnum.annee2:
        return 2;
      case AnneeEnum.annee3:
        return 3;
      case AnneeEnum.annee4:
        return 4;
      case AnneeEnum.annee5:
        return 5;
      case AnneeEnum.master1:
        return 6;
      case AnneeEnum.master2:
        return 7;
      default:
        return null;
    }
  }
}
