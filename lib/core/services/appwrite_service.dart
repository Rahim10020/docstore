import 'package:appwrite/appwrite.dart';
import 'package:docstore/core/constants/api_constants.dart';
import 'package:get/get.dart';

class AppwriteService extends GetxService {
  late final Client _client;
  late final Databases databases;
  late final Storage storage;

  // Singleton pattern avec GetX
  static AppwriteService get to => Get.find();

  Future<AppwriteService> init() async {
    _client = Client()
      ..setEndpoint(ApiConstants.endpoint)
      ..setProject(ApiConstants.projectId);

    databases = Databases(_client);
    storage = Storage(_client);

    return this;
  }

  Client get client => _client;

  // Helper pour gérer les erreurs Appwrite
  String handleAppwriteError(AppwriteException e) {
    switch (e.code) {
      case 401:
        return 'Non autorisé. Veuillez vous reconnecter.';
      case 404:
        return 'Ressource non trouvée.';
      case 429:
        return 'Trop de requêtes. Veuillez réessayer plus tard.';
      case 500:
        return 'Erreur serveur. Veuillez réessayer.';
      default:
        return e.message ?? 'Une erreur est survenue.';
    }
  }
}
