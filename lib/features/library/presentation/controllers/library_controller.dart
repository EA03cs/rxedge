import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/library_repository_impl.dart';
import '../../domain/entities/material_item_entity.dart';

/// State object for Resource Library
class LibraryState {
  final List<MaterialItemEntity> allMaterials;
  final String searchQuery;
  final MaterialCategory selectedCategory;
  final String? selectedProduct;
  final LibrarySortOption sortOption;
  final LibraryShortcut activeShortcut;
  final bool isGridView;
  final bool isOffline;
  final Map<String, double> activeDownloads;

  const LibraryState({
    required this.allMaterials,
    this.searchQuery = '',
    this.selectedCategory = MaterialCategory.all,
    this.selectedProduct,
    this.sortOption = LibrarySortOption.newest,
    this.activeShortcut = LibraryShortcut.none,
    this.isGridView = true,
    this.isOffline = false,
    this.activeDownloads = const {},
  });

  /// Derives all available distinct pharmaceutical product names
  List<String> get availableProducts {
    final products = allMaterials.map((e) => e.productName).toSet().toList();
    products.sort();
    return products;
  }

  /// Derives filtered, searched, and sorted materials
  List<MaterialItemEntity> get filteredMaterials {
    var items = List<MaterialItemEntity>.from(allMaterials);

    // 1. Search filter
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      items = items.where((item) {
        return item.title.toLowerCase().contains(q) ||
            item.productName.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q);
      }).toList();
    }

    // 2. Category filter
    if (selectedCategory != MaterialCategory.all) {
      items = items.where((item) => item.category == selectedCategory).toList();
    }

    // 3. Product filter
    if (selectedProduct != null && selectedProduct!.isNotEmpty) {
      items = items.where((item) => item.productName == selectedProduct).toList();
    }

    // 4. Shortcuts
    if (activeShortcut == LibraryShortcut.favorites) {
      items = items.where((item) => item.isFavorite).toList();
    } else if (activeShortcut == LibraryShortcut.downloaded) {
      items = items.where((item) => item.isDownloaded).toList();
    }

    // 5. Sorting
    switch (sortOption) {
      case LibrarySortOption.newest:
        items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case LibrarySortOption.mostUsed:
        items.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      case LibrarySortOption.alphabetical:
        items.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }

    return items;
  }

  LibraryState copyWith({
    List<MaterialItemEntity>? allMaterials,
    String? searchQuery,
    MaterialCategory? selectedCategory,
    String? Function()? selectedProduct,
    LibrarySortOption? sortOption,
    LibraryShortcut? activeShortcut,
    bool? isGridView,
    bool? isOffline,
    Map<String, double>? activeDownloads,
  }) {
    return LibraryState(
      allMaterials: allMaterials ?? this.allMaterials,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedProduct:
          selectedProduct != null ? selectedProduct() : this.selectedProduct,
      sortOption: sortOption ?? this.sortOption,
      activeShortcut: activeShortcut ?? this.activeShortcut,
      isGridView: isGridView ?? this.isGridView,
      isOffline: isOffline ?? this.isOffline,
      activeDownloads: activeDownloads ?? this.activeDownloads,
    );
  }
}

/// Controller managing Resource Library state and actions
class LibraryController extends AutoDisposeAsyncNotifier<LibraryState> {
  final Map<String, Timer> _downloadTimers = {};

  @override
  Future<LibraryState> build() async {
    final repository = ref.watch(libraryRepositoryProvider);
    final result = await repository.getMaterials();

    return result.when(
      success: (items) => LibraryState(allMaterials: items),
      failure: (failure) => throw failure,
    );
  }

  void setSearchQuery(String query) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(searchQuery: query));
  }

  void setCategory(MaterialCategory category) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedCategory: category));
  }

  void setProduct(String? product) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedProduct: () => product));
  }

  void setSortOption(LibrarySortOption sort) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(sortOption: sort));
  }

  void toggleShortcut(LibraryShortcut shortcut) {
    final current = state.valueOrNull;
    if (current == null) return;
    final next = current.activeShortcut == shortcut ? LibraryShortcut.none : shortcut;
    state = AsyncData(current.copyWith(activeShortcut: next));
  }

  void toggleGridView() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(isGridView: !current.isGridView));
  }

  void setOfflineMode(bool offline) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(isOffline: offline));
  }

  Future<void> toggleFavorite(String materialId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final repository = ref.read(libraryRepositoryProvider);
    final result = await repository.toggleFavorite(materialId);

    result.when(
      success: (updatedItem) {
        final updatedList = current.allMaterials.map((item) {
          return item.id == materialId ? updatedItem : item;
        }).toList();
        state = AsyncData(current.copyWith(allMaterials: updatedList));
      },
      failure: (_) {},
    );
  }

  Future<void> startDownload(String materialId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final downloads = Map<String, double>.from(current.activeDownloads);
    downloads[materialId] = 0.15;

    // Update item's download state in memory
    final updatedList = current.allMaterials.map((item) {
      if (item.id == materialId) {
        return item.copyWith(downloadState: const Downloading(0.15));
      }
      return item;
    }).toList();

    state = AsyncData(current.copyWith(
      activeDownloads: downloads,
      allMaterials: updatedList,
    ));

    // Cancel any previous timer
    _downloadTimers[materialId]?.cancel();

    // Simulate realistic stepped progress
    var progress = 0.15;
    _downloadTimers[materialId] = Timer.periodic(
      const Duration(milliseconds: 120),
      (timer) async {
        progress += 0.25;
        final latestState = state.valueOrNull;
        if (latestState == null) {
          timer.cancel();
          return;
        }

        if (progress >= 1.0) {
          timer.cancel();
          _downloadTimers.remove(materialId);

          final activeMap = Map<String, double>.from(latestState.activeDownloads)
            ..remove(materialId);

          final repository = ref.read(libraryRepositoryProvider);
          await repository.markDownloaded(materialId);

          final finishedList = latestState.allMaterials.map((item) {
            if (item.id == materialId) {
              return item.copyWith(downloadState: Downloaded(DateTime.now()));
            }
            return item;
          }).toList();

          state = AsyncData(latestState.copyWith(
            activeDownloads: activeMap,
            allMaterials: finishedList,
          ));
        } else {
          final activeMap = Map<String, double>.from(latestState.activeDownloads);
          activeMap[materialId] = progress;

          final progressingList = latestState.allMaterials.map((item) {
            if (item.id == materialId) {
              return item.copyWith(downloadState: Downloading(progress));
            }
            return item;
          }).toList();

          state = AsyncData(latestState.copyWith(
            activeDownloads: activeMap,
            allMaterials: progressingList,
          ));
        }
      },
    );
  }

  void cancelDownload(String materialId) {
    _downloadTimers[materialId]?.cancel();
    _downloadTimers.remove(materialId);

    final current = state.valueOrNull;
    if (current == null) return;

    final downloads = Map<String, double>.from(current.activeDownloads)..remove(materialId);
    final updatedList = current.allMaterials.map((item) {
      if (item.id == materialId) {
        return item.copyWith(downloadState: const NotDownloaded());
      }
      return item;
    }).toList();

    state = AsyncData(current.copyWith(
      activeDownloads: downloads,
      allMaterials: updatedList,
    ));
  }

  Future<void> removeDownload(String materialId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final repository = ref.read(libraryRepositoryProvider);
    await repository.removeDownload(materialId);

    final updatedList = current.allMaterials.map((item) {
      if (item.id == materialId) {
        return item.copyWith(downloadState: const NotDownloaded());
      }
      return item;
    }).toList();

    state = AsyncData(current.copyWith(allMaterials: updatedList));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(libraryRepositoryProvider);
      final result = await repository.getMaterials(forceRefresh: true);

      return result.when(
        success: (items) => LibraryState(allMaterials: items),
        failure: (failure) => throw failure,
      );
    });
  }
}

/// Riverpod Provider for LibraryController
final libraryControllerProvider =
    AutoDisposeAsyncNotifierProvider<LibraryController, LibraryState>(
  LibraryController.new,
);
