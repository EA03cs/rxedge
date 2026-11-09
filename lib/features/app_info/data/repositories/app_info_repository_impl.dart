import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exception_mapper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_info_entity.dart';
import '../../domain/repositories/app_info_repository.dart';
import '../datasources/app_info_local_datasource.dart';
import '../datasources/app_info_remote_datasource.dart';

/// Repository Implementation for App Info
///
/// Follows Architecture Contracts:
/// 1. "Repository decides remote vs cache (stale-while-revalidate)."
/// 2. "Datasources throw typed exceptions; repositories convert them to a sealed Failure."
/// 3. "Repositories return `Result<T>`, never throw into the UI."
class AppInfoRepositoryImpl implements AppInfoRepository {
  final AppInfoRemoteDatasource _remoteDatasource;
  final AppInfoLocalDatasource _localDatasource;

  AppInfoRepositoryImpl({
    required AppInfoRemoteDatasource remoteDatasource,
    required AppInfoLocalDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  @override
  Future<Result<AppInfoEntity>> getAppInfo({bool forceRefresh = false}) async {
    // 1. Check local cache freshness (unless forced refresh)
    if (!forceRefresh && _localDatasource.isCacheFresh()) {
      try {
        final cached = await _localDatasource.getCachedAppInfo();
        if (cached != null) {
          AppLogger.d('Returning fresh cached AppInfo');
          return Result.success(cached.toDomain());
        }
      } catch (e) {
        AppLogger.w('Failed reading cache, falling back to remote: $e');
      }
    }

    // 2. Fetch fresh data from remote datasource
    try {
      AppLogger.d('Fetching remote AppInfo...');
      final remoteDto = await _remoteDatasource.getAppInfo();

      // Write to cache
      await _localDatasource.cacheAppInfo(remoteDto);

      return Result.success(remoteDto.toDomain());
    } catch (e, st) {
      AppLogger.w('Remote fetch failed, attempting stale cache fallback', error: e);

      // Stale cache fallback
      try {
        final staleCache = await _localDatasource.getCachedAppInfo();
        if (staleCache != null) {
          AppLogger.i('Serving stale cached AppInfo due to remote error');
          return Result.success(staleCache.toDomain());
        }
      } catch (_) {
        // Cache read also failed
      }

      // 3. Map typed exception to sealed domain Failure
      final failure = ExceptionMapper.map(e, st);
      return Result.failure(failure);
    }
  }
}

/// Riverpod Providers for Data Layer (Overridable in tests)
final appInfoRemoteDatasourceProvider = Provider<AppInfoRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AppInfoRemoteDatasourceImpl(dio);
});

final appInfoLocalDatasourceProvider = Provider<AppInfoLocalDatasource>((ref) {
  final cache = ref.watch(localCacheServiceProvider);
  return AppInfoLocalDatasourceImpl(cache);
});

final appInfoRepositoryProvider = Provider<AppInfoRepository>((ref) {
  final remote = ref.watch(appInfoRemoteDatasourceProvider);
  final local = ref.watch(appInfoLocalDatasourceProvider);
  return AppInfoRepositoryImpl(
    remoteDatasource: remote,
    localDatasource: local,
  );
});
