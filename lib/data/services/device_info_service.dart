import 'package:device_info_plus/device_info_plus.dart';
import 'package:logger/logger.dart';

class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  final Logger _logger = Logger();

  factory DeviceInfoService() {
    return _instance;
  }

  DeviceInfoService._internal();

  Future<Map<String, dynamic>> getAndroidDeviceInfo() async {
    try {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      return {
        'version': androidInfo.version.sdkInt.toString(),
        'model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'device': androidInfo.device,
        'product': androidInfo.product,
      };
    } catch (e, stackTrace) {
      _logger.e(
        'Error getting Android device info: $e',
        stackTrace: stackTrace,
      );
      return {
        'version': 'unknown',
        'model': 'unknown',
        'manufacturer': 'unknown',
        'device': 'unknown',
        'product': 'unknown',
      };
    }
  }

  Future<Map<String, dynamic>> getIosDeviceInfo() async {
    try {
      final iosInfo = await _deviceInfoPlugin.iosInfo;
      return {
        'systemVersion': iosInfo.systemVersion,
        'model': iosInfo.model,
        'systemName': iosInfo.systemName,
      };
    } catch (e, stackTrace) {
      _logger.e('Error getting iOS device info: $e', stackTrace: stackTrace);
      return {
        'systemVersion': 'unknown',
        'model': 'unknown',
        'systemName': 'unknown',
      };
    }
  }
}
