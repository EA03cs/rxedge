import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/app_constants.dart';
import 'storage_initializer.dart';

/// Represents a pending write/mutation queued while offline
class OfflineQueueItem {
  final String id;
  final String endpoint;
  final String httpMethod;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final DateTime? lastAttemptedAt;
  final bool isFailed;
  final int? lastErrorStatusCode;
  final String? lastErrorMessage;

  const OfflineQueueItem({
    required this.id,
    required this.endpoint,
    required this.httpMethod,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.lastAttemptedAt,
    this.isFailed = false,
    this.lastErrorStatusCode,
    this.lastErrorMessage,
  });

  OfflineQueueItem copyWith({
    int? retryCount,
    DateTime? lastAttemptedAt,
    Map<String, dynamic>? payload,
    bool? isFailed,
    int? lastErrorStatusCode,
    String? lastErrorMessage,
    bool clearError = false,
  }) {
    return OfflineQueueItem(
      id: id,
      endpoint: endpoint,
      httpMethod: httpMethod,
      payload: payload ?? this.payload,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastAttemptedAt: lastAttemptedAt ?? this.lastAttemptedAt,
      isFailed: clearError ? false : (isFailed ?? this.isFailed),
      lastErrorStatusCode:
          clearError ? null : (lastErrorStatusCode ?? this.lastErrorStatusCode),
      lastErrorMessage:
          clearError ? null : (lastErrorMessage ?? this.lastErrorMessage),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'endpoint': endpoint,
        'httpMethod': httpMethod,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
        if (lastAttemptedAt != null)
          'lastAttemptedAt': lastAttemptedAt!.toIso8601String(),
        if (isFailed) 'isFailed': isFailed,
        if (lastErrorStatusCode != null)
          'lastErrorStatusCode': lastErrorStatusCode,
        if (lastErrorMessage != null) 'lastErrorMessage': lastErrorMessage,
      };

  factory OfflineQueueItem.fromJson(Map<String, dynamic> json) {
    return OfflineQueueItem(
      id: json['id']?.toString() ?? '',
      endpoint: json['endpoint']?.toString() ?? '',
      httpMethod: json['httpMethod']?.toString() ?? 'POST',
      payload: json['payload'] is Map
          ? Map<String, dynamic>.from(json['payload'] as Map)
          : const <String, dynamic>{},
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      lastAttemptedAt: json['lastAttemptedAt'] != null
          ? DateTime.tryParse(json['lastAttemptedAt'].toString())
          : null,
      isFailed: json['isFailed'] == true,
      lastErrorStatusCode: (json['lastErrorStatusCode'] as num?)?.toInt(),
      lastErrorMessage: json['lastErrorMessage']?.toString(),
    );
  }
}

/// Persistent Hive-backed queue for offline submissions with idempotent dedupe
/// and in-memory fallback for unit tests.
class OfflineQueueService {
  static const String queueBoxName = StorageInitializer.offlineQueueBoxName;
  final List<OfflineQueueItem> _queue = [];
  final List<void Function()> _listeners = [];
  bool _hydrated = false;

  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in List<void Function()>.from(_listeners)) {
      listener();
    }
  }

  Box<String>? get _hiveBox =>
      Hive.isBoxOpen(queueBoxName) ? Hive.box<String>(queueBoxName) : null;

  void _ensureHydrated() {
    if (_hydrated) return;
    _hydrated = true;
    final box = _hiveBox;
    if (box == null) return;

    final loaded = <OfflineQueueItem>[];
    for (final raw in box.values) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          loaded.add(
            OfflineQueueItem.fromJson(Map<String, dynamic>.from(decoded)),
          );
        }
      } catch (_) {
        // Ignore corrupted queue entries rather than blocking valid ones.
      }
    }
    loaded.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _queue
      ..clear()
      ..addAll(loaded);
  }

  List<OfflineQueueItem> get pendingItems {
    _ensureHydrated();
    return List.unmodifiable(_queue);
  }

  List<OfflineQueueItem> get failedItems =>
      pendingItems.where((item) => item.isFailed).toList(growable: false);

  int get pendingCount => pendingItems.length;
  int get failedCount => failedItems.length;

  void enqueue(OfflineQueueItem item) {
    _ensureHydrated();
    final subId = item.payload['clientSubmissionId']?.toString();
    final exists = _queue.any((q) =>
        q.id == item.id ||
        (subId != null &&
            subId.isNotEmpty &&
            q.payload['clientSubmissionId']?.toString() == subId));
    if (exists) return;

    _queue.add(item);
    _persistItem(item);
    _notifyListeners();
  }

  void markAttempted(String id) {
    _ensureHydrated();
    final index = _queue.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final updated = _queue[index].copyWith(
      retryCount: _queue[index].retryCount + 1,
      lastAttemptedAt: DateTime.now(),
    );
    _queue[index] = updated;
    _persistItem(updated);
    _notifyListeners();
  }

  void markFailed(
    String id, {
    int? statusCode,
    String? errorMessage,
  }) {
    _ensureHydrated();
    final index = _queue.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final updated = _queue[index].copyWith(
      retryCount: _queue[index].retryCount + 1,
      lastAttemptedAt: DateTime.now(),
      isFailed: true,
      lastErrorStatusCode: statusCode,
      lastErrorMessage: errorMessage,
    );
    _queue[index] = updated;
    _persistItem(updated);
    _notifyListeners();
  }

  void clearFailure(String id) {
    _ensureHydrated();
    final index = _queue.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final updated = _queue[index].copyWith(clearError: true);
    _queue[index] = updated;
    _persistItem(updated);
    _notifyListeners();
  }

  void remove(String id) {
    _ensureHydrated();
    _queue.removeWhere((item) => item.id == id);
    _hiveBox?.delete(id);
    _notifyListeners();
  }

  void clear() {
    _ensureHydrated();
    _queue.clear();
    _hiveBox?.clear();
    _notifyListeners();
  }

  bool canRetry(OfflineQueueItem item) {
    if (item.isFailed) return false;
    if (item.retryCount >= AppConstants.maxOfflineQueueRetries) return false;
    if (item.lastAttemptedAt == null) return true;
    return DateTime.now().difference(item.lastAttemptedAt!) >=
        AppConstants.offlineQueueRetryDelay;
  }

  void _persistItem(OfflineQueueItem item) {
    final box = _hiveBox;
    if (box == null) return;
    box.put(item.id, jsonEncode(item.toJson()));
  }
}

/// Riverpod provider for OfflineQueueService
final offlineQueueServiceProvider = Provider<OfflineQueueService>((ref) {
  return OfflineQueueService();
});

/// Reactive list of all items currently in the offline queue.
final offlineQueueItemsProvider =
    Provider.autoDispose<List<OfflineQueueItem>>((ref) {
  final queue = ref.watch(offlineQueueServiceProvider);
  void listener() => ref.invalidateSelf();
  queue.addListener(listener);
  ref.onDispose(() => queue.removeListener(listener));
  return queue.pendingItems;
});

/// Reactive list of offline queue items that failed with non-retryable client errors.
final failedQueueItemsProvider =
    Provider.autoDispose<List<OfflineQueueItem>>((ref) {
  final items = ref.watch(offlineQueueItemsProvider);
  return items.where((item) => item.isFailed).toList(growable: false);
});
