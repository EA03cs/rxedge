import 'package:dio/dio.dart';
import '../services/logger_service.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Translates data/network exceptions into domain [Failure] types.
abstract final class ExceptionMapper {
  static Failure map(Object error, [StackTrace? stackTrace]) {
    AppLogger.e(
      'Mapping exception: $error',
      tag: 'ExceptionMapper',
      error: error,
      stackTrace: stackTrace,
    );

    if (error is Failure) {
      return error;
    }

    if (error is DioException) {
      final inner = error.error;
      if (inner is AppException) {
        return _mapAppException(inner);
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return NetworkFailure(debugMessage: error.message);
      }
      return ServerFailure(
        statusCode: error.response?.statusCode,
        debugMessage: error.message,
      );
    }

    if (error is AppException) {
      return _mapAppException(error);
    }

    return UnknownFailure(debugMessage: error.toString());
  }

  static Failure _mapAppException(AppException exception) {
    return switch (exception) {
      NetworkException(:final message) => NetworkFailure(debugMessage: message),
      UnauthorizedException(:final message) =>
        UnauthorizedFailure(debugMessage: message),
      NotFoundException(:final message) => NotFoundFailure(debugMessage: message),
      ValidationException(:final fieldErrors, :final message) =>
        ValidationFailure(fieldErrors, debugMessage: message),
      CacheException(:final message) => CacheFailure(debugMessage: message),
      ServerException(:final statusCode, :final message) => ServerFailure(
          statusCode: statusCode,
          debugMessage: message,
        ),
      UnknownException(:final message) => UnknownFailure(debugMessage: message),
    };
  }
}
