/// Définition des noms de routes de l'application
class AppRoutes {
  // Route initiale
  static const String splash = '/';
  static const String home = '/home';

  // Établissements
  static const String ecoles = '/ecoles';
  static const String ecoleDetail = '/ecole/:id';

  // Filières
  static const String filieres = '/filieres/:ecoleId';
  static const String filiereDetail = '/filiere/:id';

  // UEs
  static const String ues = '/ues/:filiereId';
  static const String ueDetail = '/ue/:id';

  // Concours
  static const String concours = '/concours';
  static const String concoursDetail = '/concours/:id';
  static const String concoursByEcole = '/concours/ecole/:ecoleId';

  // Fichiers
  static const String pdfViewer = '/pdf-viewer';

  // Recherche
  static const String search = '/search';

  // Paramètres
  static const String settings = '/settings';

  // Helpers pour construire les routes avec paramètres
  static String getEcoleDetailRoute(String id) => '/ecole/$id';
  static String getFilieresRoute(String ecoleId) => '/filieres/$ecoleId';
  static String getFiliereDetailRoute(String id) => '/filiere/$id';
  static String getUesRoute(String filiereId) => '/ues/$filiereId';
  static String getUeDetailRoute(String id) => '/ue/$id';
  static String getConcoursDetailRoute(String id) => '/concours/$id';
  static String getConcoursByEcoleRoute(String ecoleId) =>
      '/concours/ecole/$ecoleId';
}
