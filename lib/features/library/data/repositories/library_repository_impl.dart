import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/local_file_helper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/material_item_entity.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_local_datasource.dart';
import '../datasources/library_remote_datasource.dart';
import '../models/material_item_dto.dart';

/// Repository Implementation for Resource Library
///
/// Follows Architectural Contracts:
/// 1. Repositories return Result, never throw into the UI.
/// 2. Caches remote data (stale-while-revalidate).
/// 3. Locally persists user overrides (Favorites and Downloaded states).
class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDatasource _remoteDatasource;
  final LibraryLocalDatasource _localDatasource;

  // In-memory working cache
  List<MaterialItemEntity>? _memoryItems;

  static const List<MaterialItemDto> rohtoMaterials = [
    MaterialItemDto(
      id: 'mat_rohto_cool_brochure',
      title: 'Rohto Cool',
      productName: 'Rohto Cool',
      category: 'brochure',
      fileType: 'pdf',
      fileSizeBytes: 957 * 1024,
      updatedAt: '2026-11-19T11:00:00Z',
      badge: 'new',
      isFavorite: false,
      isDownloaded: false,
      viewCount: 180,
      pageCount: 8,
      thumbnailUrl: 'assets/images/rohto_cool.png',
      fileUrl:
          'https://drive.google.com/file/d/1MYbkjhlgiovvJe7AE_XIGPVhg2YlZZ9l/view?usp=sharing',
      description: 'Rohto Cool Brochure',
    ),
    MaterialItemDto(
      id: 'mat_rohto_dry_aid_brochure',
      title: 'Rohto Dry Aid',
      productName: 'Rohto Dry Aid',
      category: 'brochure',
      fileType: 'pdf',
      fileSizeBytes: 1258291, // 1.2 MB
      updatedAt: '2026-11-19T12:00:00Z',
      badge: 'new',
      isFavorite: false,
      isDownloaded: false,
      viewCount: 210,
      pageCount: 10,
      thumbnailUrl: 'assets/images/rohto_dry_aid.png',
      fileUrl:
          'https://drive.google.com/file/d/1jaenvaltpOhA0x82DN2OHV39twZn9ms-/view?usp=drive_link',
      description: 'Rohto Dry Aid Brochure & Key Messages',
    ),
  ];

  List<MaterialItemDto> _ensureRohtoMaterials(List<MaterialItemDto> dtos) {
    if (dtos.isNotEmpty) return dtos;
    return rohtoMaterials;
  }

  LibraryRepositoryImpl({
    required LibraryRemoteDatasource remoteDatasource,
    required LibraryLocalDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  @override
  Future<Result<List<MaterialItemEntity>>> getMaterials({bool forceRefresh = false}) async {
    // 1. If in-memory items exist and not forcing refresh, return immediately
    if (!forceRefresh && _memoryItems != null && _memoryItems!.isNotEmpty) {
      return Result.success(_memoryItems!);
    }

    // 2. Check fresh local cache
    if (!forceRefresh && _localDatasource.isCacheFresh()) {
      try {
        final cached = await _localDatasource.getCachedMaterials();
        if (cached != null && cached.isNotEmpty) {
          AppLogger.d('Returning fresh cached Library materials');
          final ensured = _ensureRohtoMaterials(cached);
          final domainItems = await _mergeWithLocalOverrides(ensured);
          _memoryItems = domainItems;
          return Result.success(domainItems);
        }
      } catch (e) {
        AppLogger.w('Failed reading cached materials, falling back: $e');
      }
    }

    // 3. Fetch from remote
    try {
      AppLogger.d('Fetching remote Library materials...');
      final remoteList = await _remoteDatasource.getMaterials();
      final ensured = _ensureRohtoMaterials(remoteList);
      await _localDatasource.cacheMaterials(ensured);

      final domainItems = await _mergeWithLocalOverrides(ensured);
      _memoryItems = domainItems;
      return Result.success(domainItems);
    } catch (e) {
      AppLogger.w('Remote library fetch failed, attempting stale fallback', error: e);

      // Stale cache fallback
      try {
        final staleCache = await _localDatasource.getCachedMaterials();
        if (staleCache != null && staleCache.isNotEmpty) {
          final ensured = _ensureRohtoMaterials(staleCache);
          final domainItems = await _mergeWithLocalOverrides(ensured);
          _memoryItems = domainItems;
          return Result.success(domainItems);
        }
      } catch (_) {}

      final failure = ExceptionMapper.map(e);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<MaterialItemEntity>> toggleFavorite(String id) async {
    try {
      final favorites = await _localDatasource.getFavorites();
      
      // Determine current favorite state from memory if available, otherwise from saved set
      bool currentFav = favorites.contains(id);
      if (_memoryItems != null) {
        final found = _memoryItems!.where((item) => item.id == id);
        if (found.isNotEmpty) {
          currentFav = found.first.isFavorite;
        }
      }
      final newFav = !currentFav;

      final updatedFavorites = Set<String>.from(favorites);
      if (newFav) {
        updatedFavorites.add(id);
      } else {
        updatedFavorites.remove(id);
      }
      await _localDatasource.saveFavorites(updatedFavorites);

      // Update in-memory items
      if (_memoryItems != null) {
        final index = _memoryItems!.indexWhere((item) => item.id == id);
        if (index != -1) {
          final updated = _memoryItems![index].copyWith(isFavorite: newFav);
          _memoryItems![index] = updated;
          return Result.success(updated);
        }
      }

      // If not in memory, get item by ID
      final itemResult = await getMaterialById(id);
      return itemResult.when(
        success: (item) => Result.success(item.copyWith(isFavorite: newFav)),
        failure: (f) => Result.failure(f),
      );
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<void>> markDownloaded(String id, {String? localFilePath}) async {
    try {
      if (localFilePath == null || !localFileExists(localFilePath)) {
        return const Result.failure(
          CacheFailure(
            debugMessage: 'Cannot mark material as downloaded without a verified file on disk.',
          ),
        );
      }

      final downloaded = await _localDatasource.getDownloadedIds();
      final updatedDownloaded = Set<String>.from(downloaded)..add(id);
      await _localDatasource.saveDownloadedIds(updatedDownloaded);

      final downloadedPaths = await _localDatasource.getDownloadedPaths();
      final updatedPaths = Map<String, String>.from(downloadedPaths)
        ..[id] = localFilePath;
      await _localDatasource.saveDownloadedPaths(updatedPaths);

      if (_memoryItems != null) {
        final index = _memoryItems!.indexWhere((item) => item.id == id);
        if (index != -1) {
          _memoryItems![index] = _memoryItems![index].copyWith(
            downloadState: Downloaded(DateTime.now()),
            localFilePath: localFilePath,
          );
        }
      }
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<void>> removeDownload(String id) async {
    try {
      final downloaded = await _localDatasource.getDownloadedIds();
      final updatedDownloaded = Set<String>.from(downloaded)..remove(id);
      await _localDatasource.saveDownloadedIds(updatedDownloaded);

      final downloadedPaths = await _localDatasource.getDownloadedPaths();
      final existingPath = downloadedPaths[id];
      final updatedPaths = Map<String, String>.from(downloadedPaths)..remove(id);
      await _localDatasource.saveDownloadedPaths(updatedPaths);

      String? memoryPath;
      if (_memoryItems != null) {
        final index = _memoryItems!.indexWhere((item) => item.id == id);
        if (index != -1) {
          memoryPath = _memoryItems![index].localFilePath;
          _memoryItems![index] = _memoryItems![index].copyWith(
            downloadState: const NotDownloaded(),
            clearLocalFilePath: true,
          );
        }
      }

      await deleteLocalFile(existingPath ?? memoryPath);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<MaterialItemEntity>> getMaterialById(String id) async {
    if (_memoryItems != null) {
      final found = _memoryItems!.where((item) => item.id == id);
      if (found.isNotEmpty) {
        return Result.success(found.first);
      }
    }

    final allResult = await getMaterials();
    return allResult.when(
      success: (list) {
        final found = list.where((item) => item.id == id);
        if (found.isNotEmpty) {
          return Result.success(found.first);
        }
        return Result.failure(ExceptionMapper.map(Exception('Material not found: $id')));
      },
      failure: (f) => Result.failure(f),
    );
  }

  Future<List<MaterialItemEntity>> _mergeWithLocalOverrides(
    List<MaterialItemDto> dtoList,
  ) async {
    final favorites = await _localDatasource.getFavorites();
    final downloadedPaths = await _localDatasource.getDownloadedPaths();

    return dtoList.map((dto) {
      final entity = dto.toDomain();
      final hasLocalFav = favorites.contains(entity.id);
      final savedPath = downloadedPaths[entity.id];
      final hasVerifiedLocalFile =
          savedPath != null && localFileExists(savedPath);

      return entity.copyWith(
        isFavorite: hasLocalFav,
        downloadState: hasVerifiedLocalFile
            ? Downloaded(DateTime.now())
            : const NotDownloaded(),
        localFilePath: hasVerifiedLocalFile ? savedPath : null,
        clearLocalFilePath: !hasVerifiedLocalFile,
      );
    }).toList();
  }
}

/// Riverpod Providers for Library Data Layer
final libraryRemoteDatasourceProvider = Provider<LibraryRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return LibraryRemoteDatasourceImpl(dio: dio);
});

final libraryLocalDatasourceProvider = Provider<LibraryLocalDatasource>((ref) {
  final cache = ref.watch(localCacheServiceProvider);
  return LibraryLocalDatasourceImpl(cache);
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final remote = ref.watch(libraryRemoteDatasourceProvider);
  final local = ref.watch(libraryLocalDatasourceProvider);
  return LibraryRepositoryImpl(
    remoteDatasource: remote,
    localDatasource: local,
  );
});
