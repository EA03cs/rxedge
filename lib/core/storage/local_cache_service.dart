import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/app_constants.dart';
import 'storage_initializer.dart';

/// Cache entry wrapper with TTL expiration checking
class CacheEntry<T> {
  final T data;
  final DateTime cachedAt;
  final Duration ttl;

  const CacheEntry({
    required this.data,
    required this.cachedAt,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(cachedAt) > ttl;
}

/// Persistent + in-memory key-value cache service.
/// Uses Hive (`rxedge_cache`) when initialized in the app runtime,
/// and seamlessly falls back to memory in unit tests.
class LocalCacheService {
  static const String cacheBoxName = StorageInitializer.cacheBoxName;
  final Map<String, CacheEntry<dynamic>> _memoryCache = {};

  Box<String>? get _hiveBox =>
      Hive.isBoxOpen(cacheBoxName) ? Hive.box<String>(cacheBoxName) : null;

  void put<T>(
    String key,
    T data, {
    Duration ttl = AppConstants.defaultCacheTtl,
  }) {
    final now = DateTime.now();
    _memoryCache[key] = CacheEntry<T>(
      data: data,
      cachedAt: now,
      ttl: ttl,
    );

    final box = _hiveBox;
    if (box != null) {
      try {
        final encoded = jsonEncode(<String, dynamic>{
          'value': data,
          'cachedAt': now.toIso8601String(),
          'ttlSeconds': ttl.inSeconds,
        });
        box.put(key, encoded);
      } catch (_) {
        // Non-JSON-encodable objects remain in memory cache safely.
      }
    }
  }

  T? get<T>(String key) {
    final memEntry = _memoryCache[key];
    if (memEntry != null) {
      if (memEntry.isExpired) {
        _memoryCache.remove(key);
        _hiveBox?.delete(key);
        return null;
      }
      return _castValue<T>(memEntry.data);
    }

    final box = _hiveBox;
    if (box == null) return null;
    final raw = box.get(key);
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        box.delete(key);
        return null;
      }
      final cachedAt =
          DateTime.tryParse(decoded['cachedAt']?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
      final ttlSeconds = (decoded['ttlSeconds'] as num?)?.toInt() ??
          AppConstants.defaultCacheTtl.inSeconds;
      final ttl = Duration(seconds: ttlSeconds);
      final value = decoded['value'];

      if (DateTime.now().difference(cachedAt) > ttl) {
        box.delete(key);
        return null;
      }

      final typed = _castValue<T>(value);
      _memoryCache[key] = CacheEntry<dynamic>(
        data: typed ?? value,
        cachedAt: cachedAt,
        ttl: ttl,
      );
      return typed;
    } catch (_) {
      box.delete(key);
      return null;
    }
  }

  T? _castValue<T>(dynamic value) {
    if (value == null) return null;
    if (value is T) return value;
    if (value is List && <String>[] is T) {
      return value.map((e) => e.toString()).toList() as T;
    }
    if (value is Map && <String, dynamic>{} is T) {
      return Map<String, dynamic>.from(value) as T;
    }
    return null;
  }

  bool isFresh(String key) {
    final memEntry = _memoryCache[key];
    if (memEntry != null) {
      return !memEntry.isExpired;
    }

    final box = _hiveBox;
    if (box == null) return false;
    final raw = box.get(key);
    if (raw == null) return false;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return false;
      final cachedAt = DateTime.tryParse(decoded['cachedAt']?.toString() ?? '');
      if (cachedAt == null) return false;
      final ttlSeconds = (decoded['ttlSeconds'] as num?)?.toInt() ??
          AppConstants.defaultCacheTtl.inSeconds;
      return DateTime.now().difference(cachedAt) <= Duration(seconds: ttlSeconds);
    } catch (_) {
      return false;
    }
  }

  void remove(String key) {
    _memoryCache.remove(key);
    _hiveBox?.delete(key);
  }

  void clear() {
    _memoryCache.clear();
    _hiveBox?.clear();
  }

  /// Estimates total stored bytes across persistent Hive cache entries.
  int estimateStoredBytes() {
    final box = _hiveBox;
    if (box != null) {
      var total = 0;
      for (final val in box.values) {
        total += val.length * 2;
      }
      return total;
    }
    var memBytes = 0;
    for (final entry in _memoryCache.values) {
      memBytes += entry.data.toString().length * 2;
    }
    return memBytes;
  }
}

/// Riverpod provider for LocalCacheService
final localCacheServiceProvider = Provider<LocalCacheService>((ref) {
  return LocalCacheService();
});
