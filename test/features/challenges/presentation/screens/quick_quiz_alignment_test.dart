import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/challenges/data/repositories/challenges_repository_impl.dart';
import 'package:rxedge/features/challenges/domain/entities/challenges_entities.dart';
import 'package:rxedge/features/challenges/domain/repositories/challenges_repository.dart';
import 'package:rxedge/features/challenges/presentation/screens/quick_quiz_screen.dart';
import 'package:rxedge/features/challenges/presentation/widgets/quick_quizzes_view.dart';

class MockChallengesRepository extends Mock implements ChallengesRepository {}

void main() {
  late MockChallengesRepository mockRepo;

  const sampleRohtoQuiz = QuickQuizEntity(
    id: 'quiz-rohto-dry-aid',
    title: 'Rohto Dry Aid Clinical Challenge',
    category: 'Ophthalmology',
    durationMinutes: 3,
    rewardPoints: 100,
    isCompleted: true, // Marked as completed
    lastScore: 90,
    lastMaxScore: 100,
    questions: [
      QuizQuestionEntity(
        id: 'q1',
        question: 'What is the passmark for monthly Eye-Know challenges?',
        options: [
          '50% minimum',
          '70% minimum',
          '90% minimum',
        ],
        correctOptionIndex: 1,
        explanation: 'According to RxEdge Academy rules, passmark is minimum 70%.',
      ),
    ],
  );

  setUp(() {
    mockRepo = MockChallengesRepository();
  });

  Widget buildEnglishQuizzesView(List<QuickQuizEntity> quizzes) {
    return ProviderScope(
      overrides: [
        challengesRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        themeMode: ThemeMode.light,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: QuickQuizzesView(quizzes: quizzes),
        ),
      ),
    );
  }

  Widget buildEnglishQuizScreen(QuickQuizEntity quiz) {
    return ProviderScope(
      overrides: [
        challengesRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        themeMode: ThemeMode.light,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: QuickQuizScreen(quiz: quiz),
      ),
    );
  }

  group('Eye-Know Challenges Automated Tests (Module 3)', () {
    testWidgets('enforces single attempt lock on completed quiz in QuickQuizzesView', (tester) async {
      await tester.pumpWidget(buildEnglishQuizzesView([sampleRohtoQuiz]));
      await tester.pumpAndSettle();

      // Policy banner
      expect(
        find.text('Challenge policy: exactly one attempt permitted per participant, no retakes.'),
        findsOneWidget,
      );

      // Card Title & Category
      expect(find.text('Rohto Dry Aid Clinical Challenge'), findsOneWidget);

      // Single attempt locked button
      expect(find.text('Completed (Single Attempt)'), findsOneWidget);

      // Tapping the locked button should NOT open the quiz screen
      await tester.tap(find.text('Completed (Single Attempt)'));
      await tester.pumpAndSettle();

      expect(find.text('Question 1 of 1'), findsNothing);
    });

    testWidgets('handles 409 Conflict (ATTEMPT_ALREADY_EXISTS) with friendly snackbar',
        (tester) async {
      when(() => mockRepo.submitQuizAnswers(
            quizId: any(named: 'quizId'),
            answers: any(named: 'answers'),
          )).thenAnswer(
        (_) async => const Result.failure(
          ServerFailure(
            statusCode: 409,
            debugMessage: 'ATTEMPT_ALREADY_EXISTS',
          ),
        ),
      );

      const activeQuiz = QuickQuizEntity(
        id: 'quiz-active',
        title: 'Active Quiz',
        category: 'Ophthalmology',
        durationMinutes: 3,
        rewardPoints: 100,
        isCompleted: false,
        questions: [
          QuizQuestionEntity(
            id: 'q1',
            question: 'What is the passmark?',
            options: ['50%', '70%'],
            optionIds: ['opt_1', 'opt_2'],
            correctOptionIndex: -1, // Server-evaluated: correct index is hidden from client
            explanation: '',
          ),
        ],
      );

      await tester.pumpWidget(buildEnglishQuizScreen(activeQuiz));
      await tester.pumpAndSettle();

      // Select an option
      await tester.tap(find.text('70%'));
      await tester.pumpAndSettle();

      // Tap Finish
      await tester.tap(find.text('Finish Quiz'));
      await tester.pump(); // Start submission
      await tester.pump(const Duration(milliseconds: 300)); // Complete async call

      // Verify friendly 409 message appears in English
      expect(
        find.text(
          'You have already attempted this quiz. Retakes are not permitted per challenge policy.',
        ),
        findsOneWidget,
      );
    });
  });
}
