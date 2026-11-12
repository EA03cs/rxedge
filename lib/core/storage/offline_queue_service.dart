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

  const OfflineQueueItem({
    required this.id,
    required this.endpoint,
    required this.httpMethod,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.lastAttemptedAt,
  });

  OfflineQueueItem copyWith({
    int? retryCount,
    DateTime? lastAttemptedAt,
    Map<String, dynamic>? payload,
  }) {
    return OfflineQueueItem(
      id: id,
      endpoint: endpoint,
      httpMethod: httpMethod,
      payload: payload ?? this.payload,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastAttemptedAt: lastAttemptedAt ?? this.lastAttemptedAt,
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
    );
  }
}

/// Persistent Hive-backed queue for offline submissions with idempotent dedupe
/// and in-memory fallback for unit tests.
class OfflineQueueService {
  static const String queueBoxName = StorageInitializer.offlineQueueBoxName;
  final List<OfflineQueueItem> _queue = [];
  bool _hydrated = false;

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

  int get pendingCount => pendingItems.length;

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
  }

  void remove(String id) {
    _ensureHydrated();
    _queue.removeWhere((item) => item.id == id);
    _hiveBox?.delete(id);
  }

  void clear() {
    _ensureHydrated();
    _queue.clear();
    _hiveBox?.clear();
  }

  bool canRetry(OfflineQueueItem item) {
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
