import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:rxedge/features/profile/domain/entities/profile_entities.dart';
import 'package:rxedge/features/profile/domain/repositories/profile_repository.dart';
import 'package:rxedge/features/profile/presentation/screens/profile_screen.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository mockRepo;

  final sampleProfile = UserProfileEntity(
    id: 'usr_1',
    displayName: 'Alex Mercer',
    email: 'alex@rxedgepharma.com',
    employeeId: 'MR-7842',
    territory: 'Cairo North & Heliopolis',
    role: 'Senior Medical Representative',
    points: 1250,
    streakDays: 4,
    badges: [
      BadgeEntity(
        id: 'b1',
        name: 'Spotlight Rep',
        description: 'Top performer',
        earnedAt: DateTime(2026, 10, 1),
      ),
      BadgeEntity(
        id: 'b2',
        name: 'Cardio Ace',
        description: '100% Cardio quiz pass',
        earnedAt: DateTime(2026, 10, 15),
      ),
    ],
    notificationPreferences: const NotificationPreferencesEntity(),
    storageUsageBytes: 25800000,
  );

  setUp(() {
    mockRepo = MockProfileRepository();
    when(() => mockRepo.getProfile()).thenAnswer((_) async => Result.success(sampleProfile));
    when(() => mockRepo.clearCachedDownloads()).thenAnswer((_) async => const Result.success(null));
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const MaterialApp(
        themeMode: ThemeMode.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen Widget Tests', () {
    testWidgets('renders rep details, points, badges, and settings', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Title & Rep Info
      expect(find.text('Profile & Settings'), findsOneWidget);
      expect(find.text('Alex Mercer'), findsOneWidget);
      expect(find.text('Employee ID: MR-7842'), findsOneWidget);
      expect(find.text('Cairo North & Heliopolis'), findsOneWidget);

      // Points & Badges
      expect(find.text('1250 Pts'), findsOneWidget);
      expect(find.text('4 Days Streak'), findsOneWidget);
      expect(find.text('Spotlight Rep'), findsOneWidget);
      expect(find.text('Cardio Ace'), findsOneWidget);

      // Settings sections
      expect(find.text('General Settings'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
      expect(find.text('Notification Preferences'), findsOneWidget);
      expect(find.text('Storage & Downloads'), findsOneWidget);
      expect(find.text('24.6 MB Cached Offline'), findsOneWidget);
    });

    testWidgets('clearing downloads prompts confirmation and updates state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Clear Cached Downloads'));
      await tester.tap(find.text('Clear Cached Downloads'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to remove all offline downloaded materials? You can re-download them anytime.'), findsOneWidget);

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      verify(() => mockRepo.clearCachedDownloads()).called(1);
    });

    testWidgets('logout button prompts confirmation dialog', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Sign Out'));
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to sign out? You will need your employee credentials to sign back in.'), findsOneWidget);
    });
  });
}
