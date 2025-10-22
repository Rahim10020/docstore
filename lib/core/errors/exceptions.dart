class ServerException implements Exception {
  final String message;
  final int? code;

  ServerException(this.message, {this.code});

  @override
  String toString() =>
      'ServerException: $message ${code != null ? '(Code: $code)' : ''}';
}

class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class FileException implements Exception {
  final String message;

  FileException(this.message);

  @override
  String toString() => 'FileException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;

  ValidationException(this.message, {this.errors});

  @override
  String toString() => 'ValidationException: $message';
}
