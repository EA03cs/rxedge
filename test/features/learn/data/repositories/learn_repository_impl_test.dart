import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/core/error/exceptions.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/features/learn/data/datasources/learn_local_datasource.dart';
import 'package:rxedge/features/learn/data/datasources/learn_remote_datasource.dart';
import 'package:rxedge/features/learn/data/models/learning_dto.dart';
import 'package:rxedge/features/learn/data/repositories/learn_repository_impl.dart';

class MockLearnRemoteDatasource extends Mock implements LearnRemoteDatasource {}
class MockLearnLocalDatasource extends Mock implements LearnLocalDatasource {}

void main() {
  late MockLearnRemoteDatasource mockRemote;
  late MockLearnLocalDatasource mockLocal;
  late LearnRepositoryImpl repository;

  final testProducts = [
    const ProductLearningDto(
      id: 'prod_1',
      name: 'Cardura XL',
      therapeuticArea: 'Hypertension & BPH',
      isRecommended: true,
      positioning: ProductPositioningDto(
        keyMessage: 'Test key message',
        targetDoctors: ['Cardiologist'],
        keyBenefits: ['Benefit 1'],
        dosageHighlights: ['4mg once daily'],
        proofPoints: ['Proof point 1'],
      ),
      competitors: [
        CompetitorComparisonDto(
          id: 'comp_1',
          competitorName: 'Amlodipine',
          theirClaim: 'Low cost',
          howToRespond: 'Edema risk',
          proofReference: 'Study 2025',
        ),
      ],
      lessons: [
        LessonDto(
          id: 'les_1',
          productId: 'prod_1',
          productName: 'Cardura XL',
          title: 'Lesson 1',
          durationMinutes: 5,
          order: 1,
          isCompleted: false,
          isBookmarked: false,
        ),
      ],
    ),
  ];

  setUp(() {
    mockRemote = MockLearnRemoteDatasource();
    mockLocal = MockLearnLocalDatasource();
    repository = LearnRepositoryImpl(
      remoteDatasource: mockRemote,
      localDatasource: mockLocal,
    );

    when(() => mockLocal.getCompletedLessonIds()).thenAnswer((_) async => {});
    when(() => mockLocal.getBookmarkedLessonIds()).thenAnswer((_) async => {});
  });

  group('LearnRepositoryImpl', () {
    test('getProducts fetches remote and caches when local cache is not fresh', () async {
      when(() => mockLocal.isCacheFresh()).thenReturn(false);
      when(() => mockRemote.getProducts()).thenAnswer((_) async => testProducts);
      when(() => mockLocal.cacheProducts(testProducts)).thenAnswer((_) async {});

      final result = await repository.getProducts(forceRefresh: true);

      expect(result.isSuccess, isTrue);
      result.when(
        success: (products) {
          expect(products.length, 1);
          expect(products.first.name, 'Cardura XL');
        },
        failure: (_) => fail('Expected success'),
      );
      verify(() => mockRemote.getProducts()).called(1);
      verify(() => mockLocal.cacheProducts(testProducts)).called(1);
    });

    test('getProducts uses fresh local cache when available', () async {
      when(() => mockLocal.isCacheFresh()).thenReturn(true);
      when(() => mockLocal.getCachedProducts()).thenAnswer((_) async => testProducts);

      final result = await repository.getProducts();

      expect(result.isSuccess, isTrue);
      result.when(
        success: (products) {
          expect(products.length, 1);
          expect(products.first.id, 'prod_1');
        },
        failure: (_) => fail('Expected success'),
      );
      verifyNever(() => mockRemote.getProducts());
    });

    test('getProducts falls back to stale cache on remote failure', () async {
      when(() => mockLocal.isCacheFresh()).thenReturn(false);
      when(() => mockRemote.getProducts()).thenThrow(const ServerException('Server error'));
      when(() => mockLocal.getCachedProducts()).thenAnswer((_) async => testProducts);

      final result = await repository.getProducts(forceRefresh: true);

      expect(result.isSuccess, isTrue);
      result.when(
        success: (products) {
          expect(products.length, 1);
        },
        failure: (_) => fail('Expected fallback success'),
      );
    });

    test('getProducts returns failure if remote and cache both fail', () async {
      when(() => mockLocal.isCacheFresh()).thenReturn(false);
      when(() => mockRemote.getProducts()).thenThrow(const NetworkException('No connection'));
      when(() => mockLocal.getCachedProducts()).thenAnswer((_) async => null);

      final result = await repository.getProducts(forceRefresh: true);

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('Expected failure'),
        failure: (f) {
          expect(f, isA<NetworkFailure>());
        },
      );
    });

    test('markLessonCompleted persists completed status', () async {
      when(() => mockLocal.isCacheFresh()).thenReturn(true);
      when(() => mockLocal.getCachedProducts()).thenAnswer((_) async => testProducts);
      when(() => mockLocal.saveCompletedLessonIds(any())).thenAnswer((_) async {});

      // Prime in-memory
      await repository.getProducts();

      final result = await repository.markLessonCompleted('les_1');

      expect(result.isSuccess, isTrue);
      result.when(
        success: (lesson) {
          expect(lesson.id, 'les_1');
          expect(lesson.isCompleted, isTrue);
        },
        failure: (_) => fail('Expected success'),
      );
      verify(() => mockLocal.saveCompletedLessonIds({'les_1'})).called(1);
    });

    test('toggleLessonBookmark adds and removes bookmarks correctly', () async {
      when(() => mockLocal.isCacheFresh()).thenReturn(true);
      when(() => mockLocal.getCachedProducts()).thenAnswer((_) async => testProducts);
      when(() => mockLocal.saveBookmarkedLessonIds(any())).thenAnswer((_) async {});

      await repository.getProducts();

      // Add bookmark
      final addResult = await repository.toggleLessonBookmark('les_1');
      expect(addResult.isSuccess, isTrue);
      expect(addResult.dataOrNull?.isBookmarked, isTrue);
      verify(() => mockLocal.saveBookmarkedLessonIds({'les_1'})).called(1);

      // Now mock returning the bookmark
      when(() => mockLocal.getBookmarkedLessonIds()).thenAnswer((_) async => {'les_1'});

      // Remove bookmark
      final removeResult = await repository.toggleLessonBookmark('les_1');
      expect(removeResult.isSuccess, isTrue);
      expect(removeResult.dataOrNull?.isBookmarked, isFalse);
    });
  });
}
