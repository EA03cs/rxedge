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
import 'package:rxedge/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rxedge/features/auth/domain/repositories/auth_repository.dart';
import 'package:rxedge/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:rxedge/features/auth/presentation/screens/login_screen.dart';
import 'package:rxedge/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:rxedge/features/auth/presentation/screens/splash_screen.dart';
import 'package:rxedge/features/home/data/repositories/home_repository_impl.dart';
import 'package:rxedge/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:rxedge/features/home/domain/repositories/home_repository.dart';
import 'package:rxedge/features/home/presentation/screens/home_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    when(() => mockRepository.isOnboardingCompleted()).thenAnswer((_) async => true);
    when(() => mockRepository.isAuthenticated()).thenAnswer((_) async => false);
    when(() => mockRepository.getCurrentUser()).thenAnswer((_) async => null);
  });

  Widget buildTestableWidget(Widget child) {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(
        theme: RxTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  group('Auth Flow Screens Widget Tests', () {
    testWidgets('SplashScreen renders centered logo and branding', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SplashScreen()));

      expect(find.text('RxEdge'), findsOneWidget);
      expect(find.text('Field Medical Intelligence'), findsOneWidget);
      expect(find.byIcon(LucideIcons.activity), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('OnboardingScreen renders 3 slides and Skip button', (WidgetTester tester) async {
      when(() => mockRepository.setOnboardingCompleted()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
      await tester.pumpAndSettle();

      // Slide 1 title
      expect(find.text('Learn every product'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Tap Next to advance to Slide 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Find any material in seconds'), findsOneWidget);

      // Tap Next to advance to Slide 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Tell marketing what you see in the field'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
    });

    testWidgets('LoginScreen validates required fields and renders company note', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Sign in to RxEdge'), findsOneWidget);
      expect(find.text('Work Email or Employee ID'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Accounts are provided by your company'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);

      // Tap Sign In with empty fields -> inline errors appear
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(find.text('Work Email or Employee ID is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('ForgotPasswordScreen explains corporate support contact', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Need Password Assistance?'), findsOneWidget);
      expect(find.text('support@rxedge.internal'), findsOneWidget);
      expect(find.text('Contact Marketing & IT Support'), findsOneWidget);
      expect(find.text('Back to Sign In'), findsOneWidget);
    });

    testWidgets('HomeScreen renders MR dashboard', (WidgetTester tester) async {
      final mockHomeRepo = MockHomeRepository();
      when(() => mockHomeRepo.getHomeDashboard(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer(
        (_) async => const Result.success(
          HomeDashboardEntity(
            challenge: MonthlyChallengeEntity(
              id: 'ch_1',
              title: 'Cardio Sprint',
              daysLeft: 5,
              progress: 0.5,
              currentRank: 2,
              totalParticipants: 20,
            ),
            objection: DoctorObjectionEntity(
              id: 'obj_1',
              doctorQuote: 'Why switch therapy?',
              doctorName: 'Dr. Tarek',
              specialty: 'Cardiology',
              productConcerned: 'Cardura XL',
              responseSummary: '24-hour sustained efficacy.',
            ),
            recentMaterials: [],
            stats: RepStatsEntity(
              points: 300,
              streakDays: 4,
              quizzesCompleted: 3,
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockRepository),
            homeRepositoryProvider.overrideWithValue(mockHomeRepo),
          ],
          child: MaterialApp(
            theme: RxTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Search drug monographs, guidelines...'), findsOneWidget);
    });

    testWidgets('LoginScreen surfaces backend Joi ValidationFailure errors cleanly', (WidgetTester tester) async {
      when(
        () => mockRepository.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
          keepSignedIn: any(named: 'keepSignedIn'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(
          ValidationFailure(
            {
              'field_0': 'VALIDATION_EMAIL_INVALID',
              'field_1': 'VALIDATION_PASSWORD_MIN',
            },
            debugMessage: 'Validation failed',
          ),
        ),
      );

      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'REP-101');
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid work email (e.g. rep@rxedge.com).'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters.'), findsOneWidget);
    });

    testWidgets('LoginScreen falls back to general banner for unmapped ValidationFailure and 401', (WidgetTester tester) async {
      when(
        () => mockRepository.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
          keepSignedIn: any(named: 'keepSignedIn'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(
          ValidationFailure(
            {'field_0': 'UNKNOWN_RULE'},
            debugMessage: 'Validation failed',
          ),
        ),
      );

      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'rep@rxedge.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(find.text('Please check the highlighted fields and try again.'), findsOneWidget);

      when(
        () => mockRepository.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
          keepSignedIn: any(named: 'keepSignedIn'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(
          UnauthorizedFailure(debugMessage: 'Invalid credentials'),
        ),
      );

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Invalid username or password. Please verify and try again.'),
        findsOneWidget,
      );
    });
  });
}
