import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/app/theme/theme.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/core/widgets/widgets.dart';
import 'package:rxedge/features/learn/data/repositories/learn_repository_impl.dart';
import 'package:rxedge/features/learn/domain/entities/learning_entities.dart';
import 'package:rxedge/features/learn/domain/repositories/learn_repository.dart';
import 'package:rxedge/features/learn/presentation/screens/lesson_screen.dart';

class MockLearnRepository extends Mock implements LearnRepository {}

void main() {
  late MockLearnRepository mockRepo;

  const sampleLesson = LessonEntity(
    id: 'les_test_01',
    productId: 'prod_cardura',
    productName: 'Cardura XL',
    title: 'GITS Mechanism & Absorption',
    durationMinutes: 4,
    order: 1,
    isCompleted: false,
    isBookmarked: false,
    quizQuestionCount: 3,
    sections: [
      LessonSection(
        title: 'Osmotic Push-Pull Delivery',
        content: 'Cardura XL utilizes an osmotic pump delivery system.',
        keyTakeaway: 'Delivers 24h smooth plateau plasma levels.',
      ),
    ],
  );

  const sampleProduct = ProductLearningEntity(
    id: 'prod_cardura',
    name: 'Cardura XL',
    therapeuticArea: 'Hypertension',
    isRecommended: true,
    positioning: ProductPositioningEntity(
      keyMessage: 'Key',
      targetDoctors: ['Cardio'],
      keyBenefits: ['Benefit'],
      dosageHighlights: ['4mg'],
      proofPoints: ['Proof'],
    ),
    competitors: [],
    lessons: [sampleLesson],
  );

  setUp(() {
    mockRepo = MockLearnRepository();
    when(() => mockRepo.getProducts(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => const Result.success([sampleProduct]));
  });

  Widget buildTestWidget({required LessonEntity lesson}) {
    return ProviderScope(
      overrides: [
        learnRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        theme: RxTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LessonScreen(lesson: lesson),
      ),
    );
  }

  group('LessonScreen Widget Tests', () {
    testWidgets('renders clean reading layout with top progress and sections', (tester) async {
      await tester.pumpWidget(buildTestWidget(lesson: sampleLesson));
      await tester.pumpAndSettle();

      // Top progress bar
      expect(find.byType(ProgressBar), findsOneWidget);

      // Titles & metadata
      expect(find.text('GITS Mechanism & Absorption'), findsWidgets);
      expect(find.text('4 min read'), findsOneWidget);

      // Section and key takeaway
      expect(find.text('Osmotic Push-Pull Delivery'), findsOneWidget);
      expect(find.text('Cardura XL utilizes an osmotic pump delivery system.'), findsOneWidget);
      expect(find.text('Delivers 24h smooth plateau plasma levels.'), findsOneWidget);

      // Single primary action: Mark as complete
      expect(find.text('Mark as complete'), findsOneWidget);
    });

    testWidgets('toggles bookmark via AppBar action', (tester) async {
      when(() => mockRepo.toggleLessonBookmark('les_test_01')).thenAnswer(
        (_) async => Result.success(sampleLesson.copyWith(isBookmarked: true)),
      );

      await tester.pumpWidget(buildTestWidget(lesson: sampleLesson));
      await tester.pumpAndSettle();

      final bookmarkButton = find.byTooltip('Bookmarks');
      expect(bookmarkButton, findsOneWidget);

      await tester.tap(bookmarkButton);
      await tester.pumpAndSettle();

      verify(() => mockRepo.toggleLessonBookmark('les_test_01')).called(1);
    });

    testWidgets('marking complete shows Next Step and Take quick quiz button', (tester) async {
      when(() => mockRepo.markLessonCompleted('les_test_01')).thenAnswer(
        (_) async => Result.success(sampleLesson.copyWith(isCompleted: true)),
      );

      await tester.pumpWidget(buildTestWidget(lesson: sampleLesson));
      await tester.pumpAndSettle();

      final markCompleteBtn = find.text('Mark as complete');
      await tester.ensureVisible(markCompleteBtn);
      await tester.tap(markCompleteBtn);
      await tester.pumpAndSettle();

      verify(() => mockRepo.markLessonCompleted('les_test_01')).called(1);

      // Should now show Completed badge & Next Step & Take quick quiz
      expect(find.text('Next Step'), findsOneWidget);
      expect(find.text('Take quick quiz'), findsOneWidget);

      // Tapping Take quick quiz opens quiz sheet
      await tester.tap(find.text('Take quick quiz'));
      await tester.pumpAndSettle();

      expect(find.text('Clinical Recall Quiz'), findsOneWidget);
      expect(find.text('Start Quiz Now (+50 Pts)'), findsOneWidget);
    });
  });
}
