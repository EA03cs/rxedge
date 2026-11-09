import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/library/data/repositories/library_repository_impl.dart';
import 'package:rxedge/features/library/domain/entities/material_item_entity.dart';
import 'package:rxedge/features/library/domain/repositories/library_repository.dart';
import 'package:rxedge/features/library/presentation/controllers/library_controller.dart';

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
      viewCount: 210,
      description: 'Dual-action mechanism chart.',
    ),
  ];

  setUp(() {
    mockRepository = MockLibraryRepository();
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

      await container.read(libraryControllerProvider.future);
      final controller = container.read(libraryControllerProvider.notifier);

      expect(container.read(libraryControllerProvider).value!.isGridView, isTrue);
      controller.toggleGridView();
      expect(container.read(libraryControllerProvider).value!.isGridView, isFalse);

      expect(container.read(libraryControllerProvider).value!.isOffline, isFalse);
      controller.setOfflineMode(true);
      expect(container.read(libraryControllerProvider).value!.isOffline, isTrue);
    });
  });
}
