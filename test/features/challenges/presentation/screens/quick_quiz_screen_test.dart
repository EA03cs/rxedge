import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/core/widgets/widgets.dart';
import 'package:rxedge/features/challenges/data/repositories/challenges_repository_impl.dart';
import 'package:rxedge/features/challenges/domain/entities/challenges_entities.dart';
import 'package:rxedge/features/challenges/domain/repositories/challenges_repository.dart';
import 'package:rxedge/features/challenges/presentation/screens/quick_quiz_screen.dart';

class MockChallengesRepository extends Mock implements ChallengesRepository {}

void main() {
  late MockChallengesRepository mockRepo;

  const sampleQuiz = QuickQuizEntity(
    id: 'quiz_test',
    title: 'Cardura XL Clinical Recall',
    category: 'Hypertension',
    durationMinutes: 2,
    rewardPoints: 50,
    questions: [
      QuizQuestionEntity(
        id: 'q1',
        question: 'What is the primary GITS pharmacokinetic advantage?',
        options: [
          'High 2-hour peak plasma spikes',
          'Consistent 24-hour plasma plateau with zero spikes',
        ],
        correctOptionIndex: 1,
        explanation: 'GITS osmotic pump ensures constant zero-order delivery.',
      ),
      QuizQuestionEntity(
        id: 'q2',
        question: 'What is the standard starting dose?',
        options: [
          '4mg once daily taken with breakfast',
          '16mg divided twice daily',
        ],
        correctOptionIndex: 0,
        explanation: 'Standard starting dose is 4mg once daily with food.',
      ),
    ],
  );

  setUp(() {
    mockRepo = MockChallengesRepository();
    when(() => mockRepo.submitQuizResult(
          quizId: any(named: 'quizId'),
          score: any(named: 'score'),
          totalQuestions: any(named: 'totalQuestions'),
          timeTakenSeconds: any(named: 'timeTakenSeconds'),
        )).thenAnswer(
      (_) async => Result.success(
        QuizResultHistoryEntity(
          id: 'res_1',
          quizId: 'quiz_test',
          quizTitle: 'Cardura XL Clinical Recall',
          score: 2,
          totalQuestions: 2,
          pointsEarned: 50,
          timeTakenSeconds: 30,
          completedAt: DateTime.now(),
        ),
      ),
    );
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        challengesRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const MaterialApp(
        themeMode: ThemeMode.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: QuickQuizScreen(quiz: sampleQuiz),
      ),
    );
  }

  group('QuickQuizScreen Widget Tests', () {
    testWidgets('executes interactive quiz flow with immediate feedback and result screen',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Question 1
      expect(find.text('Question 1 of 2'), findsOneWidget);
      expect(find.byType(ProgressBar), findsOneWidget);
      expect(find.text('What is the primary GITS pharmacokinetic advantage?'), findsOneWidget);
      expect(find.text('Consistent 24-hour plasma plateau with zero spikes'), findsOneWidget);

      // Select Option B (Correct)
      await tester.tap(find.text('Consistent 24-hour plasma plateau with zero spikes'));
      await tester.pumpAndSettle();

      // Immediate feedback appears
      expect(find.text('Correct Recall'), findsOneWidget);
      expect(find.text('GITS osmotic pump ensures constant zero-order delivery.'), findsOneWidget);
      expect(find.text('Next Question'), findsOneWidget);

      // Tap Next Question
      await tester.tap(find.text('Next Question'));
      await tester.pumpAndSettle();

      // Question 2
      expect(find.text('Question 2 of 2'), findsOneWidget);
      expect(find.text('What is the standard starting dose?'), findsOneWidget);

      // Select Option A (Correct)
      await tester.tap(find.text('4mg once daily taken with breakfast'));
      await tester.pumpAndSettle();

      expect(find.text('Finish Quiz'), findsOneWidget);

      // Tap Finish Quiz
      await tester.tap(find.text('Finish Quiz'));
      await tester.pumpAndSettle();

      // Result Screen Score Card
      expect(find.text('Quiz Completed'), findsOneWidget);
      expect(find.text('Clinical Mastery Achieved'), findsOneWidget); // High score subtle celebration
      expect(find.text('2 of 2 Questions Correct'), findsOneWidget);
      expect(find.text('+30 Marks'), findsOneWidget); // 2*10 + 10 bonus

      // Per-Question Breakdown for ALL questions rendered immediately
      expect(find.text('Questions Breakdown'), findsOneWidget);
      expect(find.text('All (2)'), findsOneWidget);
      expect(find.text('Incorrect only (0)'), findsOneWidget);
      expect(find.text('Question 1'), findsOneWidget);
      expect(find.text('Question 2'), findsOneWidget);
      expect(find.text('Correct'), findsNWidgets(2)); // Dual indicator label
      expect(find.text('Your answer: Consistent 24-hour plasma plateau with zero spikes'), findsOneWidget);
      expect(find.text('Your answer: 4mg once daily taken with breakfast'), findsOneWidget);
      expect(find.text('Clinical Explanation'), findsNWidgets(2));

      // 3 Actions Present
      expect(find.text('Review Mistakes'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Back to Challenges'), findsOneWidget);

      // Tap Review Mistakes / filter to incorrect
      await tester.tap(find.text('Review Mistakes'));
      await tester.pumpAndSettle();

      expect(find.text('Flawless! Zero incorrect answers to review.'), findsOneWidget);
    });

    testWidgets('shows incorrect answer breakdown with dual indicators and filters dynamically',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Q1: Select Option B (Correct)
      await tester.tap(find.text('Consistent 24-hour plasma plateau with zero spikes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next Question'));
      await tester.pumpAndSettle();

      // Q2: Select Option B (Incorrect: correct is 4mg)
      await tester.tap(find.text('16mg divided twice daily'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finish Quiz'));
      await tester.pumpAndSettle();

      // Result Screen
      expect(find.text('1 of 2 Questions Correct'), findsOneWidget);
      expect(find.text('Questions Breakdown'), findsOneWidget);
      expect(find.text('All (2)'), findsOneWidget);
      expect(find.text('Incorrect only (1)'), findsOneWidget);

      // Check Q1 (Correct)
      expect(find.text('Question 1'), findsOneWidget);
      expect(find.text('Correct'), findsOneWidget);

      // Check Q2 (Incorrect) with dual indicators (label + icon) and correct answer
      expect(find.text('Question 2'), findsOneWidget);
      expect(find.text('Incorrect'), findsOneWidget);
      expect(find.text('Your answer: 16mg divided twice daily'), findsOneWidget);
      expect(find.text('Correct answer: 4mg once daily taken with breakfast'), findsOneWidget);
      expect(find.text('Standard starting dose is 4mg once daily with food.'), findsOneWidget);

      // Switch Filter to Incorrect only
      await tester.tap(find.text('Incorrect only (1)'));
      await tester.pumpAndSettle();

      // Now only Question 2 is visible
      expect(find.text('Question 1'), findsNothing);
      expect(find.text('Question 2'), findsOneWidget);

      // Switch Filter back to All
      await tester.tap(find.text('All (2)'));
      await tester.pumpAndSettle();

      // Both questions visible again
      expect(find.text('Question 1'), findsOneWidget);
      expect(find.text('Question 2'), findsOneWidget);
    });

    testWidgets('renders English breakdown with dual indicators and correct labels',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(ProviderScope(
        overrides: [
          challengesRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: QuickQuizScreen(quiz: sampleQuiz),
        ),
      ));
      await tester.pumpAndSettle();

      // Answer Q1
      await tester.tap(find.text('Consistent 24-hour plasma plateau with zero spikes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next Question'));
      await tester.pumpAndSettle();

      // Answer Q2
      await tester.tap(find.text('4mg once daily taken with breakfast'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finish Quiz'));
      await tester.pumpAndSettle();

      // Verify English Breakdown
      expect(find.text('Questions Breakdown'), findsOneWidget);
      expect(find.text('All (2)'), findsOneWidget);
      expect(find.text('Incorrect only (0)'), findsOneWidget);
      expect(find.text('Question 1'), findsOneWidget);
      expect(find.text('Question 2'), findsOneWidget);
      expect(find.text('Correct'), findsNWidgets(2));
      expect(find.text('Clinical Explanation'), findsNWidgets(2));
    });

    testWidgets('opens completed attempt review directly in breakdown mode',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const minimalQuiz = QuickQuizEntity(
        id: 'quiz-done',
        title: 'Rohto Dry Aid Review Quiz',
        category: 'Ophthalmology',
        durationMinutes: 3,
        rewardPoints: 50,
        isCompleted: true,
        questions: [],
      );

      const reviewResult = QuizSubmissionResultEntity(
        attemptId: 'att-done',
        scorePercentage: 50,
        isPassed: false,
        passingScore: 70,
        pointsAwarded: 0,
        answers: [
          QuizAnswerEvaluationEntity(
            questionId: 'q1',
            questionText: 'How long does Rohto Dry Aid relieve dryness?',
            selectedOptionId: 'o1',
            selectedOptionText: 'Up to 12 hours',
            correctOptionId: 'o1',
            correctOptionText: 'Up to 12 hours',
            isCorrect: true,
            explanation: 'Lasts up to 12 hours.',
          ),
          QuizAnswerEvaluationEntity(
            questionId: 'q2',
            questionText: 'How long can Rohto Dry Aid be kept after opening?',
            selectedOptionId: 'o3',
            selectedOptionText: '1 month',
            correctOptionId: 'o4',
            correctOptionText: '3 months',
            isCorrect: false,
            explanation: 'Discard 3 months after first opening.',
          ),
        ],
      );

      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: [Locale('en')],
          home: QuickQuizScreen(
            quiz: minimalQuiz,
            initialReviewResult: reviewResult,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Rohto Dry Aid Review Quiz'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('How long does Rohto Dry Aid relieve dryness?'), findsOneWidget);
      expect(find.text('How long can Rohto Dry Aid be kept after opening?'), findsOneWidget);
      expect(find.text('Discard 3 months after first opening.'), findsOneWidget);
      expect(find.text('All (2)'), findsOneWidget);
      expect(find.text('Incorrect only (1)'), findsOneWidget);

      await tester.tap(find.text('Incorrect only (1)'));
      await tester.pumpAndSettle();

      expect(find.text('How long does Rohto Dry Aid relieve dryness?'), findsNothing);
      expect(find.text('How long can Rohto Dry Aid be kept after opening?'), findsOneWidget);
    });

    testWidgets(
        'auto-opens completed attempt review when quiz.isCompleted is true',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const completedQuiz = QuickQuizEntity(
        id: 'quiz-already-done',
        title: 'Rohto Dry Aid Attempted Quiz',
        category: 'Ophthalmology',
        durationMinutes: 3,
        rewardPoints: 50,
        isCompleted: true,
        questions: [],
      );

      const reviewResult = QuizSubmissionResultEntity(
        attemptId: 'att-prev',
        scorePercentage: 100,
        isPassed: true,
        passingScore: 70,
        pointsAwarded: 50,
        answers: [
          QuizAnswerEvaluationEntity(
            questionId: 'q1',
            questionText: 'What technology powers Rohto Dry Aid?',
            selectedOptionId: 'o1',
            selectedOptionText: 'Tearshield Technology',
            correctOptionId: 'o1',
            correctOptionText: 'Tearshield Technology',
            isCorrect: true,
            explanation: 'Works on all layers of the tear film.',
          ),
        ],
      );

      when(() => mockRepo.getQuizAttemptReview('quiz-already-done'))
          .thenAnswer((_) async => const Result.success(reviewResult));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            challengesRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: [Locale('en')],
            home: QuickQuizScreen(quiz: completedQuiz),
          ),
        ),
      );
      await tester.pumpAndSettle();

      verify(() => mockRepo.getQuizAttemptReview('quiz-already-done')).called(1);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('What technology powers Rohto Dry Aid?'), findsOneWidget);
    });

    testWidgets(
        'recovers gracefully on 409 single-attempt conflict by showing saved review',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const serverQuiz = QuickQuizEntity(
        id: 'quiz-409',
        title: 'Rohto Cool Clinical Quiz',
        category: 'Ophthalmology',
        durationMinutes: 3,
        rewardPoints: 40,
        isCompleted: false,
        questions: [
          QuizQuestionEntity(
            id: 'q1',
            question: 'Which patients benefit from Rohto Cool?',
            options: ['Contact lens wearers & screen fatigue', 'None'],
            optionIds: ['opt1', 'opt2'],
            correctOptionIndex: -1,
            explanation: '',
          ),
        ],
      );

      const reviewResult = QuizSubmissionResultEntity(
        attemptId: 'att-409',
        scorePercentage: 100,
        isPassed: true,
        passingScore: 70,
        pointsAwarded: 40,
        answers: [
          QuizAnswerEvaluationEntity(
            questionId: 'q1',
            questionText: 'Which patients benefit from Rohto Cool?',
            selectedOptionId: 'opt1',
            selectedOptionText: 'Contact lens wearers & screen fatigue',
            correctOptionId: 'opt1',
            correctOptionText: 'Contact lens wearers & screen fatigue',
            isCorrect: true,
            explanation: 'Refreshes tired eyes and supports lens comfort.',
          ),
        ],
      );

      when(() => mockRepo.submitQuizAnswers(
            quizId: 'quiz-409',
            answers: any(named: 'answers'),
          )).thenAnswer(
        (_) async => const Result.failure(
          ServerFailure(
            statusCode: 409,
            debugMessage: 'You have already completed your single attempt for this quiz',
          ),
        ),
      );
      when(() => mockRepo.getQuizAttemptReview('quiz-409'))
          .thenAnswer((_) async => const Result.success(reviewResult));
      when(() => mockRepo.getQuickQuizzes(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => const Result.success([]));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            challengesRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: [Locale('en')],
            home: QuickQuizScreen(quiz: serverQuiz),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Contact lens wearers & screen fatigue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finish Quiz'));
      await tester.pumpAndSettle();

      expect(find.text('100%'), findsOneWidget);
      expect(
        find.text('Refreshes tired eyes and supports lens comfort.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'You have already attempted this quiz. Retakes are not permitted per challenge policy.',
        ),
        findsOneWidget,
      );
    });
  });
}
