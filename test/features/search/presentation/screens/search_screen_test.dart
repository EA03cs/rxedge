import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/search/data/repositories/search_repository_impl.dart';
import 'package:rxedge/features/search/domain/entities/search_entities.dart';
import 'package:rxedge/features/search/domain/repositories/search_repository.dart';
import 'package:rxedge/features/search/presentation/screens/search_screen.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late MockSearchRepository mockRepo;

  const sampleLesson = SearchResultItemEntity(
    id: 's_1',
    category: SearchResultCategory.lesson,
    title: 'Cardura XL GITS Absorption Curve',
    subtitle: 'Zero-order kinetics study',
    badgeText: 'Cardura XL',
  );

  const sampleLib = SearchResultItemEntity(
    id: 's_2',
    category: SearchResultCategory.libraryFile,
    title: 'Cardura XL 2026 Clinical Monograph',
    subtitle: 'PDF 4.2 MB',
    badgeText: 'PDF',
  );

  const sampleObj = SearchResultItemEntity(
    id: 's_3',
    category: SearchResultCategory.objection,
    title: 'Doctor skeptical about morning orthostatic drop',
    subtitle: 'Response: Clarify GITS kinetics',
    badgeText: 'Objection',
  );

  setUp(() {
    mockRepo = MockSearchRepository();
    when(() => mockRepo.getRecentSearches())
        .thenAnswer((_) async => const Result.success(['Cardura XL', 'AtorvaCare']));
    when(() => mockRepo.addRecentSearch(any()))
        .thenAnswer((_) async => const Result.success(null));
    when(() => mockRepo.clearRecentSearches())
        .thenAnswer((_) async => const Result.success(null));
    when(() => mockRepo.search('Cardura')).thenAnswer((_) async => const Result.success({
          SearchResultCategory.lesson: [sampleLesson],
          SearchResultCategory.libraryFile: [sampleLib],
          SearchResultCategory.objection: [sampleObj],
        }));
    when(() => mockRepo.search('emptyresult')).thenAnswer((_) async => const Result.success({}));
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        searchRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const MaterialApp(
        themeMode: ThemeMode.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SearchScreen(),
      ),
    );
  }

  group('SearchScreen Widget Tests', () {
    testWidgets('renders recent searches and suggested topics when query is empty', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Recent Searches'), findsOneWidget);
      expect(find.text('Cardura XL'), findsNWidgets(2)); // Recent search chip + Suggested topic
      expect(find.text('Suggested Topics'), findsOneWidget);
    });

    testWidgets('entering query displays grouped search results', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Cardura');
      await tester.pumpAndSettle();

      expect(find.text('Clinical Lessons & Monographs'), findsOneWidget);
      expect(find.text('Cardura XL GITS Absorption Curve'), findsOneWidget);

      expect(find.text('Library Files & Visual Aids'), findsOneWidget);
      expect(find.text('Cardura XL 2026 Clinical Monograph'), findsOneWidget);

      expect(find.text('Doctor Objections & Talking Points'), findsOneWidget);
      expect(find.text('Doctor skeptical about morning orthostatic drop'), findsOneWidget);
    });

    testWidgets('displays no results empty state with suggestions for unmatched query', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'emptyresult');
      await tester.pumpAndSettle();

      expect(find.text('No results for "emptyresult"'), findsOneWidget);
      expect(find.text('Try fewer words, check product spelling, or search by therapeutic area (e.g. Cardura XL, AtorvaCare).'), findsOneWidget);
    });
  });
}
