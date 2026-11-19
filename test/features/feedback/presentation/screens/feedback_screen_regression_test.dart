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

  Widget buildArabicFeedbackScreen(List<FeedbackItemEntity> items) {
    when(() => mockRepo.getSubmissions(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => Result.success(items));

    return ProviderScope(
      overrides: [
        feedbackRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const MaterialApp(
        themeMode: ThemeMode.light,
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
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
        'title': 'اعتراض استشاري الرمد على آلية تقنية تيرشيلد',
        'doctorSpecialty': 'استشاري جراحة العيون والقرنية',
        'details': 'تساءل الطبيب عن كيفية عمل تقنية TEARSHIELD في استعادة طبقة الدموع الطبيعية.',
        'representativeResponse': 'أوضحت أن تقنية TEARSHIELD تستعيد وتزيت طبقة الدموع الطبيعية وتوفر راحة طويلة الأمد.',
        'competitorName': null,
        'competitorClaim': null,
        'attachmentUrl': 'https://drive.google.com/uc?id=sample_photo',
        'createdAt': '2026-11-19T09:00:00.000Z',
        'product': <String, dynamic>{
          'id': 'prod-rohto-dry-aid',
          'brandCode': 'ROHTO-DRY',
          'name': 'Rohto Dry Aid',
          'translations': <Map<String, dynamic>>[
            {'name': 'روهتو دراي إيد', 'lang': 'ar'}
          ],
        },
        'replies': <dynamic>[
          <String, dynamic>{
            'id': 'rep-reply-01',
            'message': 'ممتاز، تم إدراج سلايد دراسة الفعالية 12 ساعة في العرض القادم.',
            'createdAt': '2026-11-19T10:00:00.000Z',
            'repliedBy': <String, dynamic>{
              'id': 'adm-01',
              'name': 'د. أحمد - الإدارة الطبية',
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
        'title': 'نشاط منافس لقطرة Systane Ultra في مؤتمر الرمد',
        'details': 'توزيع عينات مجانية لـ Systane Ultra مع منشورات مقارنة عن ترطيب العين.',
        'competitorName': 'Systane Ultra (Alcon)',
        'competitorClaim': 'الادعاء بفاعلية أسرع في ترطيب العين من روهتو.',
        'whereHeard': 'المؤتمر السنوي لجمعية الرمد المصرية',
        'attachmentUrl': null,
        'createdAt': '2026-11-18T14:30:00.000Z',
        'product': null,
      };

      // Ensure DTO parses both without throwing any exception
      final dto1 = FeedbackItemDto.fromJson(rawBackendItem1);
      final dto2 = FeedbackItemDto.fromJson(rawBackendItem2);

      expect(dto1.product, 'Rohto Dry Aid');
      expect(dto1.repliedBy, 'د. أحمد - الإدارة الطبية');
      expect(dto1.typeString, 'doctorObjection');

      expect(dto2.typeString, 'competitorClaim');
      expect(dto2.statusString, 'seen');

      final domainItems = [dto1.toDomain(), dto2.toDomain()];

      await tester.pumpWidget(buildArabicFeedbackScreen(domainItems));
      await tester.pumpAndSettle();

      // Verify Screen rendered in Arabic cleanly with NO type cast errors
      expect(find.text('صوت المندوب (Rep Voice)'), findsOneWidget);
      expect(find.text('مشاركاتي السابقة'), findsOneWidget);
      expect(find.text('اعتراض الطبيب'), findsNWidgets(2)); // Card + submission badge
      expect(find.text('ادعاء المنافسين'), findsNWidgets(2)); // Card + submission badge
      expect(find.text('اعتراض استشاري الرمد على آلية تقنية تيرشيلد'), findsOneWidget);
      expect(find.text('نشاط منافس لقطرة Systane Ultra في مؤتمر الرمد'), findsOneWidget);
      expect(find.text('تم الرد'), findsWidgets);
    });

    testWidgets('renders empty state correctly when rep has no submissions yet', (tester) async {
      await tester.pumpWidget(buildArabicFeedbackScreen([]));
      await tester.pumpAndSettle();

      expect(find.text('لم ترسل أية ملاحظات بعد'), findsOneWidget);
      expect(find.text('تساعد ملاحظاتك الميدانية في تطوير العروض الترويجية والردود السريرية.'), findsOneWidget);
    });
  });
}
