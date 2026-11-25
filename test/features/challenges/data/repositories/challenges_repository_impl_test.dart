import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/core/error/exceptions.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/features/challenges/data/datasources/challenges_local_datasource.dart';
import 'package:rxedge/features/challenges/data/datasources/challenges_remote_datasource.dart';
import 'package:rxedge/features/challenges/data/models/challenges_dto.dart';
import 'package:rxedge/features/challenges/data/repositories/challenges_repository_impl.dart';

class MockChallengesRemoteDatasource extends Mock implements ChallengesRemoteDatasource {}
class MockChallengesLocalDatasource extends Mock implements ChallengesLocalDatasource {}

void main() {
  late MockChallengesRemoteDatasource mockRemote;
  late MockChallengesLocalDatasource mockLocal;
  late ChallengesRepositoryImpl repository;

  final sampleChallengeDto = MonthlyChallengeDto(
    id: 'ch_test',
    title: 'Rohto Eye-Know Monthly Challenge',
    deadlineIso: DateTime.now().add(const Duration(days: 4)).toIso8601String(),
    rules: const ['Rule 1', 'Rule 2', 'Rule 3'],
    currentProgress: 0.72,
    completedMilestones: 5,
    totalMilestones: 7,
    userRank: 3,
    totalParticipants: 34,
    rewards: const ['Spotlight Pin', '+500 Marks'],
    leaderboard: const [
      LeaderboardEntryDto(
        rank: 1,
        repName: 'Sarah Jenkins',
        territory: 'North District',
        points: 1420,
      ),
      LeaderboardEntryDto(
        rank: 3,
        repName: 'Alex Mercer',
        territory: 'Central District',
        points: 1250,
        isCurrentUser: true,
      ),
    ],
  );

  final sampleQuizzesDto = [
    const QuickQuizDto(
      id: 'quiz_1',
      title: 'Rohto Dry Aid Study',
      category: 'Cardio',
      durationMinutes: 3,
      rewardPoints: 50,
      questions: [
        QuizQuestionDto(
          id: 'q1',
          question: 'What is the primary endpoint?',
          options: ['Option A', 'Option B'],
          correctOptionIndex: 0,
          explanation: 'Option A is correct.',
        ),
      ],
    ),
  ];

  const sampleObjectionDto = ObjectionOfTheMonthDto(
    id: 'obj_1',
    doctorQuote: 'Why switch patients?',
    doctorName: 'Dr. Tarek',
    doctorSpecialty: 'Cardiologist',
    productConcerned: 'Cardura XL',
    recommendedResponse: 'Highlight 24h control.',
    talkingPoints: ['Point 1', 'Point 2'],
    studyReference: 'PREDICT Trial',
  );

  setUp(() {
    mockRemote = MockChallengesRemoteDatasource();
    mockLocal = MockChallengesLocalDatasource();
    repository = ChallengesRepositoryImpl(
      remoteDatasource: mockRemote,
      localDatasource: mockLocal,
    );
  });

  group('ChallengesRepositoryImpl', () {
    test('getMonthlyChallenge fetches remote and caches when local cache not fresh', () async {
      when(() => mockLocal.isCacheFresh('challenges_monthly')).thenReturn(false);
      when(() => mockRemote.getMonthlyChallenge()).thenAnswer((_) async => sampleChallengeDto);
      when(() => mockLocal.cacheMonthlyChallenge(sampleChallengeDto)).thenAnswer((_) async {});

      final result = await repository.getMonthlyChallenge(forceRefresh: true);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.title, 'Rohto Eye-Know Monthly Challenge');
      verify(() => mockRemote.getMonthlyChallenge()).called(1);
      verify(() => mockLocal.cacheMonthlyChallenge(sampleChallengeDto)).called(1);
    });

    test('getMonthlyChallenge falls back to stale cache on network failure', () async {
      when(() => mockLocal.isCacheFresh('challenges_monthly')).thenReturn(false);
      when(() => mockRemote.getMonthlyChallenge()).thenThrow(const NetworkException('No connection'));
      when(() => mockLocal.getCachedMonthlyChallenge()).thenAnswer((_) async => sampleChallengeDto);

      final result = await repository.getMonthlyChallenge(forceRefresh: true);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.id, 'ch_test');
    });

    test('getQuickQuizzes returns cached items if fresh', () async {
      when(() => mockLocal.isCacheFresh('challenges_quizzes')).thenReturn(true);
      when(() => mockLocal.getCachedQuickQuizzes()).thenAnswer((_) async => sampleQuizzesDto);

      final result = await repository.getQuickQuizzes();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.length, 1);
      verifyNever(() => mockRemote.getQuickQuizzes());
    });

    test('getObjectionOfTheMonth returns cached objection if fresh', () async {
      when(() => mockLocal.isCacheFresh('challenges_objection')).thenReturn(true);
      when(() => mockLocal.getCachedObjection()).thenAnswer((_) async => sampleObjectionDto);

      final result = await repository.getObjectionOfTheMonth();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.doctorName, 'Dr. Tarek');
    });

    test('submitQuizAnswers returns server result and caches completion without inventing points', () async {
      when(() => mockLocal.isCacheFresh('challenges_quizzes')).thenReturn(false);
      when(() => mockRemote.getQuickQuizzes()).thenAnswer((_) async => sampleQuizzesDto);
      when(() => mockLocal.cacheQuickQuizzes(any())).thenAnswer((_) async {});
      await repository.getQuickQuizzes(forceRefresh: true);

      when(() => mockRemote.submitQuizAnswers(
            quizId: 'quiz_1',
            answers: any(named: 'answers'),
          )).thenAnswer(
        (_) async => const QuizSubmissionResultDto(
          attemptId: 'att_server_1',
          score: 100,
          isPassed: true,
          passingScore: 70,
          pointsAwarded: 75,
          answers: [
            QuizAnswerEvaluationDto(
              questionId: 'q1',
              isCorrect: true,
            ),
          ],
        ),
      );

      final result = await repository.submitQuizAnswers(
        quizId: 'quiz_1',
        answers: const [
          {'questionId': 'q1', 'selectedOptionId': 'opt_a'},
        ],
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.attemptId, 'att_server_1');
      expect(result.dataOrNull?.pointsAwarded, 75);
      expect(result.dataOrNull?.isPassed, isTrue);

      final quizzesRes = await repository.getQuickQuizzes();
      expect(quizzesRes.dataOrNull?.first.isCompleted, isTrue);
    });

    test('submitQuizAnswers returns failure on server error without marking quiz completed', () async {
      when(() => mockLocal.isCacheFresh('challenges_quizzes')).thenReturn(false);
      when(() => mockRemote.getQuickQuizzes()).thenAnswer((_) async => sampleQuizzesDto);
      when(() => mockLocal.cacheQuickQuizzes(any())).thenAnswer((_) async {});
      await repository.getQuickQuizzes(forceRefresh: true);

      when(() => mockRemote.submitQuizAnswers(
            quizId: 'quiz_1',
            answers: any(named: 'answers'),
          )).thenThrow(const ServerException('500 Error', statusCode: 500));

      final result = await repository.submitQuizAnswers(
        quizId: 'quiz_1',
        answers: const [
          {'questionId': 'q1', 'selectedOptionId': 'opt_a'},
        ],
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ServerFailure>());

      final quizzesRes = await repository.getQuickQuizzes();
      expect(quizzesRes.dataOrNull?.first.isCompleted, isFalse);
    });

    test('submitQuizAnswers marks quiz completed on 409 conflict failure', () async {
      when(() => mockLocal.isCacheFresh('challenges_quizzes')).thenReturn(false);
      when(() => mockRemote.getQuickQuizzes()).thenAnswer((_) async => sampleQuizzesDto);
      when(() => mockLocal.cacheQuickQuizzes(any())).thenAnswer((_) async {});
      await repository.getQuickQuizzes(forceRefresh: true);

      when(() => mockRemote.submitQuizAnswers(
            quizId: 'quiz_1',
            answers: any(named: 'answers'),
          )).thenThrow(
        const ServerException('ATTEMPT_ALREADY_EXISTS', statusCode: 409),
      );

      final result = await repository.submitQuizAnswers(
        quizId: 'quiz_1',
        answers: const [
          {'questionId': 'q1', 'selectedOptionId': 'opt_a'},
        ],
      );

      expect(result.isFailure, isTrue);
      final quizzesRes = await repository.getQuickQuizzes();
      expect(quizzesRes.dataOrNull?.first.isCompleted, isTrue);
    });

    test('ChallengesRemoteDatasourceImpl without dio throws ServerException instead of local fake result', () async {
      final remote = ChallengesRemoteDatasourceImpl();
      await expectLater(
        () => remote.submitQuizAnswers(
          quizId: 'quiz_1',
          answers: const [
            {'questionId': 'q1', 'selectedOptionId': 'opt_a'},
          ],
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('submitDoctorObjectionResponse queues offline when remote fails', () async {
      when(() => mockRemote.submitDoctorObjectionResponse('obj_1', 'Field response text'))
          .thenThrow(const NetworkException('Offline'));
      when(() => mockLocal.queueDoctorObjectionResponse(
            objectionId: 'obj_1',
            userResponse: 'Field response text',
          )).thenAnswer((_) async {});

      final result = await repository.submitDoctorObjectionResponse(
        objectionId: 'obj_1',
        userResponse: 'Field response text',
      );

      expect(result.isSuccess, isTrue);
      verify(() => mockLocal.queueDoctorObjectionResponse(
            objectionId: 'obj_1',
            userResponse: 'Field response text',
          )).called(1);
    });
  });
}
