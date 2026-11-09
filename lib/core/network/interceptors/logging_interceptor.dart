import 'package:dio/dio.dart';
import '../../config/env_config.dart';
import '../../services/logger_service.dart';

/// Network logging interceptor that respects EnvConfig.enableLogging
/// Sanitizes sensitive Authorization headers
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (EnvConfig.enableLogging) {
      AppLogger.d('--> ${options.method} ${options.uri}', tag: 'Network');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (EnvConfig.enableLogging) {
      AppLogger.d(
        '<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
        tag: 'Network',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (EnvConfig.enableLogging) {
      AppLogger.e(
        '<-- ERROR ${err.response?.statusCode ?? 'NO_STATUS'} ${err.requestOptions.method} ${err.requestOptions.uri}: ${err.message}',
        tag: 'Network',
      );
    }
    handler.next(err);
  }
}
