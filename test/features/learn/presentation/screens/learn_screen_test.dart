import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/app/theme/theme.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/core/widgets/widgets.dart';
import 'package:rxedge/features/learn/data/repositories/learn_repository_impl.dart';
import 'package:rxedge/features/learn/domain/entities/learning_entities.dart';
import 'package:rxedge/features/learn/domain/repositories/learn_repository.dart';
import 'package:rxedge/features/learn/presentation/screens/learn_screen.dart';

class MockLearnRepository extends Mock implements LearnRepository {}

void main() {
  late MockLearnRepository mockRepo;

  final sampleProducts = [
    const ProductLearningEntity(
      id: 'prod_cardura',
      name: 'Cardura XL',
      therapeuticArea: 'Hypertension & BPH',
      isRecommended: true,
      positioning: ProductPositioningEntity(
        keyMessage: 'Once daily continuous control',
        targetDoctors: ['Cardiologist'],
        keyBenefits: ['24-hour plasma concentration'],
        dosageHighlights: ['4mg once daily'],
        proofPoints: ['PREDICT Study'],
      ),
      competitors: [
        CompetitorComparisonEntity(
          id: 'comp_1',
          competitorName: 'Generic Amlodipine',
          theirClaim: 'Low cost',
          howToRespond: 'Peripheral edema risk',
          proofReference: 'ASCOT-BPLA',
        ),
      ],
      lessons: [
        LessonEntity(
          id: 'les_crd_01',
          productId: 'prod_cardura',
          productName: 'Cardura XL',
          title: 'Absorption Kinetics',
          durationMinutes: 5,
          order: 1,
          isCompleted: true,
        ),
        LessonEntity(
          id: 'les_crd_02',
          productId: 'prod_cardura',
          productName: 'Cardura XL',
          title: 'Clinical Trial Evidence',
          durationMinutes: 4,
          order: 2,
          isCompleted: false,
        ),
      ],
    ),
  ];

  setUp(() {
    mockRepo = MockLearnRepository();
  });

  Widget buildTestWidget({List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: [
        learnRepositoryProvider.overrideWithValue(mockRepo),
        ...overrides,
      ],
      child: MaterialApp(
        theme: RxTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LearnScreen(),
      ),
    );
  }

  group('LearnScreen Widget Tests', () {
    testWidgets('renders loading skeleton while loading', (tester) async {
      final completer = Completer<Result<List<ProductLearningEntity>>>();
      when(() => mockRepo.getProducts(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(SkeletonBox), findsWidgets);
      expect(find.text('Cardura XL'), findsNothing);

      completer.complete(Result.success(sampleProducts));
      await tester.pumpAndSettle();
      expect(find.text('Cardura XL'), findsOneWidget);
    });

    testWidgets('renders product cards with ProgressRing, tags, and completed counts', (tester) async {
      when(() => mockRepo.getProducts(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(sampleProducts));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Product name & therapeutic area
      expect(find.text('Cardura XL'), findsOneWidget);
      expect(find.text('Hypertension & BPH'), findsOneWidget);

      // Tags
      expect(find.text('Recommended'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);

      // Lessons completed
      expect(find.text('1/2 lessons completed'), findsOneWidget);

      // ProgressRing percentage
      expect(find.text('50%'), findsOneWidget);
      expect(find.byType(ProgressRing), findsOneWidget);

      // Bookmarks pill button
      expect(find.text('Bookmarks'), findsOneWidget);
    });

    testWidgets('renders ErrorState with retry when failure occurs', (tester) async {
      when(() => mockRepo.getProducts(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => const Result.failure(ServerFailure(debugMessage: 'Cannot fetch modules')));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('tapping product card navigates to ProductLearningScreen', (tester) async {
      when(() => mockRepo.getProducts(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(sampleProducts));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cardura XL'));
      await tester.pumpAndSettle();

      // Should be on ProductLearningScreen
      expect(find.text('Product Positioning'), findsOneWidget);
      expect(find.text('Competitive Handling'), findsOneWidget);
    });
  });
}
