import 'exceptions.dart';
import 'failures.dart';

/// Maps thrown typed exceptions (from datasources) to sealed Failures (for repositories)
abstract final class ExceptionMapper {
  static Failure map(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      switch (error) {
        case NetworkException():
          return NetworkFailure(debugMessage: error.message);
        case ServerException():
          return ServerFailure(
            statusCode: error.statusCode,
            debugMessage: error.message,
          );
        case UnauthorizedException():
          return UnauthorizedFailure(debugMessage: error.message);
        case ValidationException():
          return ValidationFailure(
            error.fieldErrors,
            debugMessage: error.message,
          );
        case CacheException():
          return CacheFailure(debugMessage: error.message);
        case NotFoundException():
          return NotFoundFailure(debugMessage: error.message);
        case UnknownException():
          return UnknownFailure(debugMessage: error.message);
      }
    }

    return UnknownFailure(debugMessage: error.toString());
  }
}
