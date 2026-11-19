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

  Widget buildArabicLibraryScreen() {
    return ProviderScope(
      overrides: [
        libraryRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const MaterialApp(
        themeMode: ThemeMode.light,
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LibraryScreen(),
      ),
    );
  }

  group('Marketing Hub Automated Tests (Module 2)', () {
    testWidgets('renders quarterly badge (Q4 2026) and Coming Soon for unlinked materials',
        (tester) async {
      await tester.pumpWidget(buildArabicLibraryScreen());
      await tester.pumpAndSettle();

      // Verify materials are present
      expect(find.text('Rohto Dry Aid Clinical Brochure'), findsOneWidget);
      expect(find.text('Rohto Aqua Brochure'), findsOneWidget);

      // Verify Quarterly Badge Q4 2026 on available material
      expect(find.text('Q4 2026'), findsOneWidget);

      // Verify Coming Soon "قريباً" on unlinked Rohto Aqua material
      expect(find.text('قريباً'), findsOneWidget);
    });

    testWidgets('tapping Coming Soon material displays friendly explanation snackbar',
        (tester) async {
      await tester.pumpWidget(buildArabicLibraryScreen());
      await tester.pumpAndSettle();

      // Tap Rohto Aqua card (which has null fileUrl)
      await tester.tap(find.text('Rohto Aqua Brochure'));
      await tester.pumpAndSettle();

      // Verify Arabic message
      expect(
        find.text('هذه المادة قيد الإعداد والمراجعة الطبية وستتوفر قريباً.'),
        findsOneWidget,
      );
    });
  });
}
