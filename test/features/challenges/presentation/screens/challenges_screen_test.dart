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
import 'package:rxedge/features/challenges/presentation/screens/challenges_screen.dart';

class MockChallengesRepository extends Mock implements ChallengesRepository {}

void main() {
  late MockChallengesRepository mockRepo;

  final sampleChallenge = MonthlyChallengeEntity(
    id: 'ch_test',
    title: 'Cardiovascular Blitz: Q4 Master',
    deadline: DateTime.now().add(const Duration(days: 4, hours: 10)),
    rules: const [
      'Complete all 3 core clinical quick quizzes with >= 80% passing score.',
      'Review monthly physician objection and formulate clinical talking points.',
      'Top 3 district performers receive District Spotlight recognition.',
    ],
    currentProgress: 0.72,
    completedMilestones: 5,
    totalMilestones: 7,
    userRank: 3,
    totalParticipants: 34,
    rewards: const ['Spotlight Badge', '+500 Pts'],
    leaderboard: const [
      LeaderboardEntry(
        rank: 1,
        repName: 'Sarah Jenkins',
        territory: 'North District',
        points: 1420,
      ),
      LeaderboardEntry(
        rank: 2,
        repName: 'Ahmed Mansour',
        territory: 'East District',
        points: 1380,
      ),
      LeaderboardEntry(
        rank: 3,
        repName: 'Alex Mercer',
        territory: 'Central District',
        points: 1250,
        isCurrentUser: true,
      ),
    ],
  );

  final sampleQuizzes = [
    const QuickQuizEntity(
      id: 'quiz_1',
      title: 'Cardura XL ABPM Study',
      category: 'Hypertension',
      durationMinutes: 3,
      rewardPoints: 50,
      questions: [
        QuizQuestionEntity(
          id: 'q1',
          question: 'What is GITS advantage?',
          options: ['Option A', 'Option B'],
          correctOptionIndex: 0,
          explanation: 'Smooth 24h plateau.',
        ),
      ],
    ),
  ];

  const sampleObjection = ObjectionOfTheMonthEntity(
    id: 'obj_1',
    doctorQuote: 'Why switch patients from Amlodipine to Cardura XL?',
    doctorName: 'Dr. Tarek El-Khouly',
    doctorSpecialty: 'Consultant Cardiologist',
    productConcerned: 'Cardura XL',
    recommendedResponse: 'Highlight continuous 24h control without peripheral edema.',
    talkingPoints: ['Acknowledge efficacy', 'Contrast edema rates'],
    studyReference: 'ASCOT-BPLA Trial Sub-analysis',
    helpfulCount: 48,
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

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        challengesRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const MaterialApp(
        themeMode: ThemeMode.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChallengesScreen(),
      ),
    );
  }

  group('ChallengesScreen Widget Tests', () {
    testWidgets('renders 3-section segmented control and monthly challenge content', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 3 Segments
      expect(find.text('Monthly Challenge'), findsOneWidget);
      expect(find.text('Quick Quizzes'), findsOneWidget);
      expect(find.text('Objection of Month'), findsOneWidget);

      // Monthly Challenge Card
      expect(find.text('Cardiovascular Blitz: Q4 Master'), findsOneWidget);
      expect(find.text('Challenge Rules'), findsOneWidget);
      expect(find.text('5/7 Milestones'), findsOneWidget);
      expect(find.text('Territory Leaderboard'), findsOneWidget);
      expect(find.text('My Rank'), findsOneWidget);
      expect(find.text('Sarah Jenkins'), findsOneWidget);
      expect(find.text('1,250 Pts'), findsWidgets);
    });

    testWidgets('switching to Quick Quizzes segment shows quizzes list', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Quick Quizzes segment
      await tester.tap(find.text('Quick Quizzes'));
      await tester.pumpAndSettle();

      expect(find.text('Cardura XL ABPM Study'), findsOneWidget);
      expect(find.text('+50 Pts'), findsOneWidget);
      expect(find.text('Start Quiz'), findsOneWidget);
    });

    testWidgets('switching to Objection of Month segment shows objection and think first', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Objection segment
      await tester.tap(find.text('Objection of Month'));
      await tester.pumpAndSettle();

      expect(find.text('Why switch patients from Amlodipine to Cardura XL?'), findsOneWidget);
      expect(find.text('Dr. Tarek El-Khouly'), findsOneWidget);
      expect(find.text('Think First'), findsOneWidget);
      expect(find.text('Reveal Recommended Response'), findsOneWidget);

      // Tap Reveal
      await tester.tap(find.text('Reveal Recommended Response'));
      await tester.pumpAndSettle();

      expect(find.text('Recommended Clinical Response'), findsOneWidget);
      expect(find.text('Highlight continuous 24h control without peripheral edema.'), findsOneWidget);
      expect(find.text('Was this response helpful?'), findsOneWidget);
    });

    testWidgets('renders ErrorState with retry on initial failure', (tester) async {
      when(() => mockRepo.getMonthlyChallenge(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => const Result.failure(ServerFailure(debugMessage: 'Server unreachable')));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}
