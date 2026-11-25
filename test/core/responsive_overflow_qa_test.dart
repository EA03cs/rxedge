import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/app/theme/theme.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/challenges/data/repositories/challenges_repository_impl.dart';
import 'package:rxedge/features/challenges/domain/entities/challenges_entities.dart';
import 'package:rxedge/features/challenges/domain/repositories/challenges_repository.dart';
import 'package:rxedge/features/challenges/presentation/screens/quick_quiz_screen.dart';
import 'package:rxedge/features/challenges/presentation/widgets/monthly_challenge_view.dart';
import 'package:rxedge/features/challenges/presentation/widgets/quick_quizzes_view.dart';
import 'package:rxedge/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:rxedge/features/feedback/domain/entities/feedback_entities.dart';
import 'package:rxedge/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:rxedge/features/feedback/presentation/screens/feedback_detail_screen.dart';
import 'package:rxedge/features/feedback/presentation/screens/feedback_form_screen.dart';
import 'package:rxedge/features/learn/data/datasources/rohto_seed_data.dart';
import 'package:rxedge/features/learn/data/repositories/learn_repository_impl.dart';
import 'package:rxedge/features/learn/domain/repositories/learn_repository.dart';
import 'package:rxedge/features/learn/presentation/screens/product_learning_screen.dart';
import 'package:rxedge/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:rxedge/features/notifications/domain/entities/notification_entities.dart';
import 'package:rxedge/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:rxedge/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:rxedge/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:rxedge/features/profile/domain/entities/profile_entities.dart';
import 'package:rxedge/features/profile/domain/repositories/profile_repository.dart';
import 'package:rxedge/features/profile/presentation/screens/profile_screen.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockLearnRepository extends Mock implements LearnRepository {}

class MockFeedbackRepository extends Mock implements FeedbackRepository {}

class MockChallengesRepository extends Mock implements ChallengesRepository {}

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

void main() {
  late MockProfileRepository mockProfileRepo;
  late MockLearnRepository mockLearnRepo;
  late MockFeedbackRepository mockFeedbackRepo;
  late MockChallengesRepository mockChallengesRepo;
  late MockNotificationsRepository mockNotifsRepo;

  final rohtoProducts =
      RohtoSeedData.products.map((dto) => dto.toDomain()).toList();

  setUp(() {
    mockProfileRepo = MockProfileRepository();
    mockLearnRepo = MockLearnRepository();
    mockFeedbackRepo = MockFeedbackRepository();
    mockChallengesRepo = MockChallengesRepository();
    mockNotifsRepo = MockNotificationsRepository();

    when(() => mockProfileRepo.getProfile()).thenAnswer(
      (_) async => Result.success(
        UserProfileEntity(
          id: 'usr_qa_1',
          displayName: 'Sara El-Sayed Abdelrahman',
          email: 'sara.elsayed@mentholatum.com',
          employeeId: 'MR-2048',
          territory: 'Greater Cairo & East Delta Territory',
          role: 'Senior Ophthalmology Medical Representative',
          points: 1250,
          streakDays: 6,
          badges: [
            BadgeEntity(
              id: 'b1',
              name: 'Ophthalmology Champion',
              description: 'Completed Rohto modules',
              earnedAt: DateTime(2026, 10, 10),
            ),
          ],
          notificationPreferences: const NotificationPreferencesEntity(),
          storageUsageBytes: 25800000,
        ),
      ),
    );

    when(() => mockLearnRepo.getProducts(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => Result.success(rohtoProducts));

    when(() => mockFeedbackRepo.getDraft(FeedbackType.doctorObjection))
        .thenAnswer((_) async => const Result.success(null));
  });

  Widget wrapCompact({
    required Widget child,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: RxTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('en')],
        builder: (context, widget) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.3),
          ),
          child: widget!,
        ),
        home: child,
      ),
    );
  }

  void configureSmallPhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('Responsive & Large Text Scale QA (320px @ 1.3x)', () {
    testWidgets('Mentholatum brand token check', (tester) async {
      expect(RxColors.light.primary, const Color(0xFF005CA8));
      expect(RxColors.light.accent, const Color(0xFFE62134));
    });

    testWidgets('ProfileScreen renders without overflow on 320px at 1.3x scale',
        (tester) async {
      configureSmallPhone(tester);
      await tester.pumpWidget(
        wrapCompact(
          overrides: [profileRepositoryProvider.overrideWithValue(mockProfileRepo)],
          child: const ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'ProductLearningScreen renders without overflow on 320px at 1.3x scale',
        (tester) async {
      configureSmallPhone(tester);
      await tester.pumpWidget(
        wrapCompact(
          overrides: [learnRepositoryProvider.overrideWithValue(mockLearnRepo)],
          child: ProductLearningScreen(product: rohtoProducts.first),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'FeedbackFormScreen renders without overflow on 320px at 1.3x scale',
        (tester) async {
      configureSmallPhone(tester);
      await tester.pumpWidget(
        wrapCompact(
          overrides: [
            learnRepositoryProvider.overrideWithValue(mockLearnRepo),
            feedbackRepositoryProvider.overrideWithValue(mockFeedbackRepo),
          ],
          child: const FeedbackFormScreen(type: FeedbackType.doctorObjection),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'FeedbackDetailScreen renders without overflow on 320px at 1.3x scale',
        (tester) async {
      configureSmallPhone(tester);
      when(() => mockFeedbackRepo.getSubmissions(
              forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer(
        (_) async => Result.success([
          FeedbackItemEntity(
            id: 'fb_qa_1',
            type: FeedbackType.competitorClaim,
            title: 'Competitor preservative claim check',
            submittedAt: DateTime(2026, 11, 10, 14, 30),
            status: FeedbackStatus.answered,
            competitorName: 'Competitor Drops',
            claim: 'Claimed longer hydration without clinical study support',
            marketingReply:
                'Emphasize Rohto Dry Aid Tearshield technology up to 12 hours.',
          ),
        ]),
      );

      await tester.pumpWidget(
        wrapCompact(
          overrides: [
            feedbackRepositoryProvider.overrideWithValue(mockFeedbackRepo),
          ],
          child: const FeedbackDetailScreen(submissionId: 'fb_qa_1'),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'MonthlyChallengeView renders without overflow at 320px/1.3x',
        (tester) async {
      configureSmallPhone(tester);
      final challenge = MonthlyChallengeEntity(
        id: 'ch_qa',
        title: 'Q4 Rohto Dry Aid Tearshield Challenge',
        deadline: DateTime.now().add(const Duration(days: 5)),
        rules: const ['Score at least 70%', 'Submit one attempt'],
        currentProgress: 0.5,
        completedMilestones: 1,
        totalMilestones: 2,
        userRank: 12,
        totalParticipants: 45,
        rewards: const ['50 Challenge Marks on completion'],
        leaderboard: const [
          LeaderboardEntry(
            rank: 1,
            repName: 'Ahmed Hassan',
            territory: 'Cairo West',
            points: 100,
            isCurrentUser: false,
          ),
        ],
      );

      await tester.pumpWidget(
        wrapCompact(
          child: Scaffold(
            body: MonthlyChallengeView(challenge: challenge),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'QuickQuizzesView renders without overflow at 320px/1.3x',
        (tester) async {
      configureSmallPhone(tester);
      const quiz = QuickQuizEntity(
        id: 'q_qa',
        title: 'Rohto Dry Aid Comprehensive Clinical Assessment',
        category: 'Rohto Ophthalmology',
        durationMinutes: 5,
        rewardPoints: 50,
        completionWindowDays: 5,
        isCompleted: true,
        lastScore: 4,
        lastMaxScore: 5,
        questions: [],
      );

      await tester.pumpWidget(
        wrapCompact(
          overrides: [
            challengesRepositoryProvider.overrideWithValue(mockChallengesRepo),
          ],
          child: const Scaffold(
            body: QuickQuizzesView(quizzes: [quiz]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'QuickQuizScreen breakdown renders without overflow at 320px/1.3x',
        (tester) async {
      configureSmallPhone(tester);
      const quiz = QuickQuizEntity(
        id: 'q_rev',
        title: 'Rohto Cool Challenge',
        category: 'Ophthalmology',
        durationMinutes: 3,
        rewardPoints: 40,
        isCompleted: true,
        questions: [],
      );
      const review = QuizSubmissionResultEntity(
        attemptId: 'att_qa',
        scorePercentage: 100,
        isPassed: true,
        passingScore: 70,
        pointsAwarded: 40,
        answers: [
          QuizAnswerEvaluationEntity(
            questionId: 'q1',
            questionText: 'What is the cooling active in Rohto Cool?',
            selectedOptionId: 'o1',
            selectedOptionText: 'L-Menthol',
            correctOptionId: 'o1',
            correctOptionText: 'L-Menthol',
            isCorrect: true,
            explanation: 'Contains L-Menthol for rapid soothing sensation.',
          ),
        ],
      );

      await tester.pumpWidget(
        wrapCompact(
          overrides: [
            challengesRepositoryProvider.overrideWithValue(mockChallengesRepo),
          ],
          child: const QuickQuizScreen(
            quiz: quiz,
            initialReviewResult: review,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'NotificationsScreen renders without overflow on 320px at 1.3x scale',
        (tester) async {
      configureSmallPhone(tester);
      when(() => mockNotifsRepo.getNotifications()).thenAnswer(
        (_) async => Result.success([
          NotificationItemEntity(
            id: 'n1',
            type: NotificationType.feedbackReply,
            title: 'Medical Affairs Reply on Rohto Dry Aid',
            body: 'Review the updated clinical talking point.',
            timestamp: DateTime(2026, 11, 10, 9, 0),
            isRead: false,
          ),
        ]),
      );

      await tester.pumpWidget(
        wrapCompact(
          overrides: [
            notificationsRepositoryProvider.overrideWithValue(mockNotifsRepo),
          ],
          child: const NotificationsScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
