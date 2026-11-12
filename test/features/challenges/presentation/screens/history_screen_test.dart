import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/challenges/data/repositories/challenges_repository_impl.dart';
import 'package:rxedge/features/challenges/domain/entities/challenges_entities.dart';
import 'package:rxedge/features/challenges/domain/repositories/challenges_repository.dart';
import 'package:rxedge/features/challenges/presentation/screens/history_screen.dart';

class MockChallengesRepository extends Mock implements ChallengesRepository {}

void main() {
  late MockChallengesRepository mockRepo;

  final samplePastChallenges = [
    PastChallengeHistoryEntity(
      id: 'past_1',
      title: 'October Hypertension Master Sprint',
      completedAt: DateTime(2026, 10, 31),
      finalRank: 2,
      totalParticipants: 32,
      pointsEarned: 450,
      badgeEarned: 'Silver District Performer',
    ),
  ];

  final sampleQuizResults = [
    QuizResultHistoryEntity(
      id: 'res_hist_1',
      quizId: 'quiz_1',
      quizTitle: 'Cardura XL ABPM Study',
      score: 4,
      totalQuestions: 4,
      pointsEarned: 50,
      timeTakenSeconds: 94,
      completedAt: DateTime(2026, 11, 7),
    ),
  ];

  setUp(() {
    mockRepo = MockChallengesRepository();
    when(() => mockRepo.getPastChallengesHistory())
        .thenAnswer((_) async => Result.success(samplePastChallenges));
    when(() => mockRepo.getQuizResultsHistory())
        .thenAnswer((_) async => Result.success(sampleQuizResults));
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
        home: HistoryScreen(),
      ),
    );
  }

  group('HistoryScreen Widget Tests', () {
    testWidgets('renders past challenges and switches to quiz results tab', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Past Challenges Tab is active
      expect(find.text('Past Challenges'), findsOneWidget);
      expect(find.text('Quiz Results'), findsOneWidget);

      expect(find.text('October Hypertension Master Sprint'), findsOneWidget);
      expect(find.text('+450 Pts'), findsOneWidget);
      expect(find.text('Rank #2 of 32'), findsOneWidget);
      expect(find.text('Silver District Performer'), findsOneWidget);

      // Switch to Quiz Results Tab
      await tester.tap(find.text('Quiz Results'));
      await tester.pumpAndSettle();

      expect(find.text('Cardura XL ABPM Study'), findsOneWidget);
      expect(find.text('+50 Pts'), findsOneWidget);
      expect(find.text('4/4 • 94s'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });
  });
}
