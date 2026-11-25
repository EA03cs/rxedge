import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/feedback/data/models/feedback_dto.dart';
import 'package:rxedge/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:rxedge/features/feedback/domain/entities/feedback_entities.dart';
import 'package:rxedge/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:rxedge/features/feedback/presentation/screens/feedback_screen.dart';

class MockFeedbackRepository extends Mock implements FeedbackRepository {}

void main() {
  late MockFeedbackRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(FeedbackType.doctorObjection);
  });

  setUp(() {
    mockRepo = MockFeedbackRepository();
    when(() => mockRepo.getDraft(any())).thenAnswer((_) async => const Result.success(null));
  });

  Widget buildEnglishFeedbackScreen(List<FeedbackItemEntity> items) {
    when(() => mockRepo.getSubmissions(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => Result.success(items));

    return ProviderScope(
      overrides: [
        feedbackRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const MaterialApp(
        themeMode: ThemeMode.light,
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: [Locale('en')],
        home: FeedbackScreen(),
      ),
    );
  }

  group('Feedback Screen Automated Regression Tests', () {
    testWidgets('renders successfully with nested Prisma relation objects without any type cast error',
        (tester) async {
      // Simulate real raw backend items containing nested Maps for product and repliedBy
      final rawBackendItem1 = <String, dynamic>{
        'id': 'sub-rohto-01',
        'clientSubmissionId': 'client-sub-001',
        'userId': 'usr-rep-01',
        'productId': 'prod-rohto-dry-aid',
        'category': 'doctor_objection',
        'status': 'ANSWERED',
        'title': 'Ophthalmologist question on Tearshield mechanism',
        'doctorSpecialty': 'Consultant Ophthalmologist',
        'details': 'Doctor asked how TEARSHIELD restores the natural tear film.',
        'representativeResponse':
            'Explained that TEARSHIELD restores and lubricates all tear film layers for long-lasting relief.',
        'competitorName': null,
        'competitorClaim': null,
        'attachmentUrl': 'https://drive.google.com/uc?id=sample_photo',
        'createdAt': '2026-11-19T09:00:00.000Z',
        'product': <String, dynamic>{
          'id': 'prod-rohto-dry-aid',
          'brandCode': 'ROHTO-DRY',
          'name': 'Rohto Dry Aid',
          'translations': <Map<String, dynamic>>[
            {'name': 'Rohto Dry Aid', 'lang': 'en'}
          ],
        },
        'replies': <dynamic>[
          <String, dynamic>{
            'id': 'rep-reply-01',
            'message': 'Great point, added 12-hour efficacy slide to the deck.',
            'createdAt': '2026-11-19T10:00:00.000Z',
            'repliedBy': <String, dynamic>{
              'id': 'adm-01',
              'name': 'Dr. Ahmed - Medical Affairs',
              'role': 'MEDICAL_AFFAIRS',
            },
          }
        ],
      };

      final rawBackendItem2 = <String, dynamic>{
        'id': 'sub-rohto-02',
        'clientSubmissionId': 'client-sub-002',
        'userId': 'usr-rep-01',
        'category': 'competitors_activities',
        'status': 'SEEN',
        'title': 'Systane Ultra competitor booth activity at conference',
        'details': 'Distributed samples and comparison leaflets at the booth.',
        'competitorName': 'Systane Ultra (Alcon)',
        'competitorClaim': 'Claimed faster soothing than Rohto drops.',
        'whereHeard': 'Annual Ophthalmology Society Meeting',
        'attachmentUrl': null,
        'createdAt': '2026-11-18T14:30:00.000Z',
        'product': null,
      };

      // Ensure DTO parses both without throwing any exception
      final dto1 = FeedbackItemDto.fromJson(rawBackendItem1);
      final dto2 = FeedbackItemDto.fromJson(rawBackendItem2);

      expect(dto1.product, 'Rohto Dry Aid');
      expect(dto1.repliedBy, 'Dr. Ahmed - Medical Affairs');
      expect(dto1.typeString, 'doctorObjection');

      expect(dto2.typeString, 'competitorClaim');
      expect(dto2.statusString, 'seen');

      final domainItems = [dto1.toDomain(), dto2.toDomain()];

      await tester.pumpWidget(buildEnglishFeedbackScreen(domainItems));
      await tester.pumpAndSettle();

      // Verify Screen rendered in English cleanly with NO type cast errors
      expect(find.text('Rep Voice'), findsOneWidget);
      expect(find.text('My Submissions'), findsOneWidget);
      expect(find.text('Doctor Objection'), findsNWidgets(2)); // Card + submission badge
      expect(find.text('Competitor Claim'), findsNWidgets(2)); // Card + submission badge
      expect(find.text('Ophthalmologist question on Tearshield mechanism'), findsOneWidget);
      expect(find.text('Systane Ultra competitor booth activity at conference'), findsOneWidget);
      expect(find.text('Answered'), findsWidgets);
    });

    testWidgets('renders empty state correctly when rep has no submissions yet', (tester) async {
      await tester.pumpWidget(buildEnglishFeedbackScreen([]));
      await tester.pumpAndSettle();

      expect(find.text('No Feedback Submitted Yet'), findsOneWidget);
      expect(
        find.text('Submissions shape upcoming detailing materials and clinical rebuttal decks.'),
        findsOneWidget,
      );
    });
  });
}
