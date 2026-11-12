import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:rxedge/features/feedback/domain/entities/feedback_entities.dart';
import 'package:rxedge/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:rxedge/features/feedback/presentation/screens/feedback_form_screen.dart';
import 'package:rxedge/features/feedback/presentation/screens/feedback_success_screen.dart';

class MockFeedbackRepository extends Mock implements FeedbackRepository {}

void main() {
  late MockFeedbackRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(FeedbackType.doctorObjection);
    registerFallbackValue(
      FeedbackItemEntity(
        id: '',
        type: FeedbackType.doctorObjection,
        title: '',
        submittedAt: DateTime(2026, 1, 1),
      ),
    );
    registerFallbackValue(
      const FeedbackDraftEntity(type: FeedbackType.doctorObjection),
    );
  });

  setUp(() {
    mockRepo = MockFeedbackRepository();
    when(() => mockRepo.saveDraft(any())).thenAnswer((_) async => const Result.success(null));
    when(() => mockRepo.clearDraft(any())).thenAnswer((_) async => const Result.success(null));
  });

  Widget buildTestWidget({
    FeedbackType type = FeedbackType.doctorObjection,
    FeedbackDraftEntity? draft,
  }) {
    when(() => mockRepo.getDraft(type)).thenAnswer((_) async => Result.success(draft));

    return ProviderScope(
      overrides: [
        feedbackRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        themeMode: ThemeMode.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FeedbackFormScreen(type: type),
      ),
    );
  }

  group('FeedbackFormScreen Widget Tests', () {
    testWidgets('shows validation errors when submitting empty form', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Doctor Objection'), findsNWidgets(3));
      expect(find.text('Product'), findsOneWidget);

      // Press Send Feedback without entering anything
      await tester.tap(find.text('Send Feedback'));
      await tester.pumpAndSettle();

      expect(find.text('This field is required'), findsNWidgets(2));
    });

    testWidgets('reveals optional fields progressively on typing', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Optional fields should initially be hidden
      expect(find.text('Doctor Specialty (optional)'), findsNothing);
      expect(find.text('How I Responded (optional)'), findsNothing);

      // Enter product
      await tester.enterText(find.byType(TextFormField).first, 'Cardura XL');
      await tester.pumpAndSettle();

      // Now optional fields are revealed
      expect(find.text('Doctor Specialty (optional)'), findsOneWidget);
      expect(find.text('How I Responded (optional)'), findsOneWidget);
    });

    testWidgets('restores draft and displays draft restored badge', (tester) async {
      const savedDraft = FeedbackDraftEntity(
        type: FeedbackType.doctorObjection,
        product: 'AtorvaCare',
        objection: 'High cost vs generic',
      );

      await tester.pumpWidget(buildTestWidget(draft: savedDraft));
      await tester.pumpAndSettle();

      expect(find.text('Draft restored'), findsOneWidget);
      expect(find.text('AtorvaCare'), findsOneWidget);
      expect(find.text('High cost vs generic'), findsOneWidget);
    });

    testWidgets('submits form and navigates to FeedbackSuccessScreen', (tester) async {
      final sampleSubmitted = FeedbackItemEntity(
        id: 'fb_123',
        type: FeedbackType.doctorObjection,
        title: 'Cardura XL: Doctor objection test',
        submittedAt: DateTime.now(),
        status: FeedbackStatus.sent,
        product: 'Cardura XL',
        objection: 'Doctor objection test',
      );

      when(() => mockRepo.submitFeedback(any())).thenAnswer((_) async => Result.success(sampleSubmitted));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Fill required fields
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Cardura XL');
      await tester.enterText(textFields.at(1), 'Doctor objection test');
      await tester.pumpAndSettle();

      // Submit
      await tester.ensureVisible(find.text('Send Feedback'));
      await tester.tap(find.text('Send Feedback'));
      await tester.pumpAndSettle();

      expect(find.byType(FeedbackSuccessScreen), findsOneWidget);
      expect(find.text('Sent. Your marketing team will see this.'), findsOneWidget);
      expect(find.text('Send Another Feedback'), findsOneWidget);
      expect(find.text('Back to Feedback'), findsOneWidget);
    });
  });
}
