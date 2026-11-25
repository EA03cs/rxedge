import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/library/data/repositories/library_repository_impl.dart';
import 'package:rxedge/features/library/domain/entities/material_item_entity.dart';
import 'package:rxedge/features/library/domain/repositories/library_repository.dart';
import 'package:rxedge/features/library/presentation/screens/library_screen.dart';

class MockLibraryRepository extends Mock implements LibraryRepository {}

void main() {
  late MockLibraryRepository mockRepo;

  final rohtoMaterials = [
    // 1. Rohto Dry Aid Brochure with Google Drive Link and Q4 2026 badge
    MaterialItemEntity(
      id: 'mat-rohto-dry-aid',
      title: 'Rohto Dry Aid Clinical Brochure',
      productName: 'Rohto Dry Aid',
      category: MaterialCategory.brochure,
      fileType: MaterialFileType.pdf,
      fileSizeBytes: 2500000,
      updatedAt: DateTime(2026, 11, 15),
      quarter: 4,
      year: 2026,
      fileUrl: 'https://drive.google.com/file/d/sample_dry_aid_brochure/view?usp=drive_link',
      badge: MaterialBadge.none,
      isFavorite: false,
      downloadState: const NotDownloaded(),
      viewCount: 45,
      description: 'Rohto Dry Aid official detailing brochure',
    ),
    // 2. Rohto Aqua Brochure (Missing link in Excel -> Coming Soon)
    MaterialItemEntity(
      id: 'mat-rohto-aqua',
      title: 'Rohto Aqua Brochure',
      productName: 'Rohto Aqua',
      category: MaterialCategory.brochure,
      fileType: MaterialFileType.pdf,
      fileSizeBytes: 0,
      updatedAt: DateTime(2026, 11, 15),
      quarter: 4,
      year: 2026,
      fileUrl: null, // Missing link in Excel
      badge: MaterialBadge.none,
      isFavorite: false,
      downloadState: const NotDownloaded(),
      viewCount: 12,
      description: 'Rohto Aqua official brochure',
    ),
  ];

  setUp(() {
    mockRepo = MockLibraryRepository();
    when(() => mockRepo.getMaterials(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => Result.success(rohtoMaterials));
  });

  Widget buildEnglishLibraryScreen() {
    return ProviderScope(
      overrides: [
        libraryRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const MaterialApp(
        themeMode: ThemeMode.light,
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: [Locale('en')],
        home: LibraryScreen(),
      ),
    );
  }

  group('Marketing Hub Automated Tests (Module 2)', () {
    testWidgets('renders quarterly notice, product selector, quarterly badge and default Dry Aid filter',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildEnglishLibraryScreen());
      await tester.pumpAndSettle();

      // 1. Verify Quarterly update notice under title
      expect(find.text('Materials are updated quarterly.'), findsOneWidget);

      // 2. Verify Primary Product Selector (Rohto Dry Aid / Rohto Cool & Aqua)
      expect(find.text('Rohto Dry Aid'), findsWidgets);
      expect(find.text('Rohto Cool & Aqua'), findsOneWidget);

      // 3. Verify Material Sections
      expect(find.text('Brochures'), findsWidgets);
      expect(find.text('Visual Aids'), findsWidgets);
      expect(find.text('E-detailed Slides'), findsWidgets);

      // 4. Default selected product is Rohto Dry Aid, matching selector state
      expect(find.text('Rohto Dry Aid Clinical Brochure'), findsOneWidget);
      expect(find.text('Rohto Aqua Brochure'), findsNothing);

      // 5. Verify Quarterly Badge Q4 2026 and honest Open Online action on Drive brochure
      expect(find.text('Q4 2026'), findsOneWidget);
      expect(find.text('Open Online'), findsOneWidget);
      expect(find.text('Download'), findsNothing);

      // 6. Switch to Rohto Cool & Aqua -> Rohto Aqua to verify Coming Soon unlinked material
      await tester.tap(find.text('Rohto Cool & Aqua'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rohto Aqua'));
      await tester.pumpAndSettle();
      expect(find.text('Rohto Aqua Brochure'), findsOneWidget);
      expect(find.text('COMING SOON'), findsWidgets);
    });

    testWidgets('switching product in primary selector updates materials and shows coming soon',
        (tester) async {
      await tester.pumpWidget(buildEnglishLibraryScreen());
      await tester.pumpAndSettle();

      // Switch to Rohto Cool & Aqua
      await tester.tap(find.text('Rohto Cool & Aqua'));
      await tester.pumpAndSettle();

      // Verify sub-product pills appear
      expect(find.text('Rohto Cool'), findsOneWidget);
      expect(find.text('Rohto Aqua'), findsWidgets);

      // Select Rohto Dry Aid again
      await tester.tap(find.text('Rohto Dry Aid'));
      await tester.pumpAndSettle();

      expect(find.text('Rohto Dry Aid Clinical Brochure'), findsOneWidget);
    });

    testWidgets('tapping Coming Soon material displays neutral explanation snackbar',
        (tester) async {
      await tester.pumpWidget(buildEnglishLibraryScreen());
      await tester.pumpAndSettle();

      // Navigate to Rohto Aqua
      await tester.tap(find.text('Rohto Cool & Aqua'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rohto Aqua'));
      await tester.pumpAndSettle();

      // Tap Rohto Aqua card (which has null fileUrl)
      await tester.tap(find.text('Rohto Aqua Brochure'));
      await tester.pumpAndSettle();

      // Verify neutral message
      expect(
        find.text('No material available yet.'),
        findsOneWidget,
      );
    });

    testWidgets('Rohto Aqua Coming Soon badge in sub-filter is data-driven based on material count',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Case A: Rohto Aqua has 0 materials
      final dryAidOnly = [rohtoMaterials[0]];
      when(() => mockRepo.getMaterials(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(dryAidOnly));

      await tester.pumpWidget(buildEnglishLibraryScreen());
      await tester.pumpAndSettle();

      // Switch to Rohto Cool & Aqua segment
      await tester.tap(find.text('Rohto Cool & Aqua'));
      await tester.pumpAndSettle();

      // Sub-filter Rohto Aqua should show Coming Soon badge because count is 0
      expect(find.text('Coming Soon'), findsWidgets);

      // Select Rohto Aqua to view empty state banner
      await tester.tap(find.text('Rohto Aqua'));
      await tester.pumpAndSettle();

      // Banner must show neutral message with NO invented promises
      expect(find.text('No materials available yet for Rohto Aqua.'), findsOneWidget);
    });

    testWidgets('English copy has neutral coming soon and no invented promises',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockRepo.getMaterials(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success([rohtoMaterials[0]]));

      await tester.pumpWidget(ProviderScope(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: [Locale('en')],
          home: LibraryScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      // Visual Aids empty state: "To be developed later" (keep)
      expect(find.text('To be developed later'), findsWidgets);
      expect(find.text('Visual aids will be developed later.'), findsOneWidget);

      // E-detailed Slides empty state: "Coming Soon" with neutral line
      expect(find.text('Coming Soon'), findsWidgets);
      expect(find.text('No material available yet.'), findsWidgets);

      // Select Rohto Cool & Aqua, then Rohto Aqua
      await tester.tap(find.text('Rohto Cool & Aqua'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rohto Aqua'));
      await tester.pumpAndSettle();

      // Rohto Aqua banner: "No materials available yet for Rohto Aqua."
      expect(find.text('No materials available yet for Rohto Aqua.'), findsOneWidget);
    });
  });
}
