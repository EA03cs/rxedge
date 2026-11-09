import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/home/data/repositories/home_repository_impl.dart';
import 'package:rxedge/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:rxedge/features/home/domain/repositories/home_repository.dart';
import 'package:rxedge/features/home/presentation/controllers/home_controller.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late MockHomeRepository mockRepository;

  final testDashboardEntity = HomeDashboardEntity(
    continueLesson: const ContinueLearningEntity(
      id: 'les_cardio_204',
      productName: 'AtorvaCare 20mg',
      lessonTitle: 'Managing Statin-Associated Muscle Symptoms (SAMS)',
      progress: 0.65,
      totalModules: 4,
      completedModules: 2,
    ),
    recommendedProduct: const RecommendedProductEntity(
      id: 'prod_cardura_xl',
      productName: 'Cardura XL',
      therapeuticArea: 'Hypertension & BPH',
      description: 'GITS sustained blood pressure control.',
    ),
    challenge: const MonthlyChallengeEntity(
      id: 'chal_nov_q4',
      title: 'Cardiovascular Knowledge Blitz',
      daysLeft: 4,
      progress: 0.72,
      currentRank: 3,
      totalParticipants: 28,
    ),
    objection: const DoctorObjectionEntity(
      id: 'obj_vance_01',
      doctorQuote: '“Why switch patients to Cardura XL?”',
      doctorName: 'Dr. Robert Vance',
      specialty: 'Consultant Cardiologist',
      productConcerned: 'Cardura XL',
      responseSummary: 'Highlight 24h plasma concentration stability.',
    ),
    recentMaterials: [
      MaterialUpdateEntity(
        id: 'mat_01',
        title: 'AtorvaCare Phase IV Renal Safety Sub-study',
        specialty: 'Cardiology',
        badgeType: MaterialBadgeType.newRelease,
        updatedAt: DateTime(2026, 11, 8),
      ),
    ],
    stats: const RepStatsEntity(
      points: 350,
      streakDays: 7,
      quizzesCompleted: 18,
    ),
  );

  setUp(() {
    mockRepository = MockHomeRepository();
  });

  group('HomeController Tests', () {
    test('initial state loads entity successfully into AsyncData', () async {
      when(() => mockRepository.getHomeDashboard(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(testDashboardEntity));

      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        homeControllerProvider,
        (previous, next) {},
      );

      // Initial state is loading
      expect(subscription.read(), const AsyncValue<HomeDashboardEntity>.loading());

      // Wait for future resolution
      await container.read(homeControllerProvider.future);

      // Successfully resolved
      expect(subscription.read(), AsyncValue.data(testDashboardEntity));
      expect(subscription.read().value?.stats.points, 350);
    });

    test('handles failure and transitions to AsyncError', () async {
      const failure = NetworkFailure(debugMessage: 'No network connection');
      when(() => mockRepository.getHomeDashboard(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => const Result.failure(failure));

      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        homeControllerProvider,
        (previous, next) {},
      );

      try {
        await container.read(homeControllerProvider.future);
      } catch (e) {
        expect(e, failure);
      }

      expect(subscription.read(), isA<AsyncError<HomeDashboardEntity>>());
    });

    test('refresh invokes repository with forceRefresh = true', () async {
      when(() => mockRepository.getHomeDashboard(forceRefresh: false))
          .thenAnswer((_) async => Result.success(testDashboardEntity));
      when(() => mockRepository.getHomeDashboard(forceRefresh: true))
          .thenAnswer((_) async => Result.success(testDashboardEntity));

      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(homeControllerProvider.future);

      // Trigger manual refresh
      await container.read(homeControllerProvider.notifier).refresh();

      verify(() => mockRepository.getHomeDashboard(forceRefresh: true)).called(1);
    });
  });
}
