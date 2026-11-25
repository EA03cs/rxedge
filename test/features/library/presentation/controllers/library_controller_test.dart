import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/core/services/file_download_service.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/library/data/repositories/library_repository_impl.dart';
import 'package:rxedge/features/library/domain/entities/material_item_entity.dart';
import 'package:rxedge/features/library/domain/repositories/library_repository.dart';
import 'package:rxedge/features/library/presentation/controllers/library_controller.dart';

class MockLibraryRepository extends Mock implements LibraryRepository {}

class MockFileDownloadService extends Mock implements FileDownloadService {}

void main() {
  late MockLibraryRepository mockRepository;
  late MockFileDownloadService mockDownloadService;
  late Directory tempDir;
  late File fileMat02;
  late File fileMat03;
  late List<MaterialItemEntity> testMaterials;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('rxedge_ctrl_test_');
    fileMat02 = File('${tempDir.path}/mat_02.bin')..writeAsStringSync('slides');
    fileMat03 = File('${tempDir.path}/mat_03.png')..writeAsStringSync('image');
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
      MaterialItemEntity(
        id: 'mat_03',
        title: 'LipiShield Duo Comparative Chart',
        productName: 'LipiShield Duo',
        category: MaterialCategory.visualAid,
        fileType: MaterialFileType.image,
        fileSizeBytes: 1800000,
        updatedAt: DateTime(2026, 10, 28),
        badge: MaterialBadge.none,
        isFavorite: false,
        downloadState: Downloaded(DateTime.now()),
        localFilePath: fileMat03.path,
        viewCount: 210,
        description: 'Dual-action mechanism chart.',
      ),
    ];

    mockRepository = MockLibraryRepository();
    mockDownloadService = MockFileDownloadService();
  });

  group('LibraryController Tests', () {
    test('initial state loads all materials into AsyncData', () async {
      when(() => mockRepository.getMaterials(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(testMaterials));

      final container = ProviderContainer(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);
      container.listen(libraryControllerProvider, (p, n) {});

      final subscription = container.listen(libraryControllerProvider, (p, n) {});
      expect(subscription.read(), const AsyncValue<LibraryState>.loading());

      await container.read(libraryControllerProvider.future);

      final state = subscription.read().value!;
      expect(state.allMaterials.length, 3);
      expect(state.filteredMaterials.length, 3);
      expect(state.availableProducts.length, 3);
    });

    test('filters materials by search query', () async {
      when(() => mockRepository.getMaterials(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(testMaterials));

      final container = ProviderContainer(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);
      container.listen(libraryControllerProvider, (p, n) {});

      await container.read(libraryControllerProvider.future);
      final controller = container.read(libraryControllerProvider.notifier);

      controller.setSearchQuery('atorva');

      final state = container.read(libraryControllerProvider).value!;
      expect(state.filteredMaterials.length, 1);
      expect(state.filteredMaterials.first.productName, 'AtorvaCare 20mg');
    });

    test('filters materials by category and product', () async {
      when(() => mockRepository.getMaterials(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(testMaterials));

      final container = ProviderContainer(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);
      container.listen(libraryControllerProvider, (p, n) {});

      await container.read(libraryControllerProvider.future);
      final controller = container.read(libraryControllerProvider.notifier);

      // Filter by category: visualAid
      controller.setCategory(MaterialCategory.visualAid);
      var state = container.read(libraryControllerProvider).value!;
      expect(state.filteredMaterials.length, 1);
      expect(state.filteredMaterials.first.id, 'mat_03');

      // Filter by product: Cardura XL with All categories
      controller.setCategory(MaterialCategory.all);
      controller.setProduct('Cardura XL');
      state = container.read(libraryControllerProvider).value!;
      expect(state.filteredMaterials.length, 1);
      expect(state.filteredMaterials.first.productName, 'Cardura XL');
    });

    test('filters materials by shortcuts (favorites and downloaded)', () async {
      when(() => mockRepository.getMaterials(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(testMaterials));

      final container = ProviderContainer(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);
      container.listen(libraryControllerProvider, (p, n) {});

      await container.read(libraryControllerProvider.future);
      final controller = container.read(libraryControllerProvider.notifier);

      // Favorites shortcut
      controller.toggleShortcut(LibraryShortcut.favorites);
      var state = container.read(libraryControllerProvider).value!;
      expect(state.filteredMaterials.length, 1);
      expect(state.filteredMaterials.first.id, 'mat_02');

      // Downloaded shortcut
      controller.toggleShortcut(LibraryShortcut.downloaded);
      state = container.read(libraryControllerProvider).value!;
      expect(state.filteredMaterials.length, 2);
    });

    test('sorts materials by mostUsed and alphabetical', () async {
      when(() => mockRepository.getMaterials(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(testMaterials));

      final container = ProviderContainer(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);
      container.listen(libraryControllerProvider, (p, n) {});

      await container.read(libraryControllerProvider.future);
      final controller = container.read(libraryControllerProvider.notifier);

      // Sort by mostUsed (viewCount 210 -> mat_03 first)
      controller.setSortOption(LibrarySortOption.mostUsed);
      var state = container.read(libraryControllerProvider).value!;
      expect(state.filteredMaterials.first.id, 'mat_03');

      // Sort alphabetical ('AtorvaCare...' -> mat_02 first)
      controller.setSortOption(LibrarySortOption.alphabetical);
      state = container.read(libraryControllerProvider).value!;
      expect(state.filteredMaterials.first.id, 'mat_02');
    });

    test('toggles grid/list view and offline mode', () async {
      when(() => mockRepository.getMaterials(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(testMaterials));

      final container = ProviderContainer(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);
      container.listen(libraryControllerProvider, (p, n) {});

      await container.read(libraryControllerProvider.future);
      final controller = container.read(libraryControllerProvider.notifier);

      expect(container.read(libraryControllerProvider).value!.isGridView, isTrue);
      controller.toggleGridView();
      expect(container.read(libraryControllerProvider).value!.isGridView, isFalse);

      expect(container.read(libraryControllerProvider).value!.isOffline, isFalse);
      controller.setOfflineMode(true);
      expect(container.read(libraryControllerProvider).value!.isOffline, isTrue);
    });

    test('build sanitizes fake Downloaded state when local file does not exist on disk', () async {
      final fakeDownloadedMaterials = [
        MaterialItemEntity(
          id: 'mat_fake',
          title: 'Fake Downloaded Brochure',
          productName: 'Rohto Dry Aid',
          category: MaterialCategory.brochure,
          fileType: MaterialFileType.pdf,
          fileSizeBytes: 1024,
          updatedAt: DateTime(2026, 11, 10),
          description: 'No file on disk.',
          downloadState: Downloaded(DateTime.now()),
          localFilePath: '${tempDir.path}/does_not_exist.pdf',
        ),
      ];

      when(() => mockRepository.getMaterials(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(fakeDownloadedMaterials));

      final container = ProviderContainer(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);
      container.listen(libraryControllerProvider, (p, n) {});

      await container.read(libraryControllerProvider.future);
      final item = container.read(libraryControllerProvider).value!.allMaterials.first;

      expect(item.isDownloaded, isFalse);
      expect(item.downloadState, isA<NotDownloaded>());
      expect(item.localFilePath, isNull);
    });

    test('startDownload never fakes progress or Downloaded for Drive or missing URLs', () async {
      final externalMaterials = [
        MaterialItemEntity(
          id: 'mat_drive',
          title: 'Rohto Dry Aid Brochure',
          productName: 'Rohto Dry Aid',
          category: MaterialCategory.brochure,
          fileType: MaterialFileType.pdf,
          fileSizeBytes: 1200000,
          updatedAt: DateTime(2026, 11, 19),
          description: 'External Google Drive brochure.',
          fileUrl: 'https://drive.google.com/file/d/1jaenvaltpOhA0x82DN2OHV39twZn9ms-/view',
        ),
        MaterialItemEntity(
          id: 'mat_empty',
          title: 'Rohto Aqua Brochure',
          productName: 'Rohto Aqua',
          category: MaterialCategory.brochure,
          fileType: MaterialFileType.pdf,
          fileSizeBytes: 0,
          updatedAt: DateTime(2026, 11, 19),
          description: 'Coming soon.',
          fileUrl: null,
        ),
      ];

      when(() => mockRepository.getMaterials(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(externalMaterials));

      final container = ProviderContainer(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(mockRepository),
          fileDownloadServiceProvider.overrideWithValue(mockDownloadService),
        ],
      );
      addTearDown(container.dispose);
      container.listen(libraryControllerProvider, (p, n) {});

      await container.read(libraryControllerProvider.future);
      final controller = container.read(libraryControllerProvider.notifier);

      await controller.startDownload('mat_drive');
      await controller.startDownload('mat_empty');
      await Future<void>.delayed(const Duration(milliseconds: 350));

      final state = container.read(libraryControllerProvider).value!;
      expect(state.allMaterials[0].isDownloaded, isFalse);
      expect(state.allMaterials[0].isDownloading, isFalse);
      expect(state.allMaterials[1].isDownloaded, isFalse);
      expect(state.allMaterials[1].isDownloading, isFalse);
      expect(state.activeDownloads, isEmpty);

      verifyNever(() => mockDownloadService.downloadFile(
            fileUrl: any(named: 'fileUrl'),
            savePath: any(named: 'savePath'),
            onProgress: any(named: 'onProgress'),
          ));
      verifyNever(() => mockRepository.markDownloaded(
            any(),
            localFilePath: any(named: 'localFilePath'),
          ));
    });

    test('startDownload resets to NotDownloaded if download fails or file is missing on disk', () async {
      final binaryMaterial = MaterialItemEntity(
        id: 'mat_pdf',
        title: 'Direct PDF Brochure',
        productName: 'Rohto Dry Aid',
        category: MaterialCategory.brochure,
        fileType: MaterialFileType.pdf,
        fileSizeBytes: 1200000,
        updatedAt: DateTime(2026, 11, 19),
        description: 'Direct PDF.',
        fileUrl: 'https://cdn.example.com/rohto_dry_aid.pdf',
      );

      when(() => mockRepository.getMaterials(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success([binaryMaterial]));
      when(() => mockDownloadService.resolveLocalMaterialPath('mat_pdf', ext: 'pdf'))
          .thenAnswer((_) async => '${tempDir.path}/not_written.pdf');
      // Returns path that was never written to disk
      when(() => mockDownloadService.downloadFile(
            fileUrl: any(named: 'fileUrl'),
            savePath: any(named: 'savePath'),
            onProgress: any(named: 'onProgress'),
          )).thenAnswer((_) async => '${tempDir.path}/not_written.pdf');

      final container = ProviderContainer(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(mockRepository),
          fileDownloadServiceProvider.overrideWithValue(mockDownloadService),
        ],
      );
      addTearDown(container.dispose);
      container.listen(libraryControllerProvider, (p, n) {});

      await container.read(libraryControllerProvider.future);
      final controller = container.read(libraryControllerProvider.notifier);

      await controller.startDownload('mat_pdf');

      var item = container.read(libraryControllerProvider).value!.allMaterials.first;
      expect(item.isDownloaded, isFalse);
      expect(item.localFilePath, isNull);
      verifyNever(() => mockRepository.markDownloaded(
            any(),
            localFilePath: any(named: 'localFilePath'),
          ));

      // Also verify exception during download never falls back to fake timer
      when(() => mockDownloadService.downloadFile(
            fileUrl: any(named: 'fileUrl'),
            savePath: any(named: 'savePath'),
            onProgress: any(named: 'onProgress'),
          )).thenThrow(Exception('Network error'));

      await controller.startDownload('mat_pdf');
      await Future<void>.delayed(const Duration(milliseconds: 350));

      item = container.read(libraryControllerProvider).value!.allMaterials.first;
      expect(item.isDownloaded, isFalse);
      expect(item.isDownloading, isFalse);
    });

    test('startDownload marks Downloaded only when real file exists on disk', () async {
      final savedFilePath = '${tempDir.path}/rohto_dry_aid.pdf';
      final binaryMaterial = MaterialItemEntity(
        id: 'mat_pdf_ok',
        title: 'Direct PDF Brochure',
        productName: 'Rohto Dry Aid',
        category: MaterialCategory.brochure,
        fileType: MaterialFileType.pdf,
        fileSizeBytes: 1200000,
        updatedAt: DateTime(2026, 11, 19),
        description: 'Direct PDF.',
        fileUrl: 'https://cdn.example.com/rohto_dry_aid.pdf',
      );

      when(() => mockRepository.getMaterials(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success([binaryMaterial]));
      when(() => mockDownloadService.resolveLocalMaterialPath('mat_pdf_ok', ext: 'pdf'))
          .thenAnswer((_) async => savedFilePath);
      when(() => mockDownloadService.downloadFile(
            fileUrl: any(named: 'fileUrl'),
            savePath: any(named: 'savePath'),
            onProgress: any(named: 'onProgress'),
          )).thenAnswer((_) async {
        File(savedFilePath).writeAsStringSync('%PDF-1.4');
        return savedFilePath;
      });
      when(() => mockRepository.markDownloaded('mat_pdf_ok', localFilePath: savedFilePath))
          .thenAnswer((_) async => const Result.success(null));

      final container = ProviderContainer(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(mockRepository),
          fileDownloadServiceProvider.overrideWithValue(mockDownloadService),
        ],
      );
      addTearDown(container.dispose);
      container.listen(libraryControllerProvider, (p, n) {});

      await container.read(libraryControllerProvider.future);
      final controller = container.read(libraryControllerProvider.notifier);

      await controller.startDownload('mat_pdf_ok');

      final state = container.read(libraryControllerProvider).value!;
      final item = state.allMaterials.first;
      expect(item.isDownloaded, isTrue);
      expect(item.localFilePath, savedFilePath);
      expect(File(savedFilePath).existsSync(), isTrue);
      expect(state.activeDownloads, isEmpty);
      verify(() => mockRepository.markDownloaded('mat_pdf_ok', localFilePath: savedFilePath))
          .called(1);
    });
  });
}
