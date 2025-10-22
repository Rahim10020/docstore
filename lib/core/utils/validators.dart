class Validators {
  // Valider un ID Appwrite (format standard)
  static bool isValidAppwriteId(String? id) {
    if (id == null || id.isEmpty) return false;
    // ID Appwrite : alphanumérique, longueur typique 20-36 caractères
    return RegExp(r'^[a-zA-Z0-9]{20,36}$').hasMatch(id);
  }

  // Valider une URL
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }

  // Valider un email
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Valider une année (format YYYY)
  static bool isValidYear(String? year) {
    if (year == null || year.isEmpty) return false;
    final parsed = int.tryParse(year);
    if (parsed == null) return false;
    return parsed >= 2000 && parsed <= 2100;
  }
}
