import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/app/theme/theme.dart';
import 'package:rxedge/core/config/app_constants.dart';
import 'package:rxedge/core/network/dio_client.dart';
import 'package:rxedge/core/network/interceptors/auth_interceptor.dart';
import 'package:rxedge/core/storage/secure_storage_service.dart';
import 'package:rxedge/features/feedback/presentation/widgets/voice_note_player_card.dart';

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

class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  late MockAudioPlayer mockPlayer;
  late StreamController<PlayerState> stateController;
  late StreamController<void> completeController;
  late Directory tempDir;

  setUpAll(() {
    registerFallbackValue(DeviceFileSource(''));
  });

  setUp(() {
    mockPlayer = MockAudioPlayer();
    stateController = StreamController<PlayerState>.broadcast();
    completeController = StreamController<void>.broadcast();
    tempDir = Directory.systemTemp.createTempSync('rxedge_voice_test_');

    when(() => mockPlayer.onPlayerStateChanged)
        .thenAnswer((_) => stateController.stream);
    when(() => mockPlayer.onPlayerComplete)
        .thenAnswer((_) => completeController.stream);
    when(() => mockPlayer.play(any())).thenAnswer((_) async {});
    when(() => mockPlayer.pause()).thenAnswer((_) async {});
    when(() => mockPlayer.stop()).thenAnswer((_) async {});
    when(() => mockPlayer.dispose()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await stateController.close();
    await completeController.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Widget wrapWidget({
    required Widget child,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: RxTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  group('VoiceNotePlayerCard authenticated playback tests', () {
    testWidgets(
      'downloads API-host voice note via authenticated Dio to temp file, plays DeviceFileSource, and deletes temp file on dispose',
      (tester) async {
        final storage = _InMemorySecureStorage();
        await storage.write(AppConstants.keyAuthToken, 'voice_jwt_token');

        String? capturedAuthHeader;
        String? createdTempPath;

        final dio = Dio(BaseOptions(baseUrl: 'https://rxedge.agro-plus.net/api/v1'))
          ..httpClientAdapter = _FakeHttpClientAdapter((options, _, _) async {
            capturedAuthHeader =
                options.headers[AppConstants.headerAuthorization]?.toString();
            return ResponseBody.fromBytes(
              Uint8List.fromList(<int>[0x49, 0x44, 0x33, 0x01, 0x02]),
              200,
            );
          });
        dio.interceptors.add(
          AuthInterceptor(
            storage,
            refreshBaseUrl: 'https://rxedge.agro-plus.net/api/v1',
          ),
        );

        await tester.pumpWidget(
          wrapWidget(
            overrides: [dioClientProvider.overrideWithValue(dio)],
            child: VoiceNotePlayerCard(
              voiceSource: '/uploads/feedback/voice_note.m4a',
              playerBuilder: () => mockPlayer,
              tempFileWriter: (bytes, {extension = 'm4a'}) async {
                final file = File('${tempDir.path}/cached_voice.$extension');
                file.writeAsBytesSync(bytes, flush: true);
                createdTempPath = file.path;
                return file.path;
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(LucideIcons.play));
        await tester.pumpAndSettle();

        expect(capturedAuthHeader, 'Bearer voice_jwt_token');
        expect(createdTempPath, isNotNull);
        expect(File(createdTempPath!).existsSync(), isTrue);

        final verified = verify(() => mockPlayer.play(captureAny())).captured;
        expect(verified.single, isA<DeviceFileSource>());
        expect((verified.single as DeviceFileSource).path, createdTempPath);

        // Dispose widget -> temp file must be cleaned up.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pumpAndSettle();

        expect(File(createdTempPath!).existsSync(), isFalse);
      },
    );

    testWidgets(
      'does not attach Bearer token when downloading voice note from external host',
      (tester) async {
        final storage = _InMemorySecureStorage();
        await storage.write(AppConstants.keyAuthToken, 'secret_jwt_token');

        String? capturedAuthHeader = 'sentinel';

        final dio = Dio(BaseOptions(baseUrl: 'https://rxedge.agro-plus.net/api/v1'))
          ..httpClientAdapter = _FakeHttpClientAdapter((options, _, _) async {
            capturedAuthHeader =
                options.headers[AppConstants.headerAuthorization]?.toString();
            return ResponseBody.fromBytes(
              Uint8List.fromList(<int>[1, 2, 3, 4]),
              200,
            );
          });
        dio.interceptors.add(
          AuthInterceptor(
            storage,
            refreshBaseUrl: 'https://rxedge.agro-plus.net/api/v1',
          ),
        );

        await tester.pumpWidget(
          wrapWidget(
            child: VoiceNotePlayerCard(
              voiceSource: 'https://drive.google.com/uc?id=external-audio.m4a',
              dioClient: dio,
              playerBuilder: () => mockPlayer,
              tempFileWriter: (bytes, {extension = 'm4a'}) async {
                final file = File('${tempDir.path}/ext_voice.$extension');
                file.writeAsBytesSync(bytes, flush: true);
                return file.path;
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(LucideIcons.play));
        await tester.pumpAndSettle();

        expect(capturedAuthHeader, isNull);
        verify(() => mockPlayer.play(any())).called(1);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
      },
    );

    testWidgets(
      'shows clear error message on 401/403 without crashing',
      (tester) async {
        final storage = _InMemorySecureStorage();
        await storage.write(AppConstants.keyAuthToken, 'denied_jwt');

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
          wrapWidget(
            overrides: [dioClientProvider.overrideWithValue(dio)],
            child: VoiceNotePlayerCard(
              voiceSource: 'https://rxedge.agro-plus.net/uploads/feedback/private.m4a',
              playerBuilder: () => mockPlayer,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(LucideIcons.play));
        await tester.pumpAndSettle();

        expect(
          find.text('You do not have permission to play this voice note (403).'),
          findsAtLeastNWidgets(1),
        );
        verifyNever(() => mockPlayer.play(any()));
      },
    );
  });
}
