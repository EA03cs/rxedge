import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/core/error/exceptions.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/features/home/data/datasources/home_local_datasource.dart';
import 'package:rxedge/features/home/data/datasources/home_remote_datasource.dart';
import 'package:rxedge/features/home/data/models/home_dashboard_dto.dart';
import 'package:rxedge/features/home/data/repositories/home_repository_impl.dart';

class MockHomeRemoteDatasource extends Mock implements HomeRemoteDatasource {}
class MockHomeLocalDatasource extends Mock implements HomeLocalDatasource {}

void main() {
  late MockHomeRemoteDatasource mockRemote;
  late MockHomeLocalDatasource mockLocal;
  late HomeRepositoryImpl repository;

  final testDashboardDto = HomeDashboardDto(
    continueLesson: const ContinueLearningDto(
      id: 'les_cardio_204',
      productName: 'AtorvaCare 20mg',
      lessonTitle: 'Managing Statin-Associated Muscle Symptoms (SAMS)',
      progress: 0.65,
      totalModules: 4,
      completedModules: 2,
    ),
    recommendedProduct: const RecommendedProductDto(
      id: 'prod_cardura_xl',
      productName: 'Cardura XL',
      therapeuticArea: 'Hypertension & BPH',
      description: 'Gastrointestinal therapeutic system providing sustained BP control.',
    ),
    challenge: const MonthlyChallengeDto(
      id: 'chal_nov_q4',
      title: 'Cardiovascular Knowledge Blitz',
      daysLeft: 4,
      progress: 0.72,
      currentRank: 3,
      totalParticipants: 28,
    ),
    objection: const DoctorObjectionDto(
      id: 'obj_vance_01',
      doctorQuote: '“I usually stick with generic amlodipine for stage 1 hypertension.”',
      doctorName: 'Dr. Robert Vance',
      specialty: 'Consultant Cardiologist',
      productConcerned: 'Cardura XL',
      responseSummary: 'Highlight 24-hour plasma concentration stability.',
    ),
    recentMaterials: [
      MaterialUpdateDto(
        id: 'mat_01',
        title: 'AtorvaCare Phase IV Renal Safety Sub-study',
        specialty: 'Cardiology',
        badgeType: 'new',
        updatedAt: DateTime(2026, 11, 8).toIso8601String(),
      ),
    ],
    stats: const RepStatsDto(
      points: 350,
      streakDays: 7,
      quizzesCompleted: 18,
    ),
  );

  setUpAll(() {
    registerFallbackValue(testDashboardDto);
  });

  setUp(() {
    mockRemote = MockHomeRemoteDatasource();
    mockLocal = MockHomeLocalDatasource();
    repository = HomeRepositoryImpl(
      remoteDatasource: mockRemote,
      localDatasource: mockLocal,
    );
  });

  group('HomeRepositoryImpl - Stale-While-Revalidate Strategy', () {
    test('returns cached HomeDashboard immediately when cache is fresh', () async {
      when(() => mockLocal.isCacheFresh()).thenReturn(true);
      when(() => mockLocal.getCachedHomeDashboard()).thenAnswer((_) async => testDashboardDto);

      final result = await repository.getHomeDashboard(forceRefresh: false);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.continueLesson?.productName, 'AtorvaCare 20mg');
      expect(result.dataOrNull?.stats.points, 350);
      verify(() => mockLocal.getCachedHomeDashboard()).called(1);
      verifyNever(() => mockRemote.getHomeDashboard());
    });

    test('fetches from remote and updates cache when cache is stale', () async {
      when(() => mockLocal.isCacheFresh()).thenReturn(false);
      when(() => mockRemote.getHomeDashboard()).thenAnswer((_) async => testDashboardDto);
      when(() => mockLocal.cacheHomeDashboard(any())).thenAnswer((_) async {});

      final result = await repository.getHomeDashboard();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.challenge.title, 'Cardiovascular Knowledge Blitz');
      verify(() => mockRemote.getHomeDashboard()).called(1);
      verify(() => mockLocal.cacheHomeDashboard(testDashboardDto)).called(1);
    });

    test('forces remote fetch when forceRefresh is true even if cache is fresh', () async {
      when(() => mockLocal.isCacheFresh()).thenReturn(true);
      when(() => mockRemote.getHomeDashboard()).thenAnswer((_) async => testDashboardDto);
      when(() => mockLocal.cacheHomeDashboard(any())).thenAnswer((_) async {});

      final result = await repository.getHomeDashboard(forceRefresh: true);

      expect(result.isSuccess, isTrue);
      verify(() => mockRemote.getHomeDashboard()).called(1);
      verifyNever(() => mockLocal.getCachedHomeDashboard());
    });

    test('falls back to stale cache if remote fetch throws network exception', () async {
      when(() => mockLocal.isCacheFresh()).thenReturn(false);
      when(() => mockRemote.getHomeDashboard()).thenThrow(const NetworkException('No connection'));
      when(() => mockLocal.getCachedHomeDashboard()).thenAnswer((_) async => testDashboardDto);

      final result = await repository.getHomeDashboard();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.objection.doctorName, 'Dr. Robert Vance');
      verify(() => mockRemote.getHomeDashboard()).called(1);
      verify(() => mockLocal.getCachedHomeDashboard()).called(1);
    });

    test('returns Failure when remote throws and no cache exists', () async {
      when(() => mockLocal.isCacheFresh()).thenReturn(false);
      when(() => mockRemote.getHomeDashboard())
          .thenThrow(const ServerException('Server unavailable', statusCode: 500));
      when(() => mockLocal.getCachedHomeDashboard()).thenAnswer((_) async => null);

      final result = await repository.getHomeDashboard();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ServerFailure>());
      final failure = result.failureOrNull as ServerFailure;
      expect(failure.statusCode, 500);
    });
  });
}
