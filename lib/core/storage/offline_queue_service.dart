import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_constants.dart';
import '../services/logger_service.dart';

enum OfflineSyncStatus {
  pending,
  syncing,
  failed,
  synced,
}

class OfflineQueueItem {
  final String id;
  final String endpoint;
  final String httpMethod; // POST, PUT, DELETE
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final OfflineSyncStatus status;
  final String? lastError;

  const OfflineQueueItem({
    required this.id,
    required this.endpoint,
    required this.httpMethod,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.status = OfflineSyncStatus.pending,
    this.lastError,
  });

  OfflineQueueItem copyWith({
    int? retryCount,
    OfflineSyncStatus? status,
    String? lastError,
  }) {
    return OfflineQueueItem(
      id: id,
      endpoint: endpoint,
      httpMethod: httpMethod,
      payload: payload,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
    );
  }
}

/// Offline Write Queue Service
/// Queues outgoing mutations (doctor visit feedback, quiz results) while offline
class OfflineQueueService {
  final List<OfflineQueueItem> _queue = [];

  List<OfflineQueueItem> get pendingItems =>
      _queue.where((item) => item.status == OfflineSyncStatus.pending || item.status == OfflineSyncStatus.failed).toList();

  int get pendingCount => pendingItems.length;

  void enqueue(OfflineQueueItem item) {
    AppLogger.i('Enqueuing offline item: ${item.id} -> ${item.endpoint}');
    _queue.add(item);
  }

  void updateStatus(String id, OfflineSyncStatus status, {String? error}) {
    final index = _queue.indexWhere((item) => item.id == id);
    if (index != -1) {
      final current = _queue[index];
      _queue[index] = current.copyWith(
        status: status,
        retryCount: status == OfflineSyncStatus.failed ? current.retryCount + 1 : current.retryCount,
        lastError: error,
      );
    }
  }

  void remove(String id) {
    _queue.removeWhere((item) => item.id == id);
  }

  bool canRetry(OfflineQueueItem item) {
    return item.retryCount < AppConstants.maxOfflineRetries;
  }
}

/// Riverpod provider for OfflineQueueService
final offlineQueueServiceProvider = Provider<OfflineQueueService>((ref) {
  return OfflineQueueService();
});
