import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/learn/data/repositories/learn_repository_impl.dart';
import 'package:rxedge/features/learn/domain/entities/learning_entities.dart';
import 'package:rxedge/features/learn/domain/repositories/learn_repository.dart';
import 'package:rxedge/features/learn/presentation/controllers/learn_controller.dart';

class MockLearnRepository extends Mock implements LearnRepository {}

void main() {
  late MockLearnRepository mockRepo;

  final sampleProducts = [
    const ProductLearningEntity(
      id: 'prod_b',
      name: 'Beta Block',
      therapeuticArea: 'Cardio',
      isRecommended: false,
      positioning: ProductPositioningEntity(
        keyMessage: 'Beta msg',
        targetDoctors: ['Cardiologist'],
        keyBenefits: ['Benefit'],
        dosageHighlights: ['10mg'],
        proofPoints: ['Proof'],
      ),
      competitors: [],
      lessons: [
        LessonEntity(
          id: 'les_b1',
          productId: 'prod_b',
          productName: 'Beta Block',
          title: 'Lesson B1',
          durationMinutes: 4,
          order: 1,
          isCompleted: false,
        ),
      ],
    ),
    const ProductLearningEntity(
      id: 'prod_a',
      name: 'Alpha Plus',
      therapeuticArea: 'Hypertension',
      isRecommended: true,
      positioning: ProductPositioningEntity(
        keyMessage: 'Alpha msg',
        targetDoctors: ['Urologist'],
        keyBenefits: ['Benefit'],
        dosageHighlights: ['5mg'],
        proofPoints: ['Proof'],
      ),
      competitors: [],
      lessons: [
        LessonEntity(
          id: 'les_a1',
          productId: 'prod_a',
          productName: 'Alpha Plus',
          title: 'Lesson A1',
          durationMinutes: 5,
          order: 1,
          isCompleted: true,
        ),
        LessonEntity(
          id: 'les_a2',
          productId: 'prod_a',
          productName: 'Alpha Plus',
          title: 'Lesson A2',
          durationMinutes: 3,
          order: 2,
          isCompleted: false,
          isBookmarked: true,
        ),
      ],
    ),
  ];

  setUp(() {
    mockRepo = MockLearnRepository();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        learnRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('LearnController', () {
    test('initial load sorts recommended and in-progress products first', () async {
      when(() => mockRepo.getProducts(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(sampleProducts));

      final container = createContainer();
      final products = await container.read(learnControllerProvider.future);

      expect(products.length, 2);
      // Alpha Plus is recommended and in-progress, so it must be first
      expect(products.first.id, 'prod_a');
      expect(products.last.id, 'prod_b');
    });

    test('bookmarkedLessonsProvider reactively returns all bookmarked lessons', () async {
      when(() => mockRepo.getProducts(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(sampleProducts));

      final container = createContainer();
      await container.read(learnControllerProvider.future);

      final bookmarks = container.read(bookmarkedLessonsProvider);
      expect(bookmarks.length, 1);
      expect(bookmarks.first.id, 'les_a2');
    });

    test('markLessonCompleted updates lesson completion status', () async {
      when(() => mockRepo.getProducts(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(sampleProducts));
      when(() => mockRepo.markLessonCompleted('les_b1'))
          .thenAnswer((_) async => const Result.success(
                LessonEntity(
                  id: 'les_b1',
                  productId: 'prod_b',
                  productName: 'Beta Block',
                  title: 'Lesson B1',
                  durationMinutes: 4,
                  order: 1,
                  isCompleted: true,
                ),
              ));

      final container = createContainer();
      await container.read(learnControllerProvider.future);

      await container.read(learnControllerProvider.notifier).markLessonCompleted('les_b1');

      final updatedProducts = container.read(learnControllerProvider).value!;
      final beta = updatedProducts.firstWhere((p) => p.id == 'prod_b');
      expect(beta.lessons.first.isCompleted, isTrue);
    });

    test('toggleLessonBookmark updates bookmark state reactively', () async {
      when(() => mockRepo.getProducts(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(sampleProducts));
      when(() => mockRepo.toggleLessonBookmark('les_b1'))
          .thenAnswer((_) async => const Result.success(
                LessonEntity(
                  id: 'les_b1',
                  productId: 'prod_b',
                  productName: 'Beta Block',
                  title: 'Lesson B1',
                  durationMinutes: 4,
                  order: 1,
                  isBookmarked: true,
                ),
              ));

      final container = createContainer();
      await container.read(learnControllerProvider.future);

      await container.read(learnControllerProvider.notifier).toggleLessonBookmark('les_b1');

      final bookmarks = container.read(bookmarkedLessonsProvider);
      expect(bookmarks.any((l) => l.id == 'les_b1'), isTrue);
    });

    test('handles failure state properly', () async {
      when(() => mockRepo.getProducts(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => const Result.failure(ServerFailure(debugMessage: 'Server unreachable')));

      final container = createContainer();
      
      expect(
        () => container.read(learnControllerProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });
}
