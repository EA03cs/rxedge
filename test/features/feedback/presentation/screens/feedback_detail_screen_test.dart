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

class MockFeedbackRepository extends Mock implements FeedbackRepository {}

void main() {
  late MockFeedbackRepository mockRepo;

  final sampleAnswered = FeedbackItemEntity(
    id: 'fb_ans_1',
    type: FeedbackType.doctorObjection,
    title: 'Cardura XL Dosing Pushback',
    submittedAt: DateTime(2026, 11, 7, 10, 0),
    status: FeedbackStatus.answered,
    product: 'Cardura XL',
    objection: 'Dr. Vance worried about morning peak drop',
    doctorSpecialty: 'Cardiologist',
    howResponded: 'Cited GITS continuous delivery',
    marketingReply: 'Great response. New ABPM chart will be added.',
    repliedBy: 'Dr. Kareem - Medical Affairs',
    repliedAt: DateTime(2026, 11, 7, 16, 0),
  );

  final samplePending = FeedbackItemEntity(
    id: 'fb_pend_2',
    type: FeedbackType.competitorClaim,
    title: 'PharmaStar generic flyer',
    submittedAt: DateTime(2026, 11, 8, 12, 0),
    status: FeedbackStatus.pending,
    competitorName: 'PharmaStar Generic',
    claim: 'Claiming identical efficacy with zero clinical trials',
  );

  setUp(() {
    mockRepo = MockFeedbackRepository();
  });

  Widget buildTestWidget({required String submissionId, required List<FeedbackItemEntity> items}) {
    when(() => mockRepo.getSubmissions(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => Result.success(items));

    return ProviderScope(
      overrides: [
        feedbackRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        themeMode: ThemeMode.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FeedbackDetailScreen(submissionId: submissionId),
      ),
    );
  }

  group('FeedbackDetailScreen Widget Tests', () {
    testWidgets('renders doctor objection details and marketing reply card when answered', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(submissionId: 'fb_ans_1', items: [sampleAnswered]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Feedback Details'), findsOneWidget);
      expect(find.text('Doctor Objection'), findsAtLeastNWidgets(1));
      expect(find.text('Cardura XL'), findsOneWidget);
      expect(find.text('Dr. Vance worried about morning peak drop'), findsOneWidget);
      expect(find.text('Cardiologist'), findsOneWidget);
      expect(find.text('Cited GITS continuous delivery'), findsOneWidget);

      // Marketing reply
      expect(find.text('Marketing & Medical Reply'), findsOneWidget);
      expect(find.text('Great response. New ABPM chart will be added.'), findsOneWidget);
      expect(find.text('Dr. Kareem - Medical Affairs'), findsOneWidget);
    });

    testWidgets('renders offline queued banner when status is pending', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(submissionId: 'fb_pend_2', items: [samplePending]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Competitor Claim'), findsOneWidget);
      expect(find.text('PharmaStar Generic'), findsOneWidget);
      expect(find.text('Will send when you\'re back online'), findsOneWidget);
    });
  });
}
