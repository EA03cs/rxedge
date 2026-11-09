import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exception_mapper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/home_dashboard_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';
import '../datasources/home_remote_datasource.dart';

/// Repository Implementation for Home Dashboard
///
/// Follows Architecture Contracts:
/// 1. "Repository decides remote vs cache (stale-while-revalidate)."
/// 2. "Datasources throw typed exceptions; repositories convert them to a sealed Failure."
/// 3. "Repositories return Result, never throw into the UI."
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDatasource _remoteDatasource;
  final HomeLocalDatasource _localDatasource;

  HomeRepositoryImpl({
    required HomeRemoteDatasource remoteDatasource,
    required HomeLocalDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  @override
  Future<Result<HomeDashboardEntity>> getHomeDashboard({bool forceRefresh = false}) async {
    // 1. Check local cache freshness if not forcing refresh
    if (!forceRefresh && _localDatasource.isCacheFresh()) {
      try {
        final cached = await _localDatasource.getCachedHomeDashboard();
        if (cached != null) {
          AppLogger.d('Returning fresh cached HomeDashboard');
          return Result.success(cached.toDomain());
        }
      } catch (e) {
        AppLogger.w('Failed reading cache, falling back to remote: $e');
      }
    }

    // 2. Fetch fresh data from remote datasource
    try {
      AppLogger.d('Fetching remote HomeDashboard...');
      final remoteDto = await _remoteDatasource.getHomeDashboard();

      // Write to cache
      await _localDatasource.cacheHomeDashboard(remoteDto);

      return Result.success(remoteDto.toDomain());
    } catch (e, st) {
      AppLogger.w('Remote dashboard fetch failed, attempting stale cache fallback', error: e);

      // Stale cache fallback
      try {
        final staleCache = await _localDatasource.getCachedHomeDashboard();
        if (staleCache != null) {
          AppLogger.i('Serving stale cached HomeDashboard due to remote error');
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

/// Riverpod Providers for Home Data Layer (Overridable in tests)
final homeRemoteDatasourceProvider = Provider<HomeRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return HomeRemoteDatasourceImpl(dio: dio);
});

final homeLocalDatasourceProvider = Provider<HomeLocalDatasource>((ref) {
  final cache = ref.watch(localCacheServiceProvider);
  return HomeLocalDatasourceImpl(cache);
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final remote = ref.watch(homeRemoteDatasourceProvider);
  final local = ref.watch(homeLocalDatasourceProvider);
  return HomeRepositoryImpl(
    remoteDatasource: remote,
    localDatasource: local,
  );
});
