import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  static ConnectivityService get to => Get.find();

  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;

  Future<ConnectivityService> init() async {
    // Vérifier la connexion initiale
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result.first);

    // Écouter les changements
    _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results.first);
    });

    return this;
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    isConnected.value = result != ConnectivityResult.none;
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result.first != ConnectivityResult.none;
  }
}
