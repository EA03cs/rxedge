import 'package:dio/dio.dart';
import '../../error/exceptions.dart';
import '../api_response.dart';

/// Translates raw [DioException] transport and backend API responses
/// (matching `D:\Backend\rxedge\src\Utils\Response.js` and `Validation.js`)
/// into typed [AppException] instances attached to `err.error`.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final AppException mappedException = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        const NetworkException(),
      DioExceptionType.badResponse => _mapBadResponse(err),
      DioExceptionType.cancel => const NetworkException('Request cancelled'),
      DioExceptionType.badCertificate ||
      DioExceptionType.unknown ||
      _ =>
        err.error is AppException
            ? err.error! as AppException
            : NetworkException(err.message ?? 'Network communication error'),
    };

    handler.next(err.copyWith(error: mappedException));
  }

  AppException _mapBadResponse(DioException err) {
    final statusCode = err.response?.statusCode;
    final body = err.response?.data;
    final serverMessage =
        ApiResponseParser.extractErrorMessage(body) ?? err.message ?? 'Server error';
    final Map<String, dynamic>? bodyMap =
        body is Map ? Map<String, dynamic>.from(body) : null;

    if (statusCode == 401) {
      return UnauthorizedException(serverMessage);
    }

    if (statusCode == 404) {
      return NotFoundException(serverMessage);
    }

    // Backend Joi `Validation.js` returns HTTP 400 with `{ errors: [...] }`
    // and some endpoints use HTTP 422.
    if (statusCode == 422 ||
        (statusCode == 400 &&
            bodyMap != null &&
            (bodyMap['errors'] != null ||
                (bodyMap['error'] is Map &&
                    bodyMap['error']['code'] == 'VALIDATION_ERROR')))) {
      final fields = ApiResponseParser.extractFieldErrors(body);
      return ValidationException(fields, serverMessage);
    }

    return ServerException(
      serverMessage,
      statusCode: statusCode,
      data: bodyMap,
    );
  }
}
