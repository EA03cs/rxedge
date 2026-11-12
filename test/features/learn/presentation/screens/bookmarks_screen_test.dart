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
import 'package:rxedge/features/learn/presentation/screens/bookmarks_screen.dart';

class MockLearnRepository extends Mock implements LearnRepository {}

void main() {
  late MockLearnRepository mockRepo;

  setUp(() {
    mockRepo = MockLearnRepository();
  });

  Widget buildTestWidget({required List<ProductLearningEntity> products}) {
    when(() => mockRepo.getProducts(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => Result.success(products));

    return ProviderScope(
      overrides: [
        learnRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        theme: RxTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const BookmarksScreen(),
      ),
    );
  }

  group('BookmarksScreen Widget Tests', () {
    testWidgets('renders EmptyState when no lessons are bookmarked', (tester) async {
      const productWithoutBookmarks = ProductLearningEntity(
        id: 'prod_1',
        name: 'Cardura XL',
        therapeuticArea: 'Hypertension',
        positioning: ProductPositioningEntity(
          keyMessage: 'Msg',
          targetDoctors: [],
          keyBenefits: [],
          dosageHighlights: [],
          proofPoints: [],
        ),
        competitors: [],
        lessons: [
          LessonEntity(
            id: 'les_1',
            productId: 'prod_1',
            productName: 'Cardura XL',
            title: 'Lesson 1',
            durationMinutes: 3,
            order: 1,
            isBookmarked: false,
          ),
        ],
      );

      await tester.pumpWidget(buildTestWidget(products: [productWithoutBookmarks]));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No bookmarks saved yet'), findsOneWidget);
    });

    testWidgets('lists bookmarked lessons and allows unbookmarking', (tester) async {
      const bookmarkedLesson = LessonEntity(
        id: 'les_bm_01',
        productId: 'prod_1',
        productName: 'Cardura XL',
        title: 'Key Clinical Endpoints',
        durationMinutes: 4,
        order: 1,
        isBookmarked: true,
      );

      const productWithBookmark = ProductLearningEntity(
        id: 'prod_1',
        name: 'Cardura XL',
        therapeuticArea: 'Hypertension',
        positioning: ProductPositioningEntity(
          keyMessage: 'Msg',
          targetDoctors: [],
          keyBenefits: [],
          dosageHighlights: [],
          proofPoints: [],
        ),
        competitors: [],
        lessons: [bookmarkedLesson],
      );

      when(() => mockRepo.toggleLessonBookmark('les_bm_01')).thenAnswer(
        (_) async => Result.success(bookmarkedLesson.copyWith(isBookmarked: false)),
      );

      await tester.pumpWidget(buildTestWidget(products: [productWithBookmark]));
      await tester.pumpAndSettle();

      expect(find.text('Key Clinical Endpoints'), findsOneWidget);
      expect(find.text('Cardura XL'), findsOneWidget);
      expect(find.text('4 min'), findsOneWidget);

      // Tap unbookmark
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      verify(() => mockRepo.toggleLessonBookmark('les_bm_01')).called(1);
    });
  });
}
