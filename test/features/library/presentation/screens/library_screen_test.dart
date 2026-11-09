import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/app/theme/theme.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/core/widgets/widgets.dart';
import 'package:rxedge/features/library/data/repositories/library_repository_impl.dart';
import 'package:rxedge/features/library/domain/entities/material_item_entity.dart';
import 'package:rxedge/features/library/domain/repositories/library_repository.dart';
import 'package:rxedge/features/library/presentation/screens/library_screen.dart';
import 'package:rxedge/features/library/presentation/widgets/material_card_grid.dart';
import 'package:rxedge/features/library/presentation/widgets/material_card_list.dart';

class MockLibraryRepository extends Mock implements LibraryRepository {}

void main() {
  late MockLibraryRepository mockRepository;

  final testMaterials = [
    MaterialItemEntity(
      id: 'mat_01',
      title: 'Cardura XL Prescribing Monograph',
      productName: 'Cardura XL',
      category: MaterialCategory.brochure,
      fileType: MaterialFileType.pdf,
      fileSizeBytes: 3400000,
      updatedAt: DateTime(2026, 11, 4),
      badge: MaterialBadge.updated,
      isFavorite: false,
      downloadState: const NotDownloaded(),
      viewCount: 140,
      description: 'Comprehensive pharmacokinetics.',
    ),
    MaterialItemEntity(
      id: 'mat_02',
      title: 'AtorvaCare SAMS Management Slide Deck',
      productName: 'AtorvaCare 20mg',
      category: MaterialCategory.edetail,
      fileType: MaterialFileType.edetailSlides,
      fileSizeBytes: 12000000,
      updatedAt: DateTime(2026, 11, 7),
      badge: MaterialBadge.newRelease,
      isFavorite: true,
      downloadState: Downloaded(DateTime.now()),
      viewCount: 88,
      description: 'Statin adherence clinical presentation.',
    ),
  ];

  setUp(() {
    mockRepository = MockLibraryRepository();
  });

  Widget buildTestableScreen(Widget child) {
    return ProviderScope(
      overrides: [
        libraryRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(
        theme: RxTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  group('LibraryScreen Widget Tests', () {
    testWidgets('renders search bar, filter chips, view header, and grid cards',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockRepository.getMaterials(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(testMaterials));

      await tester.pumpWidget(buildTestableScreen(const LibraryScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Search Bar
      expect(find.text('Search materials, monographs, trials...'), findsOneWidget);

      // 2. Filter chips & shortcuts
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Downloaded'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Brochures'), findsOneWidget);
      expect(find.text('Visual Aids'), findsOneWidget);
      expect(find.text('E-Detail'), findsOneWidget);

      // 3. View Header
      expect(find.text('2 approved materials'), findsOneWidget);

      // 4. Grid Cards
      expect(find.byType(MaterialCardGrid), findsNWidgets(2));
      expect(find.text('Cardura XL Prescribing Monograph'), findsOneWidget);
      expect(find.text('AtorvaCare SAMS Management Slide Deck'), findsOneWidget);
      expect(find.text('UPDATED'), findsOneWidget);
      expect(find.text('NEW'), findsOneWidget);
      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('toggles between Grid and List views', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockRepository.getMaterials(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(testMaterials));

      await tester.pumpWidget(buildTestableScreen(const LibraryScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(MaterialCardGrid), findsNWidgets(2));
      expect(find.byType(MaterialCardList), findsNothing);

      // Tap view toggle button
      await tester.tap(find.byTooltip('List view'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MaterialCardList), findsNWidgets(2));
      expect(find.byType(MaterialCardGrid), findsNothing);
    });

    testWidgets('shows empty search state when query has no matches',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockRepository.getMaterials(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(testMaterials));

      await tester.pumpWidget(buildTestableScreen(const LibraryScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Enter search query
      await tester.enterText(
        find.byType(TextField),
        'nonexistent query',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No results for "nonexistent query"'), findsOneWidget);
      expect(find.text('Clear all filters'), findsOneWidget);

      // Tap clear all filters
      await tester.tap(find.text('Clear all filters'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MaterialCardGrid), findsNWidgets(2));
    });

    testWidgets('renders offline banner and disables non-downloaded items when offline',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockRepository.getMaterials(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(testMaterials));

      await tester.pumpWidget(buildTestableScreen(const LibraryScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tap the simulate offline button in app bar
      await tester.tap(find.byTooltip('Simulate Offline Mode'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // OfflineBanner is visible
      expect(find.byType(OfflineBanner), findsOneWidget);

      // Online-only badge is displayed on mat_01
      expect(find.text('Online only'), findsOneWidget);

      // Tap non-downloaded item shows snackbar explaining it requires download
      await tester.tap(find.text('Cardura XL Prescribing Monograph'));
      await tester.pump();

      expect(find.text('Requires download to view offline'), findsOneWidget);
    });
  });
}
