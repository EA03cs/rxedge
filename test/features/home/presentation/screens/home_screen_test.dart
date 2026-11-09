import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/app/theme/theme.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/core/widgets/widgets.dart';
import 'package:rxedge/features/auth/domain/entities/user_entity.dart';
import 'package:rxedge/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rxedge/features/home/data/repositories/home_repository_impl.dart';
import 'package:rxedge/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:rxedge/features/home/domain/repositories/home_repository.dart';
import 'package:rxedge/features/home/presentation/screens/home_screen.dart';
import 'package:rxedge/features/home/presentation/widgets/home_skeleton_loader.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

class FakeAuthController extends AuthController {
  final AuthState _initialState;
  FakeAuthController(this._initialState);

  @override
  AuthState build() => _initialState;
}

void main() {
  late MockHomeRepository mockRepository;

  const testUser = UserEntity(
    id: 'usr_01',
    email: 'alex.morgan@novapharma.internal',
    employeeId: 'MR-4402',
    displayName: 'Alex Morgan',
    role: 'Senior Medical Representative',
    territory: 'Cardio-Metabolic North',
    token: 'jwt_mock_token',
  );

  final testDashboard = HomeDashboardEntity(
    continueLesson: const ContinueLearningEntity(
      id: 'les_cardio_204',
      productName: 'AtorvaCare 20mg',
      lessonTitle: 'Managing Statin-Associated Muscle Symptoms (SAMS)',
      progress: 0.65,
      totalModules: 4,
      completedModules: 2,
    ),
    recommendedProduct: const RecommendedProductEntity(
      id: 'prod_cardura_xl',
      productName: 'Cardura XL',
      therapeuticArea: 'Hypertension & BPH',
      description: 'GITS sustained blood pressure control.',
    ),
    challenge: const MonthlyChallengeEntity(
      id: 'chal_nov_q4',
      title: 'Cardiovascular Knowledge Blitz',
      daysLeft: 4,
      progress: 0.72,
      currentRank: 3,
      totalParticipants: 28,
    ),
    objection: const DoctorObjectionEntity(
      id: 'obj_vance_01',
      doctorQuote: '“Why switch patients to Cardura XL?”',
      doctorName: 'Dr. Robert Vance',
      specialty: 'Consultant Cardiologist',
      productConcerned: 'Cardura XL',
      responseSummary: 'Highlight 24h plasma concentration stability.',
    ),
    recentMaterials: [
      MaterialUpdateEntity(
        id: 'mat_01',
        title: 'AtorvaCare Phase IV Renal Safety Sub-study',
        specialty: 'Cardiology',
        badgeType: MaterialBadgeType.newRelease,
        updatedAt: DateTime(2026, 11, 8),
      ),
      MaterialUpdateEntity(
        id: 'mat_02',
        title: 'Cardura XL 2026 Dosing & Titration Monograph',
        specialty: 'Internal Medicine',
        badgeType: MaterialBadgeType.updated,
        updatedAt: DateTime(2026, 11, 6),
      ),
    ],
    stats: const RepStatsEntity(
      points: 350,
      streakDays: 7,
      quizzesCompleted: 18,
    ),
  );

  setUp(() {
    mockRepository = MockHomeRepository();
  });

  Widget buildTestableScreen({
    required Widget child,
    AuthState authState = const AuthAuthenticated(user: testUser),
  }) {
    return ProviderScope(
      overrides: [
        homeRepositoryProvider.overrideWithValue(mockRepository),
        authControllerProvider.overrideWith(() => FakeAuthController(authState)),
      ],
      child: MaterialApp(
        theme: RxTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  group('HomeScreen Widget Tests', () {
    testWidgets('renders all 8 sections and enforces single filled primary button rule',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockRepository.getHomeDashboard(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(testDashboard));

      await tester.pumpWidget(buildTestableScreen(child: const HomeScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Header (Greeting + Name, Avatar, Bell)
      expect(find.textContaining('Alex'), findsWidgets);
      expect(find.text('AM'), findsOneWidget); // User initials in avatar
      expect(find.byIcon(LucideIcons.bell), findsOneWidget);

      // 2. Search bar
      expect(find.text('Search drug monographs, guidelines...'), findsOneWidget);

      // 3. Continue learning card
      expect(find.text('AtorvaCare 20mg'), findsOneWidget);
      expect(
        find.text('Managing Statin-Associated Muscle Symptoms (SAMS)'),
        findsOneWidget,
      );
      expect(find.text('Continue'), findsOneWidget);

      // 4. This month's challenge
      expect(find.text("This Month's Challenge"), findsOneWidget);
      expect(find.text('Cardiovascular Knowledge Blitz'), findsOneWidget);
      expect(find.text('4 days left'), findsOneWidget);

      // 5. Objection of the month
      expect(find.text('Objection of the Month'), findsOneWidget);
      expect(find.text('“Why switch patients to Cardura XL?”'), findsOneWidget);
      expect(find.text('See how to respond'), findsOneWidget);

      // 6. Quick actions row
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Quick quiz'), findsOneWidget);
      expect(find.text('Send feedback'), findsOneWidget);
      expect(find.text('Search library'), findsOneWidget);

      // 7. What's new section
      expect(find.text("What's New"), findsOneWidget);
      expect(find.text('AtorvaCare Phase IV Renal Safety Sub-study'), findsOneWidget);
      expect(find.text('Cardura XL 2026 Dosing & Titration Monograph'), findsOneWidget);
      expect(find.text('NEW'), findsOneWidget);
      expect(find.text('UPDATED'), findsOneWidget);

      // 8. Slim stats strip
      expect(find.text('350 Pts'), findsOneWidget);
      expect(find.text('7-Day Streak'), findsOneWidget);
      expect(find.text('18 Quizzes'), findsOneWidget);

      // STRICT RULE CHECK: Exactly ONE primary filled button visible
      final allButtons = tester.widgetList<AppButton>(find.byType(AppButton));
      final primaryButtons =
          allButtons.where((btn) => btn.variant == AppButtonVariant.primary).toList();

      expect(
        primaryButtons.length,
        1,
        reason: 'Violation: Only ONE filled primary button is allowed on the Home Screen at a time.',
      );
      expect(primaryButtons.first.text, 'Continue');
    });

    testWidgets('renders new user empty state with recommended product when no lesson started',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final emptyLessonDashboard = HomeDashboardEntity(
        continueLesson: null,
        recommendedProduct: const RecommendedProductEntity(
          id: 'prod_cardura_xl',
          productName: 'Cardura XL',
          therapeuticArea: 'Hypertension & BPH',
          description: 'GITS sustained blood pressure control.',
        ),
        challenge: testDashboard.challenge,
        objection: testDashboard.objection,
        recentMaterials: testDashboard.recentMaterials,
        stats: testDashboard.stats,
      );

      when(() => mockRepository.getHomeDashboard(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(emptyLessonDashboard));

      await tester.pumpWidget(buildTestableScreen(child: const HomeScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verifies empty state copy
      expect(find.text('Start with Cardura XL'), findsOneWidget);
      expect(find.text('Recommended for your territory'), findsOneWidget);
      expect(find.text('Start Lesson'), findsOneWidget);

      // Still enforces exactly ONE primary button
      final primaryButtons = tester
          .widgetList<AppButton>(find.byType(AppButton))
          .where((btn) => btn.variant == AppButtonVariant.primary)
          .toList();
      expect(primaryButtons.length, 1);
      expect(primaryButtons.first.text, 'Start Lesson');
    });

    testWidgets('renders skeleton loader when dashboard is loading',
        (WidgetTester tester) async {
      final completer = Completer<Result<HomeDashboardEntity>>();
      when(() => mockRepository.getHomeDashboard(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestableScreen(child: const HomeScreen()));
      await tester.pump(); // Start building while completer is pending

      expect(find.byType(HomeSkeletonLoader), findsOneWidget);
      expect(find.byType(SkeletonBox), findsWidgets);

      // Complete to avoid any pending futures
      completer.complete(Result.success(testDashboard));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('renders ErrorState on failure and handles retry',
        (WidgetTester tester) async {
      when(() => mockRepository.getHomeDashboard(forceRefresh: false)).thenAnswer(
        (_) async => const Result.failure(NetworkFailure(debugMessage: 'Connection failed')),
      );
      when(() => mockRepository.getHomeDashboard(forceRefresh: true))
          .thenAnswer((_) async => Result.success(testDashboard));

      await tester.pumpWidget(buildTestableScreen(child: const HomeScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Tap retry
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Successfully resolved after retry
      expect(find.text('AtorvaCare 20mg'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });
  });
}
