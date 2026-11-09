import '../../../../core/config/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../models/material_item_dto.dart';

/// Local Datasource Contract for Resource Library
abstract class LibraryLocalDatasource {
  Future<List<MaterialItemDto>?> getCachedMaterials();
  Future<void> cacheMaterials(List<MaterialItemDto> materials);
  bool isCacheFresh();
  Future<Set<String>> getFavorites();
  Future<void> saveFavorites(Set<String> favorites);
  Future<Set<String>> getDownloadedIds();
  Future<void> saveDownloadedIds(Set<String> downloadedIds);
  Future<void> clearCache();
}

/// Local Datasource Implementation using LocalCacheService
class LibraryLocalDatasourceImpl implements LibraryLocalDatasource {
  static const String _materialsCacheKey = 'rxedge_library_materials';
  static const String _favoritesKey = 'rxedge_library_favorites';
  static const String _downloadedKey = 'rxedge_library_downloaded';

  final LocalCacheService _cacheService;

  LibraryLocalDatasourceImpl(this._cacheService);

  @override
  Future<List<MaterialItemDto>?> getCachedMaterials() async {
    try {
      final rawList = _cacheService.get<List<dynamic>>(_materialsCacheKey);
      if (rawList != null) {
        return rawList
            .map((item) => MaterialItemDto.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      throw const CacheException('Failed to retrieve cached library materials');
    }
  }

  @override
  Future<void> cacheMaterials(List<MaterialItemDto> materials) async {
    try {
      _cacheService.put<List<dynamic>>(
        _materialsCacheKey,
        materials.map((e) => e.toJson()).toList(),
        ttl: AppConstants.defaultCacheTtl,
      );
    } catch (e) {
      throw const CacheException('Failed to cache library materials');
    }
  }

  @override
  bool isCacheFresh() {
    return _cacheService.isFresh(_materialsCacheKey);
  }

  @override
  Future<Set<String>> getFavorites() async {
    try {
      final raw = _cacheService.get<List<dynamic>>(_favoritesKey);
      if (raw != null) {
        return raw.map((e) => e.toString()).toSet();
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> saveFavorites(Set<String> favorites) async {
    try {
      _cacheService.put<List<dynamic>>(
        _favoritesKey,
        favorites.toList(),
        ttl: const Duration(days: 365),
      );
    } catch (e) {
      throw const CacheException('Failed to save favorites to local storage');
    }
  }

  @override
  Future<Set<String>> getDownloadedIds() async {
    try {
      final raw = _cacheService.get<List<dynamic>>(_downloadedKey);
      if (raw != null) {
        return raw.map((e) => e.toString()).toSet();
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> saveDownloadedIds(Set<String> downloadedIds) async {
    try {
      _cacheService.put<List<dynamic>>(
        _downloadedKey,
        downloadedIds.toList(),
        ttl: const Duration(days: 365),
      );
    } catch (e) {
      throw const CacheException('Failed to save downloaded list to local storage');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      _cacheService.remove(_materialsCacheKey);
    } catch (e) {
      throw const CacheException('Failed to clear library cache');
    }
  }
}
