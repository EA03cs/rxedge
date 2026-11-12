import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_constants.dart';
import '../network/api_endpoints.dart';
import '../network/api_response.dart';
import '../network/dio_client.dart';
import '../services/connectivity_service.dart';
import '../services/logger_service.dart';
import '../storage/local_cache_service.dart';
import '../storage/offline_queue_service.dart';

/// Synchronizes offline queued mutations (feedback/quizzes/lesson completions)
/// and checks `/sync/manifest` when connectivity is restored.
class SyncService {
  final Dio _dio;
  final OfflineQueueService _queueService;
  final LocalCacheService _cacheService;
  final ConnectivityService _connectivityService;

  bool _isSyncing = false;

  SyncService({
    required Dio dio,
    required OfflineQueueService queueService,
    required LocalCacheService cacheService,
    required ConnectivityService connectivityService,
  })  : _dio = dio,
        _queueService = queueService,
        _cacheService = cacheService,
        _connectivityService = connectivityService;

  bool get isSyncing => _isSyncing;
  int get pendingCount => _queueService.pendingCount;

  /// Flushes all pending queue items eligible for retry.
  /// Returns the number of items successfully synced.
  Future<int> flushQueue({bool force = false}) async {
    if (_isSyncing) return 0;
    final items = _queueService.pendingItems;
    if (items.isEmpty) return 0;

    final hasNetwork = await _connectivityService.checkIsOnline();
    if (!hasNetwork) return 0;

    _isSyncing = true;
    var syncedCount = 0;

    try {
      for (final item in List<OfflineQueueItem>.from(items)) {
        if (!force && !_queueService.canRetry(item)) continue;
        if (item.retryCount >= AppConstants.maxOfflineQueueRetries) {
          _queueService.remove(item.id);
          continue;
        }

        try {
          await _replayItem(item);
          _queueService.remove(item.id);
          syncedCount++;
          AppLogger.i('Synced offline queue item: ${item.id}', tag: 'Sync');
        } on DioException catch (e) {
          final status = e.response?.statusCode;
          // 409 Conflict indicates idempotent server already accepted this submission.
          if (status == 409) {
            _queueService.remove(item.id);
            syncedCount++;
            AppLogger.i('Removed duplicate queue item (409): ${item.id}', tag: 'Sync');
          } else if (status == 400 || status == 404 || status == 422) {
            // Permanent client validation failure; drop after marking so queue doesn't wedge forever.
            AppLogger.w(
              'Dropping non-retryable queue item ${item.id} (HTTP $status)',
              tag: 'Sync',
            );
            _queueService.remove(item.id);
          } else {
            _queueService.markAttempted(item.id);
          }
        } catch (e, st) {
          AppLogger.w(
            'Error replaying queue item ${item.id}',
            tag: 'Sync',
            error: e,
            stackTrace: st,
          );
          _queueService.markAttempted(item.id);
        }
      }
    } finally {
      _isSyncing = false;
    }

    return syncedCount;
  }

  Future<void> _replayItem(OfflineQueueItem item) async {
    final payload = Map<String, dynamic>.from(item.payload)
      ..remove('localAttachmentPath')
      ..remove('localItemId');

    await _dio.request<dynamic>(
      item.endpoint,
      data: payload,
      options: Options(method: item.httpMethod),
    );
  }

  /// Queries `/sync/manifest` to check for updated modules and invalidate stale caches.
  Future<bool> checkSyncManifest() async {
    try {
      final hasNetwork = await _connectivityService.checkIsOnline();
      if (!hasNetwork) return false;

      final lastSync = _cacheService.get<String>(AppConstants.keyLastSyncManifest);
      final response = await _dio.get<dynamic>(
        ApiEndpoints.syncManifest,
        queryParameters: lastSync != null ? {'lastSyncedAt': lastSync} : null,
      );

      final data = ApiResponseParser.unwrapMap(response.data);
      final serverTime = data['serverTimeUTC']?.toString();
      if (serverTime != null && serverTime.isNotEmpty) {
        _cacheService.put<String>(
          AppConstants.keyLastSyncManifest,
          serverTime,
          ttl: const Duration(days: 30),
        );
      }

      if ((data['products'] as List?)?.isNotEmpty == true ||
          (data['lessons'] as List?)?.isNotEmpty == true ||
          (data['competitors'] as List?)?.isNotEmpty == true) {
        _cacheService.remove('learn_products_list');
      }
      if ((data['materials'] as List?)?.isNotEmpty == true) {
        _cacheService.remove('library_materials_list');
      }
      if ((data['challenges'] as List?)?.isNotEmpty == true) {
        _cacheService.remove('challenges_monthly');
        _cacheService.remove('challenges_quizzes');
      }

      return true;
    } catch (e) {
      AppLogger.w('Sync manifest check skipped: $e', tag: 'Sync');
      return false;
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    dio: ref.watch(dioClientProvider),
    queueService: ref.watch(offlineQueueServiceProvider),
    cacheService: ref.watch(localCacheServiceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
});
