import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/app/theme/theme.dart';
import 'package:rxedge/features/library/data/repositories/library_repository_impl.dart';
import 'package:rxedge/features/library/domain/entities/material_item_entity.dart';
import 'package:rxedge/features/library/domain/repositories/library_repository.dart';
import 'package:rxedge/features/library/presentation/screens/edetail_viewer_screen.dart';
import 'package:rxedge/features/library/presentation/screens/image_viewer_screen.dart';
import 'package:rxedge/features/library/presentation/screens/pdf_viewer_screen.dart';

class MockLibraryRepository extends Mock implements LibraryRepository {}

void main() {
  late MockLibraryRepository mockRepository;

  final testPdfMaterial = MaterialItemEntity(
    id: 'mat_pdf_01',
    title: 'Cardura XL Prescribing Monograph',
    productName: 'Cardura XL',
    category: MaterialCategory.brochure,
    fileType: MaterialFileType.pdf,
    fileSizeBytes: 3400000,
    updatedAt: DateTime(2026, 11, 4),
    badge: MaterialBadge.updated,
    isFavorite: false,
    downloadState: Downloaded(DateTime.now()),
    viewCount: 140,
    pageCount: 8,
    description: 'Comprehensive clinical pharmacokinetics.',
  );

  final testImageMaterial = MaterialItemEntity(
    id: 'mat_img_01',
    title: 'LipiShield Duo Comparative Chart',
    productName: 'LipiShield Duo',
    category: MaterialCategory.visualAid,
    fileType: MaterialFileType.image,
    fileSizeBytes: 1800000,
    updatedAt: DateTime(2026, 10, 28),
    badge: MaterialBadge.none,
    isFavorite: false,
    downloadState: Downloaded(DateTime.now()),
    viewCount: 210,
    pageCount: 1,
    description: 'Dual-action mechanism chart.',
  );

  final testEdetailMaterial = MaterialItemEntity(
    id: 'mat_edt_01',
    title: 'AtorvaCare SAMS Management Clinical Presentation',
    productName: 'AtorvaCare 20mg',
    category: MaterialCategory.edetail,
    fileType: MaterialFileType.edetailSlides,
    fileSizeBytes: 12000000,
    updatedAt: DateTime(2026, 11, 7),
    badge: MaterialBadge.newRelease,
    isFavorite: true,
    downloadState: Downloaded(DateTime.now()),
    viewCount: 88,
    pageCount: 2,
    description: 'Detailing deck on statin adherence.',
    slides: const [
      MaterialSlide(
        slideNumber: 1,
        title: 'Epidemiology of Statin Adherence',
        headline: 'Over 50% of high-risk ASCVD patients discontinue statins within year 1',
        clinicalKeyPoints: [
          'Subjective muscle ache is the #1 cited rationale.',
          'True myopathy incidence remains < 0.1%.',
        ],
        bulletEvidence: [
          'PRIMO Study (n=7,924): 10.5% reported muscle discomfort.',
          'AtorvaCare stabilized crystalline formulation reduces tissue variance.',
        ],
        chartCaption: 'Figure 1: Real-world discontinuation curves',
      ),
      MaterialSlide(
        slideNumber: 2,
        title: 'Pharmacokinetic Differentiation',
        headline: 'Targeted hepatic selectivity minimizes systemic muscle exposure',
        clinicalKeyPoints: [
          'High hepatic extraction ratio (>70%).',
          'Elimination half-life of 14 hours.',
        ],
        bulletEvidence: [
          'Minimal cytochrome P450 3A4 displacement.',
          'Steady-state bioavailability without mandatory food timing.',
        ],
        chartCaption: 'Figure 2: Plasma AUC comparison',
      ),
    ],
  );

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

  group('Dedicated Clinical Viewers Tests', () {
    testWidgets('PdfViewerScreen renders page indicator and allows multi-page navigation',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableScreen(
        PdfViewerScreen(material: testPdfMaterial),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Page 1 of 8'), findsWidgets);
      expect(find.text('REGULATORY CLINICAL MONOGRAPH'), findsOneWidget);
      expect(find.text('SECTION 01'), findsOneWidget);

      // Navigate to next page
      await tester.tap(find.byIcon(LucideIcons.chevronRight));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Page 2 of 8'), findsWidgets);
      expect(find.text('SECTION 02'), findsOneWidget);

      // Test Zoom In & Out
      await tester.tap(find.byIcon(LucideIcons.zoomIn));
      await tester.pump();
      await tester.tap(find.byIcon(LucideIcons.zoomOut));
      await tester.pump();
    });

    testWidgets('ImageViewerScreen renders pinch-zoomable visual aid',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableScreen(
        ImageViewerScreen(material: testImageMaterial),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('CLINICAL TRIAL VISUAL AID'), findsOneWidget);
      expect(find.text('LIPISHIELD DUO'), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);

      // Reset zoom
      await tester.tap(find.byIcon(LucideIcons.maximize2));
      await tester.pump();
    });

    testWidgets(
        'EdetailViewerScreen supports full-screen, swipe between slides, hide-chrome on tap, and detailing points sheet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableScreen(
        EdetailViewerScreen(material: testEdetailMaterial),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Initial slide check
      expect(find.text('Slide 1 of 2'), findsOneWidget);
      expect(find.text('EPIDEMIOLOGY OF STATIN ADHERENCE'), findsOneWidget);
      expect(
        find.text('Over 50% of high-risk ASCVD patients discontinue statins within year 1'),
        findsOneWidget,
      );

      // 2. Hide-chrome on tap: tapping anywhere toggles top & bottom bars
      // Initially chrome is shown (Doctor Detailing Key Points button is visible)
      expect(find.text('Doctor Detailing Key Points'), findsOneWidget);

      // Tap to hide chrome
      await tester.tap(find.byType(PageView));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250)); // Animation finished

      // Tap again to show chrome
      await tester.tap(find.byType(PageView));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Doctor Detailing Key Points'), findsOneWidget);

      // 3. Open Detailing Key Points Sheet
      await tester.tap(find.text('Doctor Detailing Key Points'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Subjective muscle ache is the #1 cited rationale.'), findsOneWidget);

      // Dismiss sheet
      Navigator.of(tester.element(find.text('Subjective muscle ache is the #1 cited rationale.'))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // 4. Swipe to Next Slide
      await tester.drag(find.byType(PageView), const Offset(-900.0, 0.0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Slide 2 of 2'), findsOneWidget);
      expect(find.text('PHARMACOKINETIC DIFFERENTIATION'), findsOneWidget);
    });
  });
}
