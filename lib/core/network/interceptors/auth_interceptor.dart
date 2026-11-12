import 'package:dio/dio.dart';
import '../../config/app_constants.dart';
import '../../storage/secure_storage_service.dart';
import '../api_endpoints.dart';
import '../api_response.dart';

/// Attaches Bearer access token to authenticated requests and handles
/// transparent single-flight refresh token rotation on HTTP 401 responses.
class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService _storageService;
  final String? refreshBaseUrl;
  final void Function()? onSessionExpired;
  final Dio? _overrideRefreshDio;

  AuthInterceptor(
    this._storageService, {
    this.refreshBaseUrl,
    this.onSessionExpired,
    Dio? refreshDio,
  }) : _overrideRefreshDio = refreshDio;

  bool _isAuthPublicEndpoint(String path) {
    return path.endsWith(ApiEndpoints.login) ||
        path.endsWith(ApiEndpoints.refresh) ||
        path.endsWith(ApiEndpoints.forgotPassword);
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAuthPublicEndpoint(options.path)) {
      final token = await _storageService.read(AppConstants.keyAuthToken);
      if (token != null && token.isNotEmpty) {
        options.headers[AppConstants.headerAuthorization] =
            '${AppConstants.headerBearerPrefix}$token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final req = err.requestOptions;

    if (status == 401 &&
        !_isAuthPublicEndpoint(req.path) &&
        req.extra['_retriedAfterRefresh'] != true) {
      final sentAuth = req.headers[AppConstants.headerAuthorization]?.toString();
      final currentAccess =
          await _storageService.read(AppConstants.keyAuthToken);

      // Another queued request already refreshed the token: replay cleanly.
      if (currentAccess != null &&
          currentAccess.isNotEmpty &&
          sentAuth != '${AppConstants.headerBearerPrefix}$currentAccess') {
        try {
          final retried = await _retryWithToken(req, currentAccess);
          return handler.resolve(retried);
        } on DioException catch (retryErr) {
          return handler.next(retryErr);
        }
      }

      final refreshToken =
          await _storageService.read(AppConstants.keyRefreshToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final newAccessToken = await _performRefresh(
            refreshToken: refreshToken,
            baseUrl: req.baseUrl.isNotEmpty ? req.baseUrl : (refreshBaseUrl ?? ''),
            acceptLanguage:
                req.headers[AppConstants.headerAcceptLanguage]?.toString(),
          );
          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            final retried = await _retryWithToken(req, newAccessToken);
            return handler.resolve(retried);
          }
        } catch (_) {
          // Fall through to clearing session and rejecting.
        }
      }

      await _clearSessionAndNotify();
    } else if (status == 401 && _isAuthPublicEndpoint(req.path) &&
        req.path.endsWith(ApiEndpoints.refresh)) {
      await _clearSessionAndNotify();
    }

    handler.next(err);
  }

  Future<String?> _performRefresh({
    required String refreshToken,
    required String baseUrl,
    String? acceptLanguage,
  }) async {
    final client = _overrideRefreshDio ??
        Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: AppConstants.connectTimeout,
            receiveTimeout: AppConstants.receiveTimeout,
            headers: {
              AppConstants.headerContentType: AppConstants.headerContentTypeJson,
              AppConstants.headerAccept: AppConstants.headerContentTypeJson,
              AppConstants.headerAcceptLanguage: ?acceptLanguage,
            },
          ),
        );

    final response = await client.post<dynamic>(
      ApiEndpoints.refresh,
      data: <String, dynamic>{'refreshToken': refreshToken},
    );

    final data = ApiResponseParser.unwrapMap(response.data);
    final newAccess = data['accessToken']?.toString();
    final newRefresh = data['refreshToken']?.toString();

    if (newAccess == null || newAccess.isEmpty) {
      return null;
    }

    await _storageService.write(AppConstants.keyAuthToken, newAccess);
    if (newRefresh != null && newRefresh.isNotEmpty) {
      await _storageService.write(AppConstants.keyRefreshToken, newRefresh);
    }
    return newAccess;
  }

  Future<Response<dynamic>> _retryWithToken(
    RequestOptions failedRequest,
    String accessToken,
  ) {
    final client = _overrideRefreshDio ??
        Dio(
          BaseOptions(
            baseUrl: failedRequest.baseUrl,
            connectTimeout: failedRequest.connectTimeout,
            receiveTimeout: failedRequest.receiveTimeout,
          ),
        );

    final headers = Map<String, dynamic>.from(failedRequest.headers);
    headers[AppConstants.headerAuthorization] =
        '${AppConstants.headerBearerPrefix}$accessToken';

    final extra = Map<String, dynamic>.from(failedRequest.extra);
    extra['_retriedAfterRefresh'] = true;

    return client.request<dynamic>(
      failedRequest.path,
      data: failedRequest.data,
      queryParameters: failedRequest.queryParameters,
      options: Options(
        method: failedRequest.method,
        headers: headers,
        responseType: failedRequest.responseType,
        contentType: failedRequest.contentType,
        extra: extra,
      ),
    );
  }

  Future<void> _clearSessionAndNotify() async {
    await _storageService.delete(AppConstants.keyAuthToken);
    await _storageService.delete(AppConstants.keyRefreshToken);
    onSessionExpired?.call();
  }
}
