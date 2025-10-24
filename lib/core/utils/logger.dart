import 'package:flutter/foundation.dart';

/// Utilitaire de logging pour l'application
class AppLogger {
  static const String _prefix = '🔷 DocStore';

  /// Log d'information
  static void info(String message, [dynamic data]) {
    if (kDebugMode) {
      print('$_prefix ℹ️ INFO: $message');
      if (data != null) {
        print('   └─ Data: $data');
      }
    }
  }

  /// Log de debug
  static void debug(String message, [dynamic data]) {
    if (kDebugMode) {
      print('$_prefix 🐛 DEBUG: $message');
      if (data != null) {
        print('   └─ Data: $data');
      }
    }
  }

  /// Log d'avertissement
  static void warning(String message, [dynamic data]) {
    if (kDebugMode) {
      print('$_prefix ⚠️ WARNING: $message');
      if (data != null) {
        print('   └─ Data: $data');
      }
    }
  }

  /// Log d'erreur
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('$_prefix ❌ ERROR: $message');
      if (error != null) {
        print('   └─ Error: $error');
      }
      if (stackTrace != null) {
        print('   └─ StackTrace: $stackTrace');
      }
    }
  }

  /// Log de succès
  static void success(String message, [dynamic data]) {
    if (kDebugMode) {
      print('$_prefix ✅ SUCCESS: $message');
      if (data != null) {
        print('   └─ Data: $data');
      }
    }
  }

  /// Log réseau
  static void network(String message, [dynamic data]) {
    if (kDebugMode) {
      print('$_prefix 🌐 NETWORK: $message');
      if (data != null) {
        print('   └─ Data: $data');
      }
    }
  }

  /// Log cache
  static void cache(String message, [dynamic data]) {
    if (kDebugMode) {
      print('$_prefix 💾 CACHE: $message');
      if (data != null) {
        print('   └─ Data: $data');
      }
    }
  }

  /// Séparateur visuel
  static void separator() {
    if (kDebugMode) {
      print('$_prefix ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }
}
