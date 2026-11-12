import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxedge/core/config/app_constants.dart';
import 'package:rxedge/core/localization/app_locale_provider.dart';
import 'package:rxedge/core/network/api_endpoints.dart';
import 'package:rxedge/core/network/api_response.dart';
import 'package:rxedge/core/network/interceptors/auth_interceptor.dart';
import 'package:rxedge/core/network/interceptors/language_interceptor.dart';
import 'package:rxedge/core/network/url_resolver.dart';
import 'package:rxedge/core/storage/local_cache_service.dart';
import 'package:rxedge/core/storage/offline_queue_service.dart';
import 'package:rxedge/core/storage/secure_storage_service.dart';

class _InMemorySecureStorage extends SecureStorageService {
  final Map<String, String> store = <String, String>{};

  @override
  Future<String?> read(String key) async => store[key];

  @override
  Future<void> write(String key, String value) async {
    store[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    store.remove(key);
  }

  @override
  Future<void> clearAll() async {
    store.clear();
  }
}

typedef _AdapterHandler = Future<ResponseBody> Function(
  RequestOptions options,
  Stream<Uint8List>? requestStream,
  Future<void>? cancelFuture,
);

class _FakeHttpClientAdapter implements HttpClientAdapter {
  final _AdapterHandler handler;
  _FakeHttpClientAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options, requestStream, cancelFuture);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(Map<String, dynamic> body, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>['application/json'],
    },
  );
}

void main() {
  group('ApiResponseParser', () {
    test('unwrapMap extracts data map when envelope is present', () {
      final result = ApiResponseParser.unwrapMap(<String, dynamic>{
        'success': true,
        'status': 200,
        'data': <String, dynamic>{'id': '123', 'title': 'Clinical Overview'},
      });

      expect(result['id'], '123');
      expect(result['title'], 'Clinical Overview');
    });

    test('unwrapList supports direct list and paginated nested items', () {
      final direct = ApiResponseParser.unwrapList(<String, dynamic>{
        'success': true,
        'data': <dynamic>[
          <String, dynamic>{'id': '1'},
          <String, dynamic>{'id': '2'},
        ],
      });
      final nested = ApiResponseParser.unwrapList(<String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'items': <dynamic>[
            <String, dynamic>{'id': 'n1'},
          ],
          'total': 1,
        },
      });

      expect(direct.map((e) => e['id']), ['1', '2']);
      expect(nested.map((e) => e['id']), ['n1']);
    });

    test('extractErrorMessage prioritizes Joi errors, nested error, then message', () {
      expect(
        ApiResponseParser.extractErrorMessage(<String, dynamic>{
          'message': 'Validation failed',
          'errors': <String>['"email" must be a valid email'],
        }),
        '"email" must be a valid email',
      );

      expect(
        ApiResponseParser.extractErrorMessage(<String, dynamic>{
          'message': 'Top level',
          'error': <String, dynamic>{'code': 'UNAUTHORIZED', 'message': 'Invalid token'},
        }),
        'Invalid token',
      );

      expect(
        ApiResponseParser.extractErrorMessage(<String, dynamic>{'message': 'Server busy'}),
        'Server busy',
      );
    });
  });

  group('UrlResolver', () {
    test('strips /api/v1 when resolving relative storage URLs', () {
      expect(
        UrlResolver.originFromApiBaseUrl('http://localhost:4010/api/v1'),
        'http://localhost:4010',
      );
      expect(
        UrlResolver.resolve(
          '/uploads/materials/cardura.pdf',
          apiBaseUrl: 'http://10.0.2.2:4010/api/v1',
        ),
        'http://10.0.2.2:4010/uploads/materials/cardura.pdf',
      );
      expect(
        UrlResolver.resolve(
          'https://cdn.example.com/asset.png',
          apiBaseUrl: 'http://10.0.2.2:4010/api/v1',
        ),
        'https://cdn.example.com/asset.png',
      );
      expect(UrlResolver.resolve('   '), isNull);
    });
  });

  group('LanguageInterceptor', () {
    test('defaults Accept-Language to ar and follows localeProvider updates', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      String? capturedHeader;
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:4010/api/v1'))
        ..httpClientAdapter = _FakeHttpClientAdapter((options, _, _) async {
          capturedHeader =
              options.headers[AppConstants.headerAcceptLanguage]?.toString();
          return _jsonBody(
            <String, dynamic>{'success': true, 'data': <String, dynamic>{}},
            200,
          );
        });

      final provider = Provider<LanguageInterceptor>((ref) => LanguageInterceptor(ref));
      dio.interceptors.add(container.read(provider));

      await dio.get<dynamic>('/home/dashboard');
      expect(capturedHeader, 'ar');

      container.read(localeProvider.notifier).state = const Locale('en');
      await dio.get<dynamic>('/home/dashboard');
      expect(capturedHeader, 'en');
    });
  });

  group('AuthInterceptor', () {
    test('attaches Bearer token and rotates tokens seamlessly on 401', () async {
      final storage = _InMemorySecureStorage();
      await storage.write(AppConstants.keyAuthToken, 'expired_access');
      await storage.write(AppConstants.keyRefreshToken, 'valid_refresh');

      int protectedAttempts = 0;
      String? refreshedWithToken;

      final refreshDio = Dio(BaseOptions(baseUrl: 'http://localhost:4010/api/v1'))
        ..httpClientAdapter = _FakeHttpClientAdapter((options, _, _) async {
          if (options.path.endsWith(ApiEndpoints.refresh)) {
            refreshedWithToken =
                (options.data as Map<dynamic, dynamic>?)?['refreshToken']
                    ?.toString();
            return _jsonBody(<String, dynamic>{
              'success': true,
              'data': <String, dynamic>{
                'accessToken': 'fresh_access',
                'refreshToken': 'fresh_refresh',
              },
            }, 200);
          }

          protectedAttempts++;
          final auth = options.headers[AppConstants.headerAuthorization]?.toString();
          if (auth == 'Bearer fresh_access') {
            return _jsonBody(<String, dynamic>{
              'success': true,
              'data': <String, dynamic>{'ok': true},
            }, 200);
          }
          return _jsonBody(<String, dynamic>{'message': 'Unauthorized'}, 401);
        });

      final mainDio = Dio(BaseOptions(baseUrl: 'http://localhost:4010/api/v1'))
        ..httpClientAdapter = _FakeHttpClientAdapter((options, _, _) async {
          protectedAttempts++;
          final auth = options.headers[AppConstants.headerAuthorization]?.toString();
          if (auth == 'Bearer fresh_access') {
            return _jsonBody(<String, dynamic>{
              'success': true,
              'data': <String, dynamic>{'ok': true},
            }, 200);
          }
          return _jsonBody(<String, dynamic>{'message': 'Token expired'}, 401);
        });

      mainDio.interceptors.add(
        AuthInterceptor(storage, refreshDio: refreshDio),
      );

      final response = await mainDio.get<dynamic>('/home/dashboard');
      final responseMap = ApiResponseParser.unwrapMap(response.data);

      expect(protectedAttempts, 2);
      expect(refreshedWithToken, 'valid_refresh');
      expect(responseMap['ok'], isTrue);
      expect(await storage.read(AppConstants.keyAuthToken), 'fresh_access');
      expect(await storage.read(AppConstants.keyRefreshToken), 'fresh_refresh');
    });

    test('triggers onSessionExpired and clears storage when refresh fails', () async {
      final storage = _InMemorySecureStorage();
      await storage.write(AppConstants.keyAuthToken, 'expired_access');
      await storage.write(AppConstants.keyRefreshToken, 'revoked_refresh');

      bool expiredCalled = false;

      final refreshDio = Dio(BaseOptions(baseUrl: 'http://localhost:4010/api/v1'))
        ..httpClientAdapter = _FakeHttpClientAdapter(
          (options, _, _) async =>
              _jsonBody(<String, dynamic>{'message': 'Invalid refresh token'}, 401),
        );

      final mainDio = Dio(BaseOptions(baseUrl: 'http://localhost:4010/api/v1'))
        ..httpClientAdapter = _FakeHttpClientAdapter(
          (options, _, _) async =>
              _jsonBody(<String, dynamic>{'message': 'Unauthorized'}, 401),
        );

      mainDio.interceptors.add(
        AuthInterceptor(
          storage,
          refreshDio: refreshDio,
          onSessionExpired: () => expiredCalled = true,
        ),
      );

      await expectLater(
        () => mainDio.get<dynamic>(ApiEndpoints.homeDashboard),
        throwsA(isA<DioException>()),
      );

      expect(expiredCalled, isTrue);
      expect(await storage.read(AppConstants.keyAuthToken), isNull);
      expect(await storage.read(AppConstants.keyRefreshToken), isNull);
    });
  });

  group('LocalCacheService & OfflineQueueService', () {
    test('LocalCacheService stores values within TTL and expires past TTL', () {
      final cache = LocalCacheService();
      cache.put('fresh_key', <String, dynamic>{'points': 42});
      cache.put(
        'expired_key',
        'old',
        ttl: const Duration(milliseconds: -10),
      );

      expect(cache.get<Map<String, dynamic>>('fresh_key')?['points'], 42);
      expect(cache.get<String>('expired_key'), isNull);
    });

    test('OfflineQueueService deduplicates by clientSubmissionId and respects retry cap', () {
      final queue = OfflineQueueService();
      final item1 = OfflineQueueItem(
        id: 'q1',
        endpoint: ApiEndpoints.feedback,
        httpMethod: 'POST',
        payload: const <String, dynamic>{'clientSubmissionId': 'sub-uuid-1'},
        createdAt: DateTime.now(),
      );
      final duplicate = OfflineQueueItem(
        id: 'q2',
        endpoint: ApiEndpoints.feedback,
        httpMethod: 'POST',
        payload: const <String, dynamic>{'clientSubmissionId': 'sub-uuid-1'},
        createdAt: DateTime.now(),
      );

      queue.enqueue(item1);
      queue.enqueue(duplicate);
      expect(queue.pendingCount, 1);

      for (int i = 0; i < AppConstants.maxOfflineQueueRetries; i++) {
        queue.markAttempted('q1');
      }
      expect(queue.canRetry(queue.pendingItems.first), isFalse);
    });
  });
}
