import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/file_download_service.dart';
import '../../../../core/storage/local_file_helper.dart';
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
      if (selectedProduct == 'Rohto Cool & Aqua' ||
          selectedProduct == 'Rohto Cool / Rohto Aqua') {
        items = items.where((item) {
          final p = item.productName.toLowerCase();
          return p.contains('cool') || p.contains('aqua');
        }).toList();
      } else if (selectedProduct == 'Rohto Dry Aid') {
        items = items.where((item) {
          final p = item.productName.toLowerCase();
          return p.contains('dry aid') || p == 'rohto dry aid';
        }).toList();
      } else {
        items = items.where((item) => item.productName == selectedProduct).toList();
      }
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
  List<MaterialItemEntity> _sanitizeMaterials(List<MaterialItemEntity> items) {
    return items.map((item) {
      if (item.downloadState is Downloaded &&
          !localFileExists(item.localFilePath)) {
        return item.copyWith(
          downloadState: const NotDownloaded(),
          clearLocalFilePath: true,
        );
      }
      return item;
    }).toList();
  }

  @override
  Future<LibraryState> build() async {
    final repository = ref.watch(libraryRepositoryProvider);
    final result = await repository.getMaterials();

    return result.when(
      success: (items) {
        final sanitized = _sanitizeMaterials(items);
        final hasRohto = sanitized.any(
          (item) => item.productName.toLowerCase().contains('rohto'),
        );
        return LibraryState(
          allMaterials: sanitized,
          selectedProduct: hasRohto ? 'Rohto Dry Aid' : null,
        );
      },
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

    // 1. Optimistic UI update for immediate response
    final optimisticList = current.allMaterials.map((item) {
      if (item.id == materialId) {
        return item.copyWith(isFavorite: !item.isFavorite);
      }
      return item;
    }).toList();
    state = AsyncData(current.copyWith(allMaterials: optimisticList));

    // 2. Persist in repository
    final repository = ref.read(libraryRepositoryProvider);
    final result = await repository.toggleFavorite(materialId);

    result.when(
      success: (updatedItem) {
        final latest = state.valueOrNull ?? current;
        final confirmedList = latest.allMaterials.map((item) {
          return item.id == materialId ? updatedItem : item;
        }).toList();
        state = AsyncData(latest.copyWith(allMaterials: confirmedList));
      },
      failure: (_) {
        // Rollback on failure
        state = AsyncData(current);
      },
    );
  }

  Future<void> startDownload(String materialId) async {
    final current = state.valueOrNull;
    if (current == null || current.isOffline) return;

    final matches = current.allMaterials.where((item) => item.id == materialId);
    if (matches.isEmpty) return;
    final targetItem = matches.first;

    // External links (Google Drive/Docs) or items without a direct downloadable
    // binary URL must never be faked as offline downloads.
    if (!targetItem.hasDirectDownloadUrl) {
      return;
    }

    final fileUrl = targetItem.fileUrl!.trim();
    final downloads = Map<String, double>.from(current.activeDownloads);
    downloads[materialId] = 0.08;

    final updatedList = current.allMaterials.map((item) {
      if (item.id == materialId) {
        return item.copyWith(downloadState: const Downloading(0.08));
      }
      return item;
    }).toList();

    state = AsyncData(current.copyWith(
      activeDownloads: downloads,
      allMaterials: updatedList,
    ));

    try {
      final downloadService = ref.read(fileDownloadServiceProvider);
      final ext = _resolveExtension(targetItem, fileUrl);
      final savePath = await downloadService.resolveLocalMaterialPath(
        materialId,
        ext: ext,
      );
      final localPath = await downloadService.downloadFile(
        fileUrl: fileUrl,
        savePath: savePath,
        onProgress: (received, total) {
          if (total <= 0) return;
          final latestState = state.valueOrNull;
          if (latestState == null) return;
          final ratio = (received / total).clamp(0.05, 0.99);
          final activeMap = Map<String, double>.from(latestState.activeDownloads);
          activeMap[materialId] = ratio;
          final progressingList = latestState.allMaterials.map((item) {
            if (item.id == materialId) {
              return item.copyWith(downloadState: Downloading(ratio));
            }
            return item;
          }).toList();
          state = AsyncData(latestState.copyWith(
            activeDownloads: activeMap,
            allMaterials: progressingList,
          ));
        },
      );

      // Only mark Downloaded when the real file actually exists on disk.
      if (localPath.trim().isEmpty || !localFileExists(localPath)) {
        cancelDownload(materialId);
        return;
      }

      final repository = ref.read(libraryRepositoryProvider);
      final markResult = await repository.markDownloaded(
        materialId,
        localFilePath: localPath,
      );
      if (markResult.isFailure) {
        cancelDownload(materialId);
        return;
      }

      final latestState = state.valueOrNull;
      if (latestState == null) return;
      final activeMap = Map<String, double>.from(latestState.activeDownloads)
        ..remove(materialId);
      final finishedList = latestState.allMaterials.map((item) {
        if (item.id == materialId) {
          return item.copyWith(
            downloadState: Downloaded(DateTime.now()),
            localFilePath: localPath,
          );
        }
        return item;
      }).toList();
      state = AsyncData(latestState.copyWith(
        activeDownloads: activeMap,
        allMaterials: finishedList,
      ));
    } catch (_) {
      cancelDownload(materialId);
    }
  }

  String _resolveExtension(MaterialItemEntity item, String fileUrl) {
    final uri = Uri.tryParse(fileUrl);
    final path = uri?.path ?? '';
    final dotIdx = path.lastIndexOf('.');
    if (dotIdx != -1 && dotIdx < path.length - 1) {
      final candidate = path.substring(dotIdx + 1).toLowerCase();
      if (candidate.length <= 5 && RegExp(r'^[a-z0-9]+$').hasMatch(candidate)) {
        return candidate;
      }
    }
    return item.fileType == MaterialFileType.pdf
        ? 'pdf'
        : (item.fileType == MaterialFileType.image ? 'png' : 'bin');
  }

  void cancelDownload(String materialId) {
    final current = state.valueOrNull;
    if (current == null) return;

    final downloads = Map<String, double>.from(current.activeDownloads)
      ..remove(materialId);
    final updatedList = current.allMaterials.map((item) {
      if (item.id == materialId) {
        return item.copyWith(
          downloadState: const NotDownloaded(),
          clearLocalFilePath: true,
        );
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
        return item.copyWith(
          downloadState: const NotDownloaded(),
          clearLocalFilePath: true,
        );
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
        success: (items) {
          final sanitized = _sanitizeMaterials(items);
          final hasRohto = sanitized.any(
            (item) => item.productName.toLowerCase().contains('rohto'),
          );
          return LibraryState(
            allMaterials: sanitized,
            selectedProduct: hasRohto ? 'Rohto Dry Aid' : null,
          );
        },
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
