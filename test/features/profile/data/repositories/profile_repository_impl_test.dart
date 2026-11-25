import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/core/error/exceptions.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/core/network/api_endpoints.dart';
import 'package:rxedge/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:rxedge/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:rxedge/features/profile/data/models/profile_dto.dart';
import 'package:rxedge/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:rxedge/features/profile/domain/entities/profile_entities.dart';

class MockProfileRemoteDatasource extends Mock implements ProfileRemoteDatasource {}

class MockProfileLocalDatasource extends Mock implements ProfileLocalDatasource {}

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

void main() {
  late MockProfileRemoteDatasource mockRemote;
  late MockProfileLocalDatasource mockLocal;
  late ProfileRepositoryImpl repository;

  const sampleProfileDto = UserProfileDto(
    id: 'usr_test_1',
    displayName: 'Alex Mercer',
    email: 'alex@rxedge.com',
    employeeId: 'MR-7842',
    territory: 'Cairo North',
    role: 'Senior Medical Representative',
    points: 1250,
    streakDays: 4,
    badges: [],
    notificationPreferences: NotificationPreferencesDto(
      newMaterials: true,
      monthlyChallenges: true,
      feedbackReplies: true,
      quizReminders: true,
    ),
    storageUsageBytes: 25800000,
  );

  setUpAll(() {
    registerFallbackValue(sampleProfileDto);
    registerFallbackValue(sampleProfileDto.notificationPreferences);
  });

  setUp(() {
    mockRemote = MockProfileRemoteDatasource();
    mockLocal = MockProfileLocalDatasource();
    when(() => mockLocal.getSavedPreferences()).thenAnswer((_) async => null);
    repository = ProfileRepositoryImpl(
      remoteDatasource: mockRemote,
      localDatasource: mockLocal,
    );
  });

  group('ProfileRepositoryImpl Tests', () {
    test('getProfile returns cached profile when available', () async {
      when(() => mockLocal.getCachedProfile()).thenAnswer((_) async => sampleProfileDto);
      when(() => mockLocal.getStorageUsage()).thenReturn(25800000);

      final result = await repository.getProfile();

      expect(result.isSuccess, isTrue);
      result.when(
        success: (profile) {
          expect(profile.displayName, 'Alex Mercer');
          expect(profile.employeeId, 'MR-7842');
        },
        failure: (_) => fail('Expected success'),
      );
      verifyZeroInteractions(mockRemote);
    });

    test('getProfile fetches from remote and caches when no cache exists', () async {
      when(() => mockLocal.getCachedProfile()).thenAnswer((_) async => null);
      when(() => mockRemote.getProfile()).thenAnswer((_) async => sampleProfileDto);
      when(() => mockLocal.savePreferences(any())).thenAnswer((_) async {});
      when(() => mockLocal.cacheProfile(any())).thenAnswer((_) async {});
      when(() => mockLocal.getStorageUsage()).thenReturn(25800000);

      final result = await repository.getProfile();

      expect(result.isSuccess, isTrue);
      verify(() => mockRemote.getProfile()).called(1);
      verify(() => mockLocal.savePreferences(sampleProfileDto.notificationPreferences))
          .called(1);
      verify(() => mockLocal.cacheProfile(any())).called(1);
    });

    test('getProfile prefers server notificationPreferences from /auth/me and caches them',
        () async {
      const staleSavedPrefs = NotificationPreferencesDto(
        newMaterials: true,
        monthlyChallenges: true,
        feedbackReplies: true,
        quizReminders: true,
      );
      const serverProfile = UserProfileDto(
        id: 'usr_test_1',
        displayName: 'Alex Mercer',
        email: 'alex@rxedge.com',
        employeeId: 'MR-7842',
        territory: 'Cairo North',
        role: 'Senior Medical Representative',
        points: 1250,
        streakDays: 4,
        badges: [],
        notificationPreferences: NotificationPreferencesDto(
          newMaterials: false,
          monthlyChallenges: true,
          feedbackReplies: false,
          quizReminders: true,
        ),
        hasServerNotificationPreferences: true,
        storageUsageBytes: 25800000,
      );

      when(() => mockLocal.getSavedPreferences()).thenAnswer((_) async => staleSavedPrefs);
      when(() => mockRemote.getProfile()).thenAnswer((_) async => serverProfile);
      when(() => mockLocal.savePreferences(any())).thenAnswer((_) async {});
      when(() => mockLocal.cacheProfile(any())).thenAnswer((_) async {});
      when(() => mockLocal.getStorageUsage()).thenReturn(25800000);

      final result = await repository.getProfile(forceRefresh: true);

      expect(result.isSuccess, isTrue);
      result.when(
        success: (profile) {
          expect(profile.notificationPreferences.newMaterials, isFalse);
          expect(profile.notificationPreferences.feedbackReplies, isFalse);
          expect(profile.notificationPreferences.monthlyChallenges, isTrue);
        },
        failure: (_) => fail('Expected success'),
      );
      verify(() => mockLocal.savePreferences(serverProfile.notificationPreferences))
          .called(1);
    });

    test('getProfile falls back to cached prefs when /auth/me omits notificationPreferences',
        () async {
      const savedPrefs = NotificationPreferencesDto(
        newMaterials: false,
        monthlyChallenges: false,
        feedbackReplies: true,
        quizReminders: false,
      );
      const remoteWithoutPrefs = UserProfileDto(
        id: 'usr_test_1',
        displayName: 'Alex Mercer',
        email: 'alex@rxedge.com',
        employeeId: 'MR-7842',
        territory: 'Cairo North',
        role: 'Senior Medical Representative',
        points: 1250,
        streakDays: 4,
        badges: [],
        notificationPreferences: NotificationPreferencesDto(
          newMaterials: true,
          monthlyChallenges: true,
          feedbackReplies: true,
          quizReminders: true,
        ),
        hasServerNotificationPreferences: false,
        storageUsageBytes: 25800000,
      );

      when(() => mockLocal.getSavedPreferences()).thenAnswer((_) async => savedPrefs);
      when(() => mockLocal.getCachedProfile()).thenAnswer((_) async => null);
      when(() => mockRemote.getProfile()).thenAnswer((_) async => remoteWithoutPrefs);
      when(() => mockLocal.cacheProfile(any())).thenAnswer((_) async {});
      when(() => mockLocal.getStorageUsage()).thenReturn(25800000);

      final result = await repository.getProfile();

      expect(result.isSuccess, isTrue);
      result.when(
        success: (profile) {
          expect(profile.notificationPreferences.newMaterials, isFalse);
          expect(profile.notificationPreferences.monthlyChallenges, isFalse);
          expect(profile.notificationPreferences.feedbackReplies, isTrue);
          expect(profile.notificationPreferences.quizReminders, isFalse);
        },
        failure: (_) => fail('Expected success'),
      );
      verifyNever(() => mockLocal.savePreferences(any()));
    });

    test('updateNotificationPreferences calls remote first and caches locally on success',
        () async {
      when(() => mockRemote.updateNotificationPreferences(any()))
          .thenAnswer((_) async {});
      when(() => mockLocal.savePreferences(any())).thenAnswer((_) async {});

      const prefs = NotificationPreferencesEntity(
        newMaterials: false,
        monthlyChallenges: true,
        feedbackReplies: true,
        quizReminders: false,
      );

      final result = await repository.updateNotificationPreferences(prefs);

      expect(result.isSuccess, isTrue);
      verifyInOrder([
        () => mockRemote.updateNotificationPreferences(any()),
        () => mockLocal.savePreferences(any()),
      ]);
    });

    test('updateNotificationPreferences does not cache locally when remote PATCH fails',
        () async {
      when(() => mockRemote.updateNotificationPreferences(any())).thenThrow(
        const ServerException('PATCH failed', statusCode: 500),
      );

      const prefs = NotificationPreferencesEntity(
        newMaterials: false,
        monthlyChallenges: true,
        feedbackReplies: true,
        quizReminders: false,
      );

      final result = await repository.updateNotificationPreferences(prefs);

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ServerFailure>());
      verify(() => mockRemote.updateNotificationPreferences(any())).called(1);
      verifyNever(() => mockLocal.savePreferences(any()));
    });

    test('clearCachedDownloads clears local storage and resets memory size to 0', () async {
      when(() => mockLocal.clearDownloads()).thenAnswer((_) async {});

      final result = await repository.clearCachedDownloads();

      expect(result.isSuccess, isTrue);
      verify(() => mockLocal.clearDownloads()).called(1);
    });

    test('getProfile preserves locally saved notification preferences', () async {
      const savedPrefs = NotificationPreferencesDto(
        newMaterials: false,
        monthlyChallenges: false,
        feedbackReplies: true,
        quizReminders: false,
      );
      when(() => mockLocal.getSavedPreferences()).thenAnswer((_) async => savedPrefs);
      when(() => mockLocal.getCachedProfile()).thenAnswer((_) async => sampleProfileDto);
      when(() => mockLocal.getStorageUsage()).thenReturn(25800000);

      final result = await repository.getProfile();

      expect(result.isSuccess, isTrue);
      result.when(
        success: (profile) {
          expect(profile.notificationPreferences.newMaterials, isFalse);
          expect(profile.notificationPreferences.monthlyChallenges, isFalse);
          expect(profile.notificationPreferences.feedbackReplies, isTrue);
          expect(profile.notificationPreferences.quizReminders, isFalse);
        },
        failure: (_) => fail('Expected success'),
      );
    });
  });

  group('ProfileRemoteDatasourceImpl & UserProfileDto notificationPreferences', () {
    test('updateNotificationPreferences sends PATCH /auth/me/preferences with payload',
        () async {
      RequestOptions? captured;
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:4010/api/v1'))
        ..httpClientAdapter = _FakeHttpClientAdapter((options) async {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode(<String, dynamic>{'success': true, 'data': <String, dynamic>{}}),
            200,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>['application/json'],
            },
          );
        });

      final remote = ProfileRemoteDatasourceImpl(dio: dio);
      await remote.updateNotificationPreferences(
        const NotificationPreferencesDto(
          newMaterials: false,
          monthlyChallenges: true,
          feedbackReplies: false,
          quizReminders: true,
        ),
      );

      expect(captured, isNotNull);
      expect(captured!.method, 'PATCH');
      expect(captured!.path, ApiEndpoints.mePreferences);
      expect(captured!.data, <String, dynamic>{
        'notificationPreferences': <String, dynamic>{
          'newMaterials': false,
          'monthlyChallenges': true,
          'feedbackReplies': false,
          'quizReminders': true,
        },
      });
    });

    test('UserProfileDto.fromJson detects presence or absence of notificationPreferences',
        () {
      final withPrefs = UserProfileDto.fromJson(<String, dynamic>{
        'id': 'u1',
        'name': 'Rep One',
        'email': 'rep@rxedge.com',
        'notificationPreferences': <String, dynamic>{
          'newMaterials': false,
          'monthlyChallenges': true,
          'feedbackReplies': false,
          'quizReminders': true,
        },
      });
      final withoutPrefs = UserProfileDto.fromJson(<String, dynamic>{
        'id': 'u1',
        'name': 'Rep One',
        'email': 'rep@rxedge.com',
      });

      expect(withPrefs.hasServerNotificationPreferences, isTrue);
      expect(withPrefs.notificationPreferences.newMaterials, isFalse);
      expect(withPrefs.notificationPreferences.feedbackReplies, isFalse);
      expect(withoutPrefs.hasServerNotificationPreferences, isFalse);
    });
  });
}
