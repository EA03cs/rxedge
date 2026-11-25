import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/challenges/data/repositories/challenges_repository_impl.dart';
import 'package:rxedge/features/challenges/domain/entities/challenges_entities.dart';
import 'package:rxedge/features/challenges/domain/repositories/challenges_repository.dart';
import 'package:rxedge/features/challenges/presentation/controllers/challenges_controller.dart';

class MockChallengesRepository extends Mock implements ChallengesRepository {}

void main() {
  late MockChallengesRepository mockRepo;

  final sampleChallenge = MonthlyChallengeEntity(
    id: 'ch_test',
    title: 'Knowledge Blitz',
    deadline: DateTime.now().add(const Duration(days: 3)),
    rules: const ['Rule 1', 'Rule 2', 'Rule 3'],
    currentProgress: 0.5,
    completedMilestones: 3,
    totalMilestones: 6,
    userRank: 4,
    totalParticipants: 30,
    rewards: const ['Reward 1'],
    leaderboard: const [
      LeaderboardEntry(
        rank: 1,
        repName: 'Sarah',
        territory: 'North',
        points: 1000,
      ),
    ],
  );

  final sampleQuizzes = [
    const QuickQuizEntity(
      id: 'quiz_1',
      title: 'Cardura XL Quiz',
      category: 'Cardio',
      durationMinutes: 2,
      rewardPoints: 30,
      questions: [],
    ),
  ];

  const sampleObjection = ObjectionOfTheMonthEntity(
    id: 'obj_1',
    doctorQuote: 'Quote',
    doctorName: 'Dr. Tarek',
    doctorSpecialty: 'Cardio',
    productConcerned: 'Cardura XL',
    recommendedResponse: 'Response',
    talkingPoints: ['Point 1'],
    studyReference: 'Ref 1',
  );

  setUp(() {
    mockRepo = MockChallengesRepository();
    when(() => mockRepo.getMonthlyChallenge(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => Result.success(sampleChallenge));
    when(() => mockRepo.getQuickQuizzes(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => Result.success(sampleQuizzes));
    when(() => mockRepo.getObjectionOfTheMonth(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => const Result.success(sampleObjection));
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        challengesRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ChallengesController', () {
    test('build loads challenge, quizzes, and objection successfully', () async {
      final container = createContainer();
      final state = await container.read(challengesControllerProvider.future);

      expect(state.monthlyChallenge.title, 'Knowledge Blitz');
      expect(state.quizzes.length, 1);
      expect(state.objection.doctorName, 'Dr. Tarek');
      expect(state.selectedTabIndex, 0);
    });

    test('setTabIndex updates the selected tab index without reloading data', () async {
      final container = createContainer();
      await container.read(challengesControllerProvider.future);

      container.read(challengesControllerProvider.notifier).setTabIndex(1);
      expect(container.read(challengesControllerProvider).value?.selectedTabIndex, 1);

      container.read(challengesControllerProvider.notifier).setTabIndex(2);
      expect(container.read(challengesControllerProvider).value?.selectedTabIndex, 2);
    });

    test('submitObjectionFeedback updates objection state', () async {
      when(() => mockRepo.submitObjectionFeedback('obj_1', 'helpful'))
          .thenAnswer((_) async => Result.success(sampleObjection.copyWith(
                userFeedback: 'helpful',
                helpfulCount: 43,
              )));

      final container = createContainer();
      await container.read(challengesControllerProvider.future);

      await container.read(challengesControllerProvider.notifier).submitObjectionFeedback('helpful');

      final updated = container.read(challengesControllerProvider).value?.objection;
      expect(updated?.userFeedback, 'helpful');
      expect(updated?.helpfulCount, 43);
    });

    test('submitServerQuiz returns server evaluation result on success', () async {
      const serverResult = QuizSubmissionResultEntity(
        attemptId: 'att_123',
        scorePercentage: 100,
        isPassed: true,
        passingScore: 70,
        pointsAwarded: 45,
        answers: [],
      );
      when(() => mockRepo.submitQuizAnswers(
            quizId: 'quiz_1',
            answers: any(named: 'answers'),
          )).thenAnswer((_) async => const Result.success(serverResult));

      final container = createContainer();
      await container.read(challengesControllerProvider.future);

      final res = await container
          .read(challengesControllerProvider.notifier)
          .submitServerQuiz(
            quizId: 'quiz_1',
            answers: const [
              {'questionId': 'q1', 'selectedOptionId': 'o1'},
            ],
          );

      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull?.pointsAwarded, 45);
      expect(res.dataOrNull?.attemptId, 'att_123');
    });

    test('submitServerQuiz propagates failure on network/5xx error', () async {
      when(() => mockRepo.submitQuizAnswers(
            quizId: 'quiz_1',
            answers: any(named: 'answers'),
          )).thenAnswer(
        (_) async => const Result.failure(
          ServerFailure(statusCode: 503, debugMessage: 'Service unavailable'),
        ),
      );

      final container = createContainer();
      await container.read(challengesControllerProvider.future);

      final res = await container
          .read(challengesControllerProvider.notifier)
          .submitServerQuiz(
            quizId: 'quiz_1',
            answers: const [
              {'questionId': 'q1', 'selectedOptionId': 'o1'},
            ],
          );

      expect(res.isFailure, isTrue);
      expect(res.failureOrNull, isA<ServerFailure>());
    });
  });
}
