/// Sealed Failure type representing all domain-level error conditions.
///
/// Follows Architecture Contract:
/// "Datasources throw typed exceptions; repositories convert them to a sealed Failure."
sealed class Failure {
  final String? debugMessage;
  const Failure({this.debugMessage});

  @override
  String toString() => '$runtimeType(debugMessage: $debugMessage)';
}

/// Failure caused by network disconnect, timeout, or DNS failure
final class NetworkFailure extends Failure {
  const NetworkFailure({super.debugMessage});
}

/// Failure returned from server API (5xx, unexpected 4xx)
final class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({this.statusCode, super.debugMessage});

  @override
  String toString() => 'ServerFailure(statusCode: $statusCode, debugMessage: $debugMessage)';
}

/// Failure when authentication token is missing or expired (HTTP 401)
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.debugMessage});
}

/// Failure when form or payload fails field-level validations (HTTP 422)
final class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;

  const ValidationFailure(this.fieldErrors, {super.debugMessage});

  @override
  String toString() => 'ValidationFailure(fieldErrors: $fieldErrors, debugMessage: $debugMessage)';
}

/// Failure when local cache / Hive cannot be read or written
final class CacheFailure extends Failure {
  const CacheFailure({super.debugMessage});
}

/// Failure when resource does not exist (HTTP 404)
final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.debugMessage});
}

/// Fallback for unclassified failures
final class UnknownFailure extends Failure {
  const UnknownFailure({super.debugMessage});
}
