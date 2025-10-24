import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../utils/logger.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // État de la connexion (observable)
  final isConnected = true.obs;
  final connectionType = ConnectivityResult.none.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeConnectivity();
    _listenToConnectivityChanges();
  }

  /// Initialise l'état de la connexion au démarrage
  Future<void> _initializeConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      AppLogger.error('Erreur vérification connectivité initiale', e);
      isConnected.value = false;
    }
  }

  /// Écoute les changements de connectivité
  void _listenToConnectivityChanges() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        _updateConnectionStatus(results);
      },
      onError: (error) {
        AppLogger.error('Erreur stream connectivité', error);
        isConnected.value = false;
      },
    );
  }

  /// Met à jour le statut de connexion
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      isConnected.value = false;
      connectionType.value = ConnectivityResult.none;
      AppLogger.warning('Connexion perdue');
    } else {
      isConnected.value = true;
      connectionType.value = results.first;
      AppLogger.info('Connecté via ${results.first.name}');
    }
  }

  /// Vérifie manuellement la connexion
  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
      return isConnected.value;
    } catch (e) {
      AppLogger.error('Erreur checkConnection', e);
      return false;
    }
  }

  /// Vérifie si connecté via WiFi
  bool get isWifi => connectionType.value == ConnectivityResult.wifi;

  /// Vérifie si connecté via données mobiles
  bool get isMobile =>
      connectionType.value == ConnectivityResult.mobile ||
      connectionType.value == ConnectivityResult.other;

  /// Vérifie si connecté via ethernet
  bool get isEthernet => connectionType.value == ConnectivityResult.ethernet;

  /// Nom lisible du type de connexion
  String get connectionTypeName {
    switch (connectionType.value) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Données mobiles';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.none:
        return 'Aucune connexion';
      default:
        return 'Autre';
    }
  }

  /// Exécute une action uniquement si connecté
  Future<T?> whenConnected<T>(Future<T> Function() action) async {
    if (!isConnected.value) {
      AppLogger.warning('Action annulée: Pas de connexion internet');
      Get.snackbar(
        'Pas de connexion',
        'Veuillez vérifier votre connexion internet',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    try {
      return await action();
    } catch (e) {
      AppLogger.error('Erreur lors de l\'action connectée', e);
      rethrow;
    }
  }

  /// Attend qu'une connexion soit disponible (avec timeout)
  Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (isConnected.value) return true;

    try {
      await isConnected.stream
          .firstWhere((connected) => connected)
          .timeout(timeout);
      return true;
    } on TimeoutException {
      AppLogger.warning('Timeout en attendant la connexion');
      return false;
    } catch (e) {
      AppLogger.error('Erreur waitForConnection', e);
      return false;
    }
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
