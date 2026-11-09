import '../../../../core/config/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../models/learning_dto.dart';

/// Local Datasource Contract for Smart Learning Hub
abstract class LearnLocalDatasource {
  Future<List<ProductLearningDto>?> getCachedProducts();
  Future<void> cacheProducts(List<ProductLearningDto> products);
  bool isCacheFresh();
  Future<Set<String>> getCompletedLessonIds();
  Future<void> saveCompletedLessonIds(Set<String> ids);
  Future<Set<String>> getBookmarkedLessonIds();
  Future<void> saveBookmarkedLessonIds(Set<String> ids);
  Future<void> clearCache();
}

/// Local Datasource Implementation using LocalCacheService
class LearnLocalDatasourceImpl implements LearnLocalDatasource {
  static const String _productsCacheKey = 'rxedge_learn_products';
  static const String _completedKey = 'rxedge_learn_completed_lessons';
  static const String _bookmarksKey = 'rxedge_learn_bookmarked_lessons';

  final LocalCacheService _cacheService;

  LearnLocalDatasourceImpl(this._cacheService);

  @override
  Future<List<ProductLearningDto>?> getCachedProducts() async {
    try {
      final rawList = _cacheService.get<List<dynamic>>(_productsCacheKey);
      if (rawList != null) {
        return rawList
            .map((e) => ProductLearningDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      throw const CacheException('Failed to retrieve cached learning products');
    }
  }

  @override
  Future<void> cacheProducts(List<ProductLearningDto> products) async {
    try {
      _cacheService.put<List<dynamic>>(
        _productsCacheKey,
        products.map((e) => e.toJson()).toList(),
        ttl: AppConstants.defaultCacheTtl,
      );
    } catch (e) {
      throw const CacheException('Failed to cache learning products');
    }
  }

  @override
  bool isCacheFresh() {
    return _cacheService.isFresh(_productsCacheKey);
  }

  @override
  Future<Set<String>> getCompletedLessonIds() async {
    try {
      final raw = _cacheService.get<List<dynamic>>(_completedKey);
      if (raw != null) {
        return raw.map((e) => e.toString()).toSet();
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> saveCompletedLessonIds(Set<String> ids) async {
    try {
      _cacheService.put<List<dynamic>>(
        _completedKey,
        ids.toList(),
        ttl: const Duration(days: 365),
      );
    } catch (e) {
      throw const CacheException('Failed to persist completed lessons');
    }
  }

  @override
  Future<Set<String>> getBookmarkedLessonIds() async {
    try {
      final raw = _cacheService.get<List<dynamic>>(_bookmarksKey);
      if (raw != null) {
        return raw.map((e) => e.toString()).toSet();
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> saveBookmarkedLessonIds(Set<String> ids) async {
    try {
      _cacheService.put<List<dynamic>>(
        _bookmarksKey,
        ids.toList(),
        ttl: const Duration(days: 365),
      );
    } catch (e) {
      throw const CacheException('Failed to persist bookmarked lessons');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      _cacheService.remove(_productsCacheKey);
    } catch (e) {
      throw const CacheException('Failed to clear learning cache');
    }
  }
}
