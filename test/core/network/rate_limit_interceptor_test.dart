import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxedge/core/error/exception_mapper.dart';
import 'package:rxedge/core/error/exceptions.dart';
import 'package:rxedge/core/error/failure_message_mapper.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/core/network/interceptors/error_interceptor.dart';
import 'package:rxedge/core/network/interceptors/rate_limit_interceptor.dart';
import 'package:rxedge/l10n/app_localizations.dart';

class _FakeHttpClientAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;

  _FakeHttpClientAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(
  Map<String, dynamic> body,
  int statusCode, {
  Map<String, List<String>>? headers,
}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>['application/json'],
      ...?headers,
    },
  );
}

void main() {
  group('RateLimitInterceptor (HTTP 429 Retry-After)', () {
    test('parseRetryAfter parses integer seconds, clamps to 10s, and defaults to 2s',
        () {
      expect(
        RateLimitInterceptor.parseRetryAfter(null),
        const Duration(seconds: 2),
      );
      expect(
        RateLimitInterceptor.parseRetryAfter(Headers()),
        const Duration(seconds: 2),
      );
      expect(
        RateLimitInterceptor.parseRetryAfter(
          Headers.fromMap(<String, List<String>>{'Retry-After': <String>['5']}),
        ),
        const Duration(seconds: 5),
      );
      expect(
        RateLimitInterceptor.parseRetryAfter(
          Headers.fromMap(<String, List<String>>{'retry-after': <String>['42']}),
        ),
        const Duration(seconds: 10),
      );
      expect(
        RateLimitInterceptor.parseRetryAfter(
          Headers.fromMap(<String, List<String>>{'Retry-After': <String>['0']}),
        ),
        Duration.zero,
      );
      expect(
        RateLimitInterceptor.parseRetryAfter(
          Headers.fromMap(<String, List<String>>{'Retry-After': <String>['invalid']}),
        ),
        const Duration(seconds: 2),
      );
      expect(
        RateLimitInterceptor.parseRetryAfter(
          Headers.fromMap(<String, List<String>>{'Retry-After': <String>['-3']}),
        ),
        const Duration(seconds: 2),
      );
    });

    test('retries once after Retry-After duration and resolves when retry succeeds',
        () async {
      int attempts = 0;
      final recordedDelays = <Duration>[];
      bool? retriedFlagOnSecondAttempt;

      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:4010/api/v1'))
        ..httpClientAdapter = _FakeHttpClientAdapter((options) async {
          attempts++;
          if (attempts == 1) {
            return _jsonResponse(
              <String, dynamic>{'message': 'Too many requests'},
              429,
              headers: <String, List<String>>{
                'Retry-After': <String>['4'],
              },
            );
          }
          retriedFlagOnSecondAttempt =
              options.extra[RateLimitInterceptor.retriedExtraKey] as bool?;
          return _jsonResponse(<String, dynamic>{'success': true, 'ok': true}, 200);
        });

      dio.interceptors.addAll([
        RateLimitInterceptor(
          dio,
          delay: (duration) async {
            recordedDelays.add(duration);
          },
        ),
        ErrorInterceptor(),
      ]);

      final response = await dio.get<dynamic>('/auth/me');

      expect(attempts, 2);
      expect(recordedDelays, [const Duration(seconds: 4)]);
      expect(retriedFlagOnSecondAttempt, isTrue);
      expect(response.statusCode, 200);
      expect((response.data as Map<String, dynamic>)['ok'], isTrue);
    });

    test('defaults wait to 2s when Retry-After header is missing and clamps > 10s',
        () async {
      final recordedDelays = <Duration>[];
      int attempts = 0;

      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:4010/api/v1'))
        ..httpClientAdapter = _FakeHttpClientAdapter((options) async {
          attempts++;
          if (attempts == 1) {
            return _jsonResponse(<String, dynamic>{}, 429);
          }
          if (attempts == 3) {
            return _jsonResponse(
              <String, dynamic>{},
              429,
              headers: <String, List<String>>{
                'Retry-After': <String>['120'],
              },
            );
          }
          return _jsonResponse(<String, dynamic>{'ok': true}, 200);
        });

      dio.interceptors.addAll([
        RateLimitInterceptor(
          dio,
          delay: (duration) async => recordedDelays.add(duration),
        ),
        ErrorInterceptor(),
      ]);

      await dio.get<dynamic>('/first');
      await dio.get<dynamic>('/second');

      expect(recordedDelays, [
        const Duration(seconds: 2),
        const Duration(seconds: 10),
      ]);
    });

    testWidgets(
        'retries only once when still 429 and maps to friendly rate-limit message',
        (tester) async {
      int attempts = 0;
      final recordedDelays = <Duration>[];

      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:4010/api/v1'))
        ..httpClientAdapter = _FakeHttpClientAdapter((options) async {
          attempts++;
          return _jsonResponse(
            <String, dynamic>{'error': 'RATE_LIMIT'},
            429,
            headers: <String, List<String>>{
              'Retry-After': <String>['1'],
            },
          );
        });

      dio.interceptors.addAll([
        RateLimitInterceptor(
          dio,
          delay: (duration) async => recordedDelays.add(duration),
        ),
        ErrorInterceptor(),
      ]);

      DioException? caught;
      try {
        await dio.patch<dynamic>('/auth/me/preferences');
      } on DioException catch (e) {
        caught = e;
      }

      expect(attempts, 2);
      expect(recordedDelays, [const Duration(seconds: 1)]);
      expect(caught, isNotNull);
      expect(caught!.error, isA<ServerException>());
      final serverEx = caught.error! as ServerException;
      expect(serverEx.statusCode, 429);
      expect(serverEx.message, ErrorInterceptor.rateLimitMessage);
      expect(caught.message, ErrorInterceptor.rateLimitMessage);

      final failure = ExceptionMapper.map(caught);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 429);

      late String uiMessage;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              uiMessage = FailureMessageMapper.map(context, failure);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(
        uiMessage,
        'Too many requests. Please wait a moment and try again.',
      );
    });
  });
}
