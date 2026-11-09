import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
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

      // Result Screen
      expect(find.text('Quiz Completed'), findsOneWidget);
      expect(find.text('Clinical Mastery Achieved'), findsOneWidget); // High score subtle celebration
      expect(find.text('2 of 2 Questions Correct'), findsOneWidget);
      expect(find.text('+30 Pts'), findsOneWidget); // 2*10 + 10 bonus

      // 3 Actions Present
      expect(find.text('Review Mistakes'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Back to Challenges'), findsOneWidget);

      // Tap Review Mistakes
      await tester.tap(find.text('Review Mistakes'));
      await tester.pumpAndSettle();

      expect(find.text('Flawless! Zero incorrect answers to review.'), findsOneWidget);
    });
  });
}
