import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:rxedge/features/feedback/domain/entities/feedback_entities.dart';
import 'package:rxedge/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:rxedge/features/feedback/presentation/controllers/feedback_controller.dart';

class MockFeedbackRepository extends Mock implements FeedbackRepository {}

void main() {
  late MockFeedbackRepository mockRepo;

  final sampleItem = FeedbackItemEntity(
    id: 'fb_1',
    type: FeedbackType.doctorObjection,
    title: 'Cardura XL Dosing Concern',
    submittedAt: DateTime(2026, 11, 9, 10, 0),
    status: FeedbackStatus.answered,
    product: 'Cardura XL',
    objection: 'Doctor concerned about peak effect',
  );

  setUp(() {
    mockRepo = MockFeedbackRepository();
  });

  ProviderContainer createContainer({List<Override> overrides = const []}) {
    final container = ProviderContainer(
      overrides: [
        feedbackRepositoryProvider.overrideWithValue(mockRepo),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('FeedbackListController Tests', () {
    test('initial state loads submissions into AsyncData', () async {
      when(() => mockRepo.getSubmissions(forceRefresh: false))
          .thenAnswer((_) async => Result.success([sampleItem]));

      final container = createContainer();
      final subscription = container.listen(feedbackListControllerProvider, (previous, next) {});

      await Future<void>.delayed(Duration.zero);

      final state = subscription.read();
      expect(state.hasValue, isTrue);
      expect(state.value?.length, 1);
      expect(state.value?.first.id, 'fb_1');
    });

    test('refresh invokes repository with forceRefresh = true', () async {
      when(() => mockRepo.getSubmissions(forceRefresh: false))
          .thenAnswer((_) async => Result.success([sampleItem]));
      when(() => mockRepo.getSubmissions(forceRefresh: true))
          .thenAnswer((_) async => Result.success([sampleItem]));

      final container = createContainer();
      container.listen(feedbackListControllerProvider, (previous, next) {});
      await Future<void>.delayed(Duration.zero);

      await container.read(feedbackListControllerProvider.notifier).refresh();

      verify(() => mockRepo.getSubmissions(forceRefresh: true)).called(1);
    });

    test('addSubmission prepends new item to existing state', () async {
      when(() => mockRepo.getSubmissions(forceRefresh: false))
          .thenAnswer((_) async => Result.success([sampleItem]));

      final container = createContainer();
      container.listen(feedbackListControllerProvider, (previous, next) {});
      await Future<void>.delayed(Duration.zero);

      final newItem = FeedbackItemEntity(
        id: 'fb_new',
        type: FeedbackType.competitorClaim,
        title: 'New Competitor Claim',
        submittedAt: DateTime(2026, 11, 9, 11, 0),
      );

      container.read(feedbackListControllerProvider.notifier).addSubmission(newItem);

      final state = container.read(feedbackListControllerProvider);
      expect(state.value?.length, 2);
      expect(state.value?.first.id, 'fb_new');
    });

    test('handles failure and transitions to AsyncError', () async {
      when(() => mockRepo.getSubmissions(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => const Result.failure(ServerFailure(debugMessage: 'Server error')));

      final container = createContainer();
      container.listen(feedbackListControllerProvider, (previous, next) {});
      await Future<void>.delayed(Duration.zero);

      final state = container.read(feedbackListControllerProvider);
      expect(state.hasError, isTrue);
    });
  });

  group('feedbackDetailProvider Tests', () {
    test('returns matching item by id', () async {
      when(() => mockRepo.getSubmissions(forceRefresh: false))
          .thenAnswer((_) async => Result.success([sampleItem]));

      final container = createContainer();
      container.listen(feedbackListControllerProvider, (previous, next) {});
      await Future<void>.delayed(Duration.zero);

      final detail = container.read(feedbackDetailProvider('fb_1'));
      expect(detail, isNotNull);
      expect(detail?.title, 'Cardura XL Dosing Concern');

      final notFound = container.read(feedbackDetailProvider('non_existent'));
      expect(notFound, isNull);
    });
  });
}
