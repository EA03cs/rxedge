import 'package:dio/dio.dart';

/// Retries HTTP 429 (Too Many Requests) responses once after respecting the
/// `Retry-After` response header (integer seconds clamped to 10s, defaulting to 2s).
class RateLimitInterceptor extends Interceptor {
  static const String retriedExtraKey = 'retried_429';
  static const int defaultRetrySeconds = 2;
  static const int maxRetrySeconds = 10;

  final Dio _dio;
  final Future<void> Function(Duration duration) _delay;

  RateLimitInterceptor(
    this._dio, {
    Future<void> Function(Duration duration)? delay,
  }) : _delay = delay ?? Future<void>.delayed;

  /// Parses `Retry-After` as integer seconds clamped to `0..10` seconds.
  /// Defaults to [defaultRetrySeconds] (2s) if missing, empty, or non-integer.
  static Duration parseRetryAfter(Headers? headers) {
    final raw = headers?.value('retry-after')?.trim();
    if (raw == null || raw.isEmpty) {
      return const Duration(seconds: defaultRetrySeconds);
    }
    final parsed = int.tryParse(raw);
    if (parsed == null || parsed < 0) {
      return const Duration(seconds: defaultRetrySeconds);
    }
    final clamped = parsed > maxRetrySeconds ? maxRetrySeconds : parsed;
    return Duration(seconds: clamped);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final req = err.requestOptions;

    if (status != 429 || req.extra[retriedExtraKey] == true) {
      handler.next(err);
      return;
    }

    final retryDelay = parseRetryAfter(err.response?.headers);
    await _delay(retryDelay);

    final updatedExtra = Map<String, dynamic>.from(req.extra);
    updatedExtra[retriedExtraKey] = true;

    final retryOptions = req.copyWith(extra: updatedExtra);

    try {
      final response = await _dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryErr) {
      handler.next(retryErr);
    }
  }
}
