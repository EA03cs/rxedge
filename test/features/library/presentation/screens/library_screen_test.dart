import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
import 'package:url_launcher/url_launcher.dart';

class MockLibraryRepository extends Mock implements LibraryRepository {}

void main() {
  late MockLibraryRepository mockRepository;
  late Directory tempDir;
  late File fileMat02;
  late List<MaterialItemEntity> testMaterials;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('rxedge_screen_test_');
    fileMat02 = File('${tempDir.path}/mat_02.bin')..writeAsStringSync('slides');
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    testMaterials = [
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
        localFilePath: fileMat02.path,
        viewCount: 88,
        description: 'Statin adherence clinical presentation.',
      ),
    ];

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

      // 1. Search Bar & Quarterly Notice
      expect(find.text('Materials are updated quarterly.'), findsOneWidget);
      expect(find.text('Search materials, monographs, trials...'), findsOneWidget);

      // 2. Filter chips & shortcuts
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Downloaded'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Brochures'), findsWidgets);
      expect(find.text('Visual Aids'), findsWidgets);
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

    testWidgets(
        'external Drive/Docs links show Open Online, hide Download, and launch externally',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      Uri? launchedUri;
      LaunchMode? launchedMode;

      final driveMaterials = [
        MaterialItemEntity(
          id: 'mat_drive_01',
          title: 'Rohto Dry Aid Brochure',
          productName: 'Rohto Dry Aid',
          category: MaterialCategory.brochure,
          fileType: MaterialFileType.pdf,
          fileSizeBytes: 1258291,
          updatedAt: DateTime(2026, 11, 19),
          badge: MaterialBadge.newRelease,
          description: 'Tearshield brochure on Google Drive.',
          fileUrl:
              'https://drive.google.com/file/d/1jaenvaltpOhA0x82DN2OHV39twZn9ms-/view?usp=drive_link',
        ),
        MaterialItemEntity(
          id: 'mat_direct_01',
          title: 'Rohto Dry Aid Direct PDF',
          productName: 'Rohto Dry Aid',
          category: MaterialCategory.brochure,
          fileType: MaterialFileType.pdf,
          fileSizeBytes: 950000,
          updatedAt: DateTime(2026, 11, 20),
          badge: MaterialBadge.none,
          description: 'Direct downloadable PDF.',
          fileUrl: 'https://cdn.example.com/rohto_dry_aid_direct.pdf',
        ),
      ];

      when(() => mockRepository.getMaterials(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(driveMaterials));

      await tester.pumpWidget(
        buildTestableScreen(
          LibraryScreen(
            externalUrlLauncher: (uri, {mode = LaunchMode.platformDefault}) async {
              launchedUri = uri;
              launchedMode = mode;
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Grid view: Drive brochure shows exactly one "Open Online", direct PDF shows "Download"
      expect(find.text('Open Online'), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);

      // Tap Open Online on Grid card -> launches externally
      await tester.tap(find.text('Open Online'));
      await tester.pump();
      expect(launchedUri.toString(), contains('drive.google.com'));
      expect(launchedMode, LaunchMode.externalApplication);

      // Switch to List view -> Drive card shows Open Online and hides Download button
      await tester.tap(find.byTooltip('List view'));
      await tester.pumpAndSettle();

      expect(find.text('Open Online'), findsOneWidget);
      expect(find.byTooltip('Download'), findsOneWidget);

      // Open actions sheet on the Drive card -> shows Open Online and hides Download
      final driveMoreIcons = find.descendant(
        of: find.widgetWithText(MaterialCardList, 'Rohto Dry Aid Brochure'),
        matching: find.byIcon(LucideIcons.moreVertical),
      );
      await tester.tap(driveMoreIcons);
      await tester.pumpAndSettle();

      expect(find.text('Open Online'), findsWidgets);
      expect(find.text('Store 1.2 MB on device for offline detailing'), findsNothing);
    });

    testWidgets(
        'non-binary web URLs show Open Online and hide Download; null URLs keep Coming Soon',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mixedMaterials = [
        MaterialItemEntity(
          id: 'mat_docs_01',
          title: 'Rohto Cool Portal Link',
          productName: 'Rohto Cool',
          category: MaterialCategory.brochure,
          fileType: MaterialFileType.pdf,
          fileSizeBytes: 500000,
          updatedAt: DateTime(2026, 11, 19),
          description: 'Hosted web document.',
          fileUrl: 'https://docs.google.com/document/d/abc123/edit',
        ),
        MaterialItemEntity(
          id: 'mat_aqua_01',
          title: 'Rohto Aqua Brochure',
          productName: 'Rohto Aqua',
          category: MaterialCategory.brochure,
          fileType: MaterialFileType.pdf,
          fileSizeBytes: 0,
          updatedAt: DateTime(2026, 11, 19),
          description: 'Pending brochure.',
          fileUrl: null,
        ),
      ];

      when(() => mockRepository.getMaterials(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(mixedMaterials));

      await tester.pumpWidget(buildTestableScreen(const LibraryScreen()));
      await tester.pumpAndSettle();

      // Switch to Rohto Cool & Aqua -> Rohto Cool
      await tester.tap(find.text('Rohto Cool & Aqua'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rohto Cool'));
      await tester.pumpAndSettle();

      expect(find.text('Open Online'), findsOneWidget);
      expect(find.text('Download'), findsNothing);

      // Switch to Rohto Aqua -> Coming Soon state, no Download and no Open Online
      await tester.tap(find.text('Rohto Aqua'));
      await tester.pumpAndSettle();

      expect(find.text('Rohto Aqua Brochure'), findsOneWidget);
      expect(find.text('COMING SOON'), findsOneWidget);
      expect(find.text('Open Online'), findsNothing);
      expect(find.text('Download'), findsNothing);
    });
  });
}
