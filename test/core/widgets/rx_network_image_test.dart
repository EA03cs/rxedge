import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxedge/app/theme/theme.dart';
import 'package:rxedge/core/config/app_constants.dart';
import 'package:rxedge/core/network/dio_client.dart';
import 'package:rxedge/core/network/interceptors/auth_interceptor.dart';
import 'package:rxedge/core/storage/secure_storage_service.dart';
import 'package:rxedge/core/widgets/rx_network_image.dart';

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

class _FakeHttpClientAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) handler;

  _FakeHttpClientAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      handler(options, requestStream, cancelFuture);

  @override
  void close({bool force = false}) {}
}

// Valid 1x1 transparent PNG image bytes.
final Uint8List _valid1x1Png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

void main() {
  Widget wrapWithApp({
    required Widget child,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: RxTheme.light(),
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  group('RxNetworkImage protected media tests', () {
    testWidgets(
      'sends Bearer token via authenticated Dio for API-host feedback image and renders MemoryImage',
      (tester) async {
        final storage = _InMemorySecureStorage();
        await storage.write(AppConstants.keyAuthToken, 'valid_img_jwt');

        String? capturedAuthHeader;
        String? capturedUri;

        final dio = Dio(BaseOptions(baseUrl: 'https://rxedge.agro-plus.net/api/v1'))
          ..httpClientAdapter = _FakeHttpClientAdapter((options, _, _) async {
            capturedUri = options.uri.toString();
            capturedAuthHeader =
                options.headers[AppConstants.headerAuthorization]?.toString();
            return ResponseBody.fromBytes(_valid1x1Png, 200);
          });
        dio.interceptors.add(
          AuthInterceptor(
            storage,
            refreshBaseUrl: 'https://rxedge.agro-plus.net/api/v1',
          ),
        );

        await tester.pumpWidget(
          wrapWithApp(
            overrides: [dioClientProvider.overrideWithValue(dio)],
            child: const RxNetworkImage(
              imageUrl: '/uploads/feedback/flyer.png',
              width: 240,
              height: 180,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          capturedUri,
          'https://rxedge.agro-plus.net/uploads/feedback/flyer.png',
        );
        expect(capturedAuthHeader, 'Bearer valid_img_jwt');

        final imageFinder = find.byType(Image);
        expect(imageFinder, findsOneWidget);
        final imageWidget = tester.widget<Image>(imageFinder);
        expect(imageWidget.image, isA<MemoryImage>());
      },
    );

    testWidgets(
      'displays clear error placeholder without crashing on HTTP 403',
      (tester) async {
        final storage = _InMemorySecureStorage();
        await storage.write(AppConstants.keyAuthToken, 'wrong_user_jwt');

        final dio = Dio(BaseOptions(baseUrl: 'https://rxedge.agro-plus.net/api/v1'))
          ..httpClientAdapter = _FakeHttpClientAdapter((options, _, _) async {
            return ResponseBody.fromString(
              jsonEncode(<String, dynamic>{'message': 'Forbidden'}),
              403,
              headers: <String, List<String>>{
                Headers.contentTypeHeader: <String>['application/json'],
              },
            );
          });
        dio.interceptors.add(
          AuthInterceptor(
            storage,
            refreshBaseUrl: 'https://rxedge.agro-plus.net/api/v1',
          ),
        );

        await tester.pumpWidget(
          wrapWithApp(
            overrides: [dioClientProvider.overrideWithValue(dio)],
            child: const RxNetworkImage(
              imageUrl: 'https://rxedge.agro-plus.net/uploads/feedback/secret.png',
              width: 240,
              height: 180,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
        expect(find.textContaining('403'), findsOneWidget);
      },
    );

    testWidgets(
      'displays clear error placeholder without crashing on HTTP 401 when refresh fails',
      (tester) async {
        final storage = _InMemorySecureStorage();
        await storage.write(AppConstants.keyAuthToken, 'expired_jwt');

        final dio = Dio(BaseOptions(baseUrl: 'https://rxedge.agro-plus.net/api/v1'))
          ..httpClientAdapter = _FakeHttpClientAdapter((options, _, _) async {
            return ResponseBody.fromString(
              jsonEncode(<String, dynamic>{'message': 'Unauthorized'}),
              401,
              headers: <String, List<String>>{
                Headers.contentTypeHeader: <String>['application/json'],
              },
            );
          });
        dio.interceptors.add(
          AuthInterceptor(
            storage,
            refreshBaseUrl: 'https://rxedge.agro-plus.net/api/v1',
          ),
        );

        await tester.pumpWidget(
          wrapWithApp(
            overrides: [dioClientProvider.overrideWithValue(dio)],
            child: const RxNetworkImage(
              imageUrl: 'https://rxedge.agro-plus.net/uploads/feedback/photo.png',
              width: 240,
              height: 180,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
        expect(find.textContaining('401'), findsOneWidget);
      },
    );

    testWidgets(
      'does not use authenticated Dio or attach Authorization header for external URLs',
      (tester) async {
        bool dioCalled = false;
        final dio = Dio(BaseOptions(baseUrl: 'https://rxedge.agro-plus.net/api/v1'))
          ..httpClientAdapter = _FakeHttpClientAdapter((options, _, _) async {
            dioCalled = true;
            return ResponseBody.fromBytes(_valid1x1Png, 200);
          });

        await tester.pumpWidget(
          wrapWithApp(
            overrides: [dioClientProvider.overrideWithValue(dio)],
            child: const RxNetworkImage(
              imageUrl: 'https://images.unsplash.com/photo-123456',
              authToken: 'should_never_leak',
              width: 200,
              height: 160,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(dioCalled, isFalse);
      },
    );
  });
}
