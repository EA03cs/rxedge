import 'package:dio/dio.dart';
import '../../error/exceptions.dart';

/// Maps DioExceptions to strongly-typed AppExceptions
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        exception = const NetworkException('Network connection timed out or is unavailable');
        break;

      case DioExceptionType.badResponse:
        final response = err.response;
        final statusCode = response?.statusCode;
        final data = response?.data;

        if (statusCode == 401) {
          exception = const UnauthorizedException('Authentication credentials missing or expired');
        } else if (statusCode == 404) {
          exception = const NotFoundException('Requested resource does not exist');
        } else if (statusCode == 422) {
          final fieldErrors = <String, String>{};
          if (data is Map<String, dynamic> && data['errors'] is Map) {
            final errs = data['errors'] as Map;
            errs.forEach((k, v) => fieldErrors[k.toString()] = v.toString());
          }
          exception = ValidationException(fieldErrors, 'Validation failed');
        } else {
          final msg = (data is Map && data['message'] != null)
              ? data['message'].toString()
              : 'Server responded with status $statusCode';
          exception = ServerException(
            msg,
            statusCode: statusCode,
            data: data is Map<String, dynamic> ? data : null,
          );
        }
        break;

      case DioExceptionType.cancel:
        exception = const UnknownException('Request was cancelled');
        break;

      case DioExceptionType.badCertificate:
        exception = const NetworkException('SSL/TLS Certificate verification failed');
        break;

      case DioExceptionType.unknown:
        if (err.error is AppException) {
          exception = err.error as AppException;
        } else {
          exception = UnknownException(err.message ?? 'Unknown network error', err.error);
        }
        break;
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        error: exception,
        type: err.type,
      ),
    );
  }
}
