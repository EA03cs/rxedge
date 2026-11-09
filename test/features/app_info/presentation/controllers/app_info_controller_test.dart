import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/app_info/data/repositories/app_info_repository_impl.dart';
import 'package:rxedge/features/app_info/domain/entities/app_info_entity.dart';
import 'package:rxedge/features/app_info/domain/repositories/app_info_repository.dart';
import 'package:rxedge/features/app_info/presentation/controllers/app_info_controller.dart';

class MockAppInfoRepository extends Mock implements AppInfoRepository {}

void main() {
  late MockAppInfoRepository mockRepository;

  final testEntity = AppInfoEntity(
    appName: 'RxEdge',
    version: '1.0.0',
    buildNumber: '1',
    environment: 'development',
    apiEndpoint: 'https://api-dev.rxedge.internal',
    minSupportedVersion: '1.0.0',
    maintenanceMode: false,
    serverTimestamp: DateTime(2026, 11, 9),
  );

  setUp(() {
    mockRepository = MockAppInfoRepository();
  });

  group('AppInfoController Tests', () {
    test('initial state loads entity successfully into AsyncData', () async {
      when(() => mockRepository.getAppInfo(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(testEntity));

      final container = ProviderContainer(
        overrides: [
          appInfoRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Listen to the controller to trigger build
      final subscription = container.listen(
        appInfoControllerProvider,
        (previous, next) {},
      );

      // Initial state is loading
      expect(subscription.read(), const AsyncValue<AppInfoEntity>.loading());

      // Wait for future resolution
      await container.read(appInfoControllerProvider.future);

      // Now it's AsyncData
      expect(subscription.read(), AsyncValue.data(testEntity));
    });

    test('handles failure and transitions to AsyncError', () async {
      const failure = NetworkFailure(debugMessage: 'Connection failed');
      when(() => mockRepository.getAppInfo(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => const Result.failure(failure));

      final container = ProviderContainer(
        overrides: [
          appInfoRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        appInfoControllerProvider,
        (previous, next) {},
      );

      try {
        await container.read(appInfoControllerProvider.future);
      } catch (e) {
        expect(e, failure);
      }

      expect(subscription.read(), isA<AsyncError<AppInfoEntity>>());
    });

    test('refresh invokes repository with forceRefresh = true', () async {
      when(() => mockRepository.getAppInfo(forceRefresh: false))
          .thenAnswer((_) async => Result.success(testEntity));
      when(() => mockRepository.getAppInfo(forceRefresh: true))
          .thenAnswer((_) async => Result.success(testEntity));

      final container = ProviderContainer(
        overrides: [
          appInfoRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(appInfoControllerProvider.future);

      // Trigger manual refresh
      await container.read(appInfoControllerProvider.notifier).refresh();

      verify(() => mockRepository.getAppInfo(forceRefresh: true)).called(1);
    });
  });
}
