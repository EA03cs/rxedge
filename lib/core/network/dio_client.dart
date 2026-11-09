import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_constants.dart';
import '../config/env_config.dart';
import '../storage/secure_storage_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Configured Dio Client instance provider
final dioClientProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);

  final options = BaseOptions(
    baseUrl: EnvConfig.baseUrl,
    connectTimeout: EnvConfig.connectTimeout,
    receiveTimeout: EnvConfig.receiveTimeout,
    headers: {
      AppConstants.headerContentType: AppConstants.headerContentTypeJson,
      AppConstants.headerAccept: AppConstants.headerContentTypeJson,
    },
  );

  final dio = Dio(options);

  dio.interceptors.addAll([
    AuthInterceptor(secureStorage),
    LoggingInterceptor(),
    ErrorInterceptor(),
  ]);

  return dio;
});
