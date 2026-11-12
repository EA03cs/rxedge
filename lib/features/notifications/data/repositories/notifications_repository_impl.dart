import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exception_mapper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/notification_entities.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_local_datasource.dart';
import '../datasources/notifications_remote_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDatasource _remoteDatasource;
  final NotificationsLocalDatasource _localDatasource;
  List<NotificationItemEntity>? _memoryItems;

  NotificationsRepositoryImpl({
    required NotificationsRemoteDatasource remoteDatasource,
    required NotificationsLocalDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  @override
  Future<Result<List<NotificationItemEntity>>> getNotifications({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _memoryItems != null) {
      return Result.success(_memoryItems!);
    }

    try {
      if (!forceRefresh) {
        final cached = await _localDatasource.getCachedNotifications();
        if (cached != null) {
          _memoryItems = cached.map((e) => e.toDomain()).toList();
          return Result.success(_memoryItems!);
        }
      }

      final remoteList = await _remoteDatasource.getNotifications();
      await _localDatasource.cacheNotifications(remoteList);
      _memoryItems = remoteList.map((e) => e.toDomain()).toList();
      return Result.success(_memoryItems!);
    } catch (e, st) {
      final stale = await _localDatasource.getCachedNotifications();
      if (stale != null) {
        _memoryItems = stale.map((e) => e.toDomain()).toList();
        return Result.success(_memoryItems!);
      }
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<void>> markAsRead(String id) async {
    try {
      await _localDatasource.markAsRead(id);
      if (_memoryItems != null) {
        _memoryItems = _memoryItems!.map((item) {
          if (item.id == id) {
            return item.copyWith(isRead: true);
          }
          return item;
        }).toList();
      }
      try {
        await _remoteDatasource.markAsRead(id);
      } catch (_) {
        // Optimistic local state retained on offline/network errors
      }
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    try {
      await _localDatasource.markAllAsRead();
      if (_memoryItems != null) {
        _memoryItems = _memoryItems!.map((item) => item.copyWith(isRead: true)).toList();
      }
      try {
        await _remoteDatasource.markAllAsRead();
      } catch (_) {
        // Optimistic local state retained on offline/network errors
      }
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    final listResult = await getNotifications();
    return listResult.when(
      success: (list) => Result.success(list.where((i) => !i.isRead).length),
      failure: (f) => Result.failure(f),
    );
  }
}

/// Riverpod Providers for Notifications
final notificationsRemoteDatasourceProvider = Provider<NotificationsRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return NotificationsRemoteDatasourceImpl(dio: dio);
});

final notificationsLocalDatasourceProvider = Provider<NotificationsLocalDatasource>((ref) {
  final cache = ref.watch(localCacheServiceProvider);
  return NotificationsLocalDatasourceImpl(cacheService: cache);
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final remote = ref.watch(notificationsRemoteDatasourceProvider);
  final local = ref.watch(notificationsLocalDatasourceProvider);
  return NotificationsRepositoryImpl(
    remoteDatasource: remote,
    localDatasource: local,
  );
});
