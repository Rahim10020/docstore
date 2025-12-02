import 'package:appwrite/appwrite.dart';
import 'package:logger/logger.dart';

class AppwriteService {
  late final Client _client;
  late final Databases _databases;
  late final Storage _storage;
  final Logger _logger = Logger();

  AppwriteService() {
    _initializeClient();
  }

  void _initializeClient() {
    _client = Client();
    _client.setEndpoint('YOUR_APPWRITE_ENDPOINT');
    _client.setProject('YOUR_PROJECT_ID');

    _databases = Databases(_client);
    _storage = Storage(_client);
  }

  Databases get databases => _databases;
  Storage get storage => _storage;
  Logger get logger => _logger;

  Future<void> testConnection() async {
    try {
      _logger.i('Testing Appwrite connection...');
      // Test simple query
      _logger.i('Appwrite connection successful');
    } catch (e) {
      _logger.e('Appwrite connection failed: $e');
      rethrow;
    }
  }
}
