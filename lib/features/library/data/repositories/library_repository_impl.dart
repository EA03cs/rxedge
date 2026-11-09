import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exception_mapper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/storage/local_cache_service.dart';
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
        if (cached != null) {
          AppLogger.d('Returning fresh cached Library materials');
          final domainItems = await _mergeWithLocalOverrides(cached);
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
      await _localDatasource.cacheMaterials(remoteList);

      final domainItems = await _mergeWithLocalOverrides(remoteList);
      _memoryItems = domainItems;
      return Result.success(domainItems);
    } catch (e, st) {
      AppLogger.w('Remote library fetch failed, attempting stale fallback', error: e);

      // Stale cache fallback
      try {
        final staleCache = await _localDatasource.getCachedMaterials();
        if (staleCache != null) {
          final domainItems = await _mergeWithLocalOverrides(staleCache);
          _memoryItems = domainItems;
          return Result.success(domainItems);
        }
      } catch (_) {}

      final failure = ExceptionMapper.map(e, st);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<MaterialItemEntity>> toggleFavorite(String id) async {
    try {
      final favorites = await _localDatasource.getFavorites();
      final isFav = favorites.contains(id);

      final updatedFavorites = Set<String>.from(favorites);
      if (isFav) {
        updatedFavorites.remove(id);
      } else {
        updatedFavorites.add(id);
      }
      await _localDatasource.saveFavorites(updatedFavorites);

      // Update in-memory items
      if (_memoryItems != null) {
        final index = _memoryItems!.indexWhere((item) => item.id == id);
        if (index != -1) {
          final updated = _memoryItems![index].copyWith(isFavorite: !isFav);
          _memoryItems![index] = updated;
          return Result.success(updated);
        }
      }

      // If not in memory, get item by ID
      final itemResult = await getMaterialById(id);
      return itemResult.when(
        success: (item) => Result.success(item.copyWith(isFavorite: !isFav)),
        failure: (f) => Result.failure(f),
      );
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<void>> markDownloaded(String id) async {
    try {
      final downloaded = await _localDatasource.getDownloadedIds();
      final updatedDownloaded = Set<String>.from(downloaded)..add(id);
      await _localDatasource.saveDownloadedIds(updatedDownloaded);

      if (_memoryItems != null) {
        final index = _memoryItems!.indexWhere((item) => item.id == id);
        if (index != -1) {
          _memoryItems![index] = _memoryItems![index].copyWith(
            downloadState: Downloaded(DateTime.now()),
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

      if (_memoryItems != null) {
        final index = _memoryItems!.indexWhere((item) => item.id == id);
        if (index != -1) {
          _memoryItems![index] = _memoryItems![index].copyWith(
            downloadState: const NotDownloaded(),
          );
        }
      }
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
    final downloaded = await _localDatasource.getDownloadedIds();

    return dtoList.map((dto) {
      final entity = dto.toDomain();
      // Apply local overrides if present
      final hasLocalFav = favorites.isNotEmpty ? favorites.contains(entity.id) : entity.isFavorite;
      final hasLocalDl = downloaded.isNotEmpty ? downloaded.contains(entity.id) : entity.isDownloaded;

      return entity.copyWith(
        isFavorite: hasLocalFav,
        downloadState: hasLocalDl ? Downloaded(DateTime.now()) : const NotDownloaded(),
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
