import '../../../../core/config/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../models/home_dashboard_dto.dart';

/// Local Datasource Contract for Home Dashboard caching
abstract class HomeLocalDatasource {
  Future<HomeDashboardDto?> getCachedHomeDashboard();
  Future<void> cacheHomeDashboard(HomeDashboardDto dto);
  bool isCacheFresh();
  Future<void> clearCache();
}

/// Local Datasource implementation using in-memory / local storage cache
class HomeLocalDatasourceImpl implements HomeLocalDatasource {
  static const String _cacheKey = 'rxedge_home_dashboard';
  final LocalCacheService _cacheService;

  HomeLocalDatasourceImpl(this._cacheService);

  @override
  Future<HomeDashboardDto?> getCachedHomeDashboard() async {
    try {
      final rawData = _cacheService.get<Map<String, dynamic>>(_cacheKey);
      if (rawData != null) {
        return HomeDashboardDto.fromJson(rawData);
      }
      return null;
    } catch (e) {
      throw const CacheException('Failed to retrieve cached home dashboard data');
    }
  }

  @override
  Future<void> cacheHomeDashboard(HomeDashboardDto dto) async {
    try {
      _cacheService.put<Map<String, dynamic>>(
        _cacheKey,
        dto.toJson(),
        ttl: AppConstants.defaultCacheTtl,
      );
    } catch (e) {
      throw const CacheException('Failed to save home dashboard data to cache');
    }
  }

  @override
  bool isCacheFresh() {
    return _cacheService.isFresh(_cacheKey);
  }

  @override
  Future<void> clearCache() async {
    try {
      _cacheService.remove(_cacheKey);
    } catch (e) {
      throw const CacheException('Failed to clear home dashboard cache');
    }
  }
}
