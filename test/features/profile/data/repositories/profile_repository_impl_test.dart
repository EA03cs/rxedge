import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:rxedge/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:rxedge/features/profile/data/models/profile_dto.dart';
import 'package:rxedge/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:rxedge/features/profile/domain/entities/profile_entities.dart';

class MockProfileRemoteDatasource extends Mock implements ProfileRemoteDatasource {}

class MockProfileLocalDatasource extends Mock implements ProfileLocalDatasource {}

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
      when(() => mockLocal.cacheProfile(any())).thenAnswer((_) async {});
      when(() => mockLocal.getStorageUsage()).thenReturn(25800000);

      final result = await repository.getProfile();

      expect(result.isSuccess, isTrue);
      verify(() => mockRemote.getProfile()).called(1);
      verify(() => mockLocal.cacheProfile(any())).called(1);
    });

    test('updateNotificationPreferences updates local and remote', () async {
      when(() => mockLocal.savePreferences(any())).thenAnswer((_) async {});
      when(() => mockRemote.updateNotificationPreferences(any())).thenAnswer((_) async {});

      const prefs = NotificationPreferencesEntity(
        newMaterials: false,
        monthlyChallenges: true,
        feedbackReplies: true,
        quizReminders: false,
      );

      final result = await repository.updateNotificationPreferences(prefs);

      expect(result.isSuccess, isTrue);
      verify(() => mockLocal.savePreferences(any())).called(1);
      verify(() => mockRemote.updateNotificationPreferences(any())).called(1);
    });

    test('clearCachedDownloads clears local storage and resets memory size to 0', () async {
      when(() => mockLocal.clearDownloads()).thenAnswer((_) async {});

      final result = await repository.clearCachedDownloads();

      expect(result.isSuccess, isTrue);
      verify(() => mockLocal.clearDownloads()).called(1);
    });
  });
}
