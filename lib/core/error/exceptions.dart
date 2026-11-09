/// Base typed exception class for datasources
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when an HTTP server error occurs (5xx, 4xx other than 401/404/422)
final class ServerException extends AppException {
  final int? statusCode;
  final Map<String, dynamic>? data;

  const ServerException(super.message, {this.statusCode, this.data});
}

/// Thrown when device has no internet or socket connection fails
final class NetworkException extends AppException {
  const NetworkException([super.message = 'Network connection unavailable']);
}

/// Thrown on HTTP 401 unauthorized or session expiry
final class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expired or unauthenticated']);
}

/// Thrown on HTTP 422 or validation failure with specific field errors
final class ValidationException extends AppException {
  final Map<String, String> fieldErrors;

  const ValidationException(
    this.fieldErrors, [
    super.message = 'Validation failed',
  ]);
}

/// Thrown when local storage / cache read or write fails
final class CacheException extends AppException {
  const CacheException([super.message = 'Cache operation failed']);
}

/// Thrown on HTTP 404 or record not found
final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Requested resource not found']);
}

/// Thrown for any unclassified or runtime parsing errors
final class UnknownException extends AppException {
  final Object? cause;
  const UnknownException([super.message = 'An unexpected error occurred', this.cause]);
}
