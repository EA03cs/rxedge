import '../../../../core/config/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../models/app_info_dto.dart';

/// Local Datasource contract for App Info
abstract class AppInfoLocalDatasource {
  Future<AppInfoDto?> getCachedAppInfo();
  Future<void> cacheAppInfo(AppInfoDto dto);
  bool isCacheFresh();
}

/// Local Datasource implementation via LocalCacheService
class AppInfoLocalDatasourceImpl implements AppInfoLocalDatasource {
  static const String _cacheKey = 'cached_app_info';
  final LocalCacheService _cacheService;

  AppInfoLocalDatasourceImpl(this._cacheService);

  @override
  Future<AppInfoDto?> getCachedAppInfo() async {
    try {
      final rawData = _cacheService.get<Map<String, dynamic>>(_cacheKey);
      if (rawData != null) {
        return AppInfoDto.fromJson(rawData);
      }
      return null;
    } catch (e) {
      throw const CacheException('Failed to retrieve cached app info');
    }
  }

  @override
  Future<void> cacheAppInfo(AppInfoDto dto) async {
    try {
      _cacheService.put<Map<String, dynamic>>(
        _cacheKey,
        dto.toJson(),
        ttl: AppConstants.defaultCacheTtl,
      );
    } catch (e) {
      throw const CacheException('Failed to cache app info');
    }
  }

  @override
  bool isCacheFresh() {
    return _cacheService.isFresh(_cacheKey);
  }
}
