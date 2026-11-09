import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/app/theme/theme.dart';
import 'package:rxedge/core/widgets/widgets.dart';
import 'package:rxedge/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rxedge/features/auth/domain/repositories/auth_repository.dart';
import 'package:rxedge/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:rxedge/features/auth/presentation/screens/login_screen.dart';
import 'package:rxedge/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:rxedge/features/auth/presentation/screens/splash_screen.dart';
import 'package:rxedge/features/home/presentation/screens/home_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

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

    testWidgets('HomeScreen renders MR territory priorities', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text("Today's Territory Priority"), findsOneWidget);
      expect(find.text('7 of 10 Visits Complete'), findsOneWidget);
    });
  });
}
