import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:rxedge/features/feedback/domain/entities/feedback_entities.dart';
import 'package:rxedge/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:rxedge/features/feedback/presentation/screens/feedback_detail_screen.dart';
import 'package:rxedge/features/feedback/presentation/screens/feedback_form_screen.dart';
import 'package:rxedge/features/feedback/presentation/screens/feedback_screen.dart';

class MockFeedbackRepository extends Mock implements FeedbackRepository {}

void main() {
  late MockFeedbackRepository mockRepo;

  final sampleAnswered = FeedbackItemEntity(
    id: 'fb_1',
    type: FeedbackType.doctorObjection,
    title: 'Cardura XL vs Generic Amlodipine',
    submittedAt: DateTime(2026, 11, 8, 14, 30),
    status: FeedbackStatus.answered,
    product: 'Cardura XL',
    objection: 'Doctor concerned about morning hypotension',
    marketingReply: 'Clinical slide added to next Monday deck',
    repliedBy: 'Dr. Kareem',
    repliedAt: DateTime(2026, 11, 8, 18, 0),
  );

  final samplePending = FeedbackItemEntity(
    id: 'pending_123',
    type: FeedbackType.competitorClaim,
    title: 'Competitor bio-equivalence flyer',
    submittedAt: DateTime(2026, 11, 9, 9, 0),
    status: FeedbackStatus.pending,
    competitorName: 'PharmaStar',
    claim: 'Unverified flyer distributed',
  );

  setUpAll(() {
    registerFallbackValue(FeedbackType.doctorObjection);
  });

  setUp(() {
    mockRepo = MockFeedbackRepository();
    when(() => mockRepo.getDraft(any())).thenAnswer((_) async => const Result.success(null));
  });

  Widget buildTestWidget({List<FeedbackItemEntity> items = const []}) {
    when(() => mockRepo.getSubmissions(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => Result.success(items));

    return ProviderScope(
      overrides: [
        feedbackRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const MaterialApp(
        themeMode: ThemeMode.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FeedbackScreen(),
      ),
    );
  }

  group('FeedbackScreen Widget Tests', () {
    testWidgets('renders 3 type cards and submissions list', (tester) async {
      await tester.pumpWidget(buildTestWidget(items: [sampleAnswered]));
      await tester.pumpAndSettle();

      // Title & Subtitle
      expect(find.text('Marketing Feedback'), findsOneWidget);
      expect(find.text('Share real clinic insights directly with medical affairs'), findsOneWidget);

      // 3 Type Cards
      expect(find.text('Doctor Objection'), findsNWidgets(2)); // Card + Submission type
      expect(find.text('Competitor Claim'), findsOneWidget);
      expect(find.text('Field Feedback'), findsOneWidget);

      // My Submissions
      expect(find.text('My Submissions'), findsOneWidget);
      expect(find.text('Cardura XL vs Generic Amlodipine'), findsOneWidget);
      expect(find.text('Answered'), findsNWidgets(2)); // StatusBadge + label
    });

    testWidgets('renders offline banner when pending item exists', (tester) async {
      await tester.pumpWidget(buildTestWidget(items: [samplePending]));
      await tester.pumpAndSettle();

      expect(find.text('Some submissions are pending offline and will sync when connected.'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('tapping type card navigates to FeedbackFormScreen', (tester) async {
      await tester.pumpWidget(buildTestWidget(items: [sampleAnswered]));
      await tester.pumpAndSettle();

      // Tap 'Doctor Objection' card
      await tester.tap(find.text('Real questions, skepticism, or pushback heard in clinic visits.'));
      await tester.pumpAndSettle();

      expect(find.byType(FeedbackFormScreen), findsOneWidget);
      expect(find.text('Product'), findsOneWidget);
      expect(find.text('Doctor Objection'), findsNWidgets(3));
    });

    testWidgets('tapping submission item navigates to FeedbackDetailScreen', (tester) async {
      await tester.pumpWidget(buildTestWidget(items: [sampleAnswered]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cardura XL vs Generic Amlodipine'));
      await tester.pumpAndSettle();

      expect(find.byType(FeedbackDetailScreen), findsOneWidget);
      expect(find.text('Feedback Details'), findsOneWidget);
      expect(find.text('Clinical slide added to next Monday deck'), findsOneWidget);
    });
  });
}
