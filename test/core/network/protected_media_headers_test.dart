import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxedge/core/config/app_constants.dart';
import 'package:rxedge/core/config/env_config.dart';
import 'package:rxedge/core/network/api_endpoints.dart';
import 'package:rxedge/core/network/interceptors/auth_interceptor.dart';
import 'package:rxedge/core/network/url_resolver.dart';
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
  group('buildProtectedMediaHeaders / UrlResolver.mediaHeaders', () {
    final defaultApiHost = Uri.parse(EnvConfig.baseUrl).host;

    test('attaches Bearer token when URL host matches configured API host', () {
      final apiUrl = 'https://$defaultApiHost/uploads/feedback/photo.jpg';

      expect(
        buildProtectedMediaHeaders(apiUrl, 'jwt_abc_123'),
        <String, String>{'Authorization': 'Bearer jwt_abc_123'},
      );
      expect(
        UrlResolver.mediaHeaders(apiUrl, 'jwt_abc_123'),
        <String, String>{'Authorization': 'Bearer jwt_abc_123'},
      );
    });

    test('matches API host case-insensitively and across http/https schemes', () {
      final upperUrl =
          'http://${defaultApiHost.toUpperCase()}/uploads/feedback/voice.m4a';

      expect(
        UrlResolver.mediaHeaders(upperUrl, 'token_xyz'),
        <String, String>{'Authorization': 'Bearer token_xyz'},
      );
    });

    test('supports custom apiBaseUrl override for local dev hosts', () {
      const devBase = 'http://10.0.2.2:4010/api/v1';

      expect(
        UrlResolver.mediaHeaders(
          'http://10.0.2.2:4010/uploads/feedback/voice.m4a',
          'dev_jwt',
          apiBaseUrl: devBase,
        ),
        <String, String>{'Authorization': 'Bearer dev_jwt'},
      );
      expect(
        UrlResolver.mediaHeaders(
          'https://rxedge.agro-plus.net/uploads/feedback/voice.m4a',
          'dev_jwt',
          apiBaseUrl: devBase,
        ),
        isNull,
      );
    });

    test('returns null for external hosts like Google Drive or Unsplash', () {
      expect(
        UrlResolver.mediaHeaders(
          'https://drive.google.com/file/d/1VNDLsNCR0yirkhYAkpm1/view',
          'secret_jwt',
        ),
        isNull,
      );
      expect(
        UrlResolver.mediaHeaders(
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae',
          'secret_jwt',
        ),
        isNull,
      );
      expect(
        UrlResolver.mediaHeaders(
          'https://$defaultApiHost.evil.com/uploads/feedback/photo.jpg',
          'secret_jwt',
        ),
        isNull,
      );
    });

    test('returns null when token is null, empty, or whitespace', () {
      final apiUrl = 'https://$defaultApiHost/uploads/feedback/photo.jpg';

      expect(UrlResolver.mediaHeaders(apiUrl, null), isNull);
      expect(UrlResolver.mediaHeaders(apiUrl, ''), isNull);
      expect(UrlResolver.mediaHeaders(apiUrl, '   '), isNull);
    });

    test('returns null for empty, relative, or non-HTTP URLs', () {
      expect(UrlResolver.mediaHeaders('', 'secret_jwt'), isNull);
      expect(UrlResolver.mediaHeaders('/uploads/feedback/photo.jpg', 'secret_jwt'), isNull);
      expect(UrlResolver.mediaHeaders('file:///tmp/photo.jpg', 'secret_jwt'), isNull);
    });
  });

  group('AuthInterceptor media host isolation', () {
    test('attaches Bearer token for API host and omits it for external hosts', () async {
      final storage = _InMemorySecureStorage();
      await storage.write(AppConstants.keyAuthToken, 'media_jwt');

      final capturedAuth = <String, String?>{};
      final dio = Dio(BaseOptions(baseUrl: 'https://rxedge.agro-plus.net/api/v1'))
        ..httpClientAdapter = _FakeHttpClientAdapter((options, _, _) async {
          capturedAuth[options.uri.toString()] =
              options.headers[AppConstants.headerAuthorization]?.toString();
          return ResponseBody.fromBytes(Uint8List.fromList(<int>[1, 2, 3]), 200);
        });

      dio.interceptors.add(
        AuthInterceptor(
          storage,
          refreshBaseUrl: 'https://rxedge.agro-plus.net/api/v1',
        ),
      );

      await dio.get<List<int>>(
        'https://rxedge.agro-plus.net/uploads/feedback/photo.jpg',
        options: Options(responseType: ResponseType.bytes),
      );
      await dio.get<List<int>>(
        'https://drive.google.com/uc?id=external-asset',
        options: Options(responseType: ResponseType.bytes),
      );

      expect(
        capturedAuth['https://rxedge.agro-plus.net/uploads/feedback/photo.jpg'],
        'Bearer media_jwt',
      );
      expect(
        capturedAuth['https://drive.google.com/uc?id=external-asset'],
        isNull,
      );
    });

    test('refreshes expired access token on 401 when fetching API-host media', () async {
      final storage = _InMemorySecureStorage();
      await storage.write(AppConstants.keyAuthToken, 'expired_jwt');
      await storage.write(AppConstants.keyRefreshToken, 'valid_refresh');

      final refreshDio = Dio(BaseOptions(baseUrl: 'https://rxedge.agro-plus.net/api/v1'))
        ..httpClientAdapter = _FakeHttpClientAdapter((options, _, _) async {
          if (options.path.endsWith(ApiEndpoints.refresh)) {
            return _jsonBody(<String, dynamic>{
              'success': true,
              'data': <String, dynamic>{
                'accessToken': 'fresh_jwt',
                'refreshToken': 'fresh_refresh',
              },
            }, 200);
          }
          final auth = options.headers[AppConstants.headerAuthorization]?.toString();
          if (auth == 'Bearer fresh_jwt') {
            return ResponseBody.fromBytes(Uint8List.fromList(<int>[9, 8, 7]), 200);
          }
          return _jsonBody(<String, dynamic>{'message': 'Unauthorized'}, 401);
        });

      final mainDio = Dio(BaseOptions(baseUrl: 'https://rxedge.agro-plus.net/api/v1'))
        ..httpClientAdapter = _FakeHttpClientAdapter((options, _, _) async {
          final auth = options.headers[AppConstants.headerAuthorization]?.toString();
          if (auth == 'Bearer fresh_jwt') {
            return ResponseBody.fromBytes(Uint8List.fromList(<int>[9, 8, 7]), 200);
          }
          return _jsonBody(<String, dynamic>{'message': 'Unauthorized'}, 401);
        });

      mainDio.interceptors.add(
        AuthInterceptor(
          storage,
          refreshBaseUrl: 'https://rxedge.agro-plus.net/api/v1',
          refreshDio: refreshDio,
        ),
      );

      final res = await mainDio.get<List<int>>(
        'https://rxedge.agro-plus.net/uploads/feedback/voice.m4a',
        options: Options(responseType: ResponseType.bytes),
      );

      expect(res.data, <int>[9, 8, 7]);
      expect(await storage.read(AppConstants.keyAuthToken), 'fresh_jwt');
    });
  });
}
