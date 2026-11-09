import 'package:dio/dio.dart';
import '../../config/app_constants.dart';
import '../../error/exceptions.dart';
import '../../services/logger_service.dart';
import '../../storage/secure_storage_service.dart';

/// Injects Bearer token and centrally handles HTTP 401 Unauthorized
class AuthInterceptor extends Interceptor {
  final SecureStorageService _storageService;
  final void Function()? onSessionExpired;

  AuthInterceptor(
    this._storageService, {
    this.onSessionExpired,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageService.read(AppConstants.keyAuthToken);
    if (token != null && token.isNotEmpty) {
      options.headers[AppConstants.headerAuthorization] =
          '${AppConstants.headerBearerPrefix}$token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      AppLogger.w('HTTP 401 Unauthorized intercepted: Session expired');
      await _storageService.delete(AppConstants.keyAuthToken);
      onSessionExpired?.call();
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          error: const UnauthorizedException('Your session has expired. Please sign in again.'),
          type: err.type,
        ),
      );
      return;
    }
    handler.next(err);
  }
}
