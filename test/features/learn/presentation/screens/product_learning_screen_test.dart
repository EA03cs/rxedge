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
import 'package:rxedge/features/learn/presentation/screens/product_learning_screen.dart';

class MockLearnRepository extends Mock implements LearnRepository {}

void main() {
  late MockLearnRepository mockRepo;

  const sampleProduct = ProductLearningEntity(
    id: 'prod_cardura',
    name: 'Cardura XL',
    therapeuticArea: 'Hypertension & BPH',
    isRecommended: true,
    positioning: ProductPositioningEntity(
      keyMessage: 'Once daily continuous 24h blood pressure control',
      targetDoctors: [
        'Cardiologists managing refractory hypertension',
        'Urologists treating BPH urinary symptoms',
      ],
      keyBenefits: [
        '24-Hour continuous plasma concentration stability',
        'Dual symptom relief',
      ],
      dosageHighlights: [
        'Standard starting dose: 4mg once daily',
      ],
      proofPoints: [
        'PREDICT Study (n=1,240): 14.2 mm Hg systolic reduction',
      ],
    ),
    competitors: [
      CompetitorComparisonEntity(
        id: 'comp_1',
        competitorName: 'Generic Amlodipine',
        theirClaim: 'Amlodipine is inexpensive and standard first line',
        howToRespond: 'Amlodipine induces peripheral edema in up to 15% and has zero BPH benefit',
        proofReference: 'ASCOT-BPLA Trial Sub-analysis (p < 0.001)',
      ),
    ],
    lessons: [
      LessonEntity(
        id: 'les_crd_01',
        productId: 'prod_cardura',
        productName: 'Cardura XL',
        title: 'Absorption Kinetics & GITS Mechanism',
        durationMinutes: 5,
        order: 1,
        isCompleted: true,
      ),
    ],
  );

  setUp(() {
    mockRepo = MockLearnRepository();
    when(() => mockRepo.getProducts(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => const Result.success([sampleProduct]));
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        learnRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        theme: RxTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProductLearningScreen(product: sampleProduct),
      ),
    );
  }

  group('ProductLearningScreen Widget Tests', () {
    testWidgets('renders product metrics and scannable positioning blocks', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Product Header
      expect(find.text('Cardura XL'), findsWidgets);
      expect(find.text('Hypertension & BPH'), findsOneWidget);
      expect(find.text('1/1 lessons completed'), findsOneWidget);
      expect(find.byType(ProgressRing), findsOneWidget);

      // Positioning Blocks
      expect(find.text('Key Message'), findsOneWidget);
      expect(find.text('Once daily continuous 24h blood pressure control'), findsOneWidget);
      expect(find.text('Target Doctors'), findsOneWidget);
      expect(find.text('Cardiologists managing refractory hypertension'), findsOneWidget);
      expect(find.text('Key Benefits'), findsOneWidget);
      expect(find.text('24-Hour continuous plasma concentration stability'), findsOneWidget);
      expect(find.text('Dosage Highlights'), findsOneWidget);
      expect(find.text('Standard starting dose: 4mg once daily'), findsOneWidget);
      expect(find.text('Proof Points'), findsOneWidget);
      expect(find.text('PREDICT Study (n=1,240): 14.2 mm Hg systolic reduction'), findsOneWidget);
    });

    testWidgets('switching to Competitive tab shows claims, responses, proof, and copy action', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Competitive Handling tab
      await tester.tap(find.text('Competitive Handling'));
      await tester.pumpAndSettle();

      expect(find.text('Their claim'), findsOneWidget);
      expect(find.text('Amlodipine is inexpensive and standard first line'), findsOneWidget);

      expect(find.text('How to respond'), findsOneWidget);
      expect(find.text('Amlodipine induces peripheral edema in up to 15% and has zero BPH benefit'), findsOneWidget);

      expect(find.text('Proof / reference'), findsOneWidget);
      expect(find.text('ASCOT-BPLA Trial Sub-analysis (p < 0.001)'), findsOneWidget);

      expect(find.text('Copy talking point'), findsOneWidget);

      // Tap copy talking point
      await tester.tap(find.text('Copy talking point'));
      await tester.pump();

      // SnackBar should appear
      expect(find.text('Talking point copied to clipboard'), findsOneWidget);
    });

    testWidgets('tapping Lessons button opens modal sheet with lesson list', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Lessons button
      await tester.tap(find.text('Lessons'));
      await tester.pumpAndSettle();

      expect(find.text('Lesson Modules'), findsOneWidget);
      expect(find.text('Absorption Kinetics & GITS Mechanism'), findsOneWidget);
      expect(find.text('5 min read'), findsOneWidget);
    });
  });
}
