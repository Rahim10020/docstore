enum TypeLicence {
  licencePro('Licence Pro'),
  licenceFond('Licence Fond.'),
  departement('Département'),
  parcours('Parcours');

  final String label;
  const TypeLicence(this.label);

  static TypeLicence fromString(String value) {
    return TypeLicence.values.firstWhere(
      (e) => e.name == value || e.label == value,
      orElse: () => TypeLicence.departement,
    );
  }
}
