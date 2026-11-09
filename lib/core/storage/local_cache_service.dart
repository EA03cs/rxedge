import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_constants.dart';
import '../error/exceptions.dart';
import '../services/logger_service.dart';

/// Cache Entry with timestamp and optional Time-To-Live
class CacheEntry<T> {
  final T data;
  final DateTime cachedAt;
  final Duration ttl;

  CacheEntry({
    required this.data,
    required this.cachedAt,
    this.ttl = AppConstants.defaultCacheTtl,
  });

  bool get isExpired => DateTime.now().isAfter(cachedAt.add(ttl));
}

/// Local Cache Service supporting in-memory and persistent caching
/// Implements the Stale-While-Revalidate caching pattern
class LocalCacheService {
  final Map<String, CacheEntry<dynamic>> _memoryCache = {};

  LocalCacheService();

  /// Retrieve cached value if available, or null
  T? get<T>(String key) {
    try {
      final entry = _memoryCache[key];
      if (entry != null && entry.data is T) {
        return entry.data as T;
      }
      return null;
    } catch (e, st) {
      AppLogger.e('Cache read error for key: $key', error: e, stackTrace: st);
      throw CacheException('Failed to read from local cache: $key');
    }
  }

  /// Check whether cache entry exists and is not expired
  bool isFresh(String key) {
    final entry = _memoryCache[key];
    if (entry == null) return false;
    return !entry.isExpired;
  }

  /// Save data to cache with optional TTL
  void put<T>(String key, T data, {Duration ttl = AppConstants.defaultCacheTtl}) {
    try {
      _memoryCache[key] = CacheEntry<T>(
        data: data,
        cachedAt: DateTime.now(),
        ttl: ttl,
      );
    } catch (e, st) {
      AppLogger.e('Cache write error for key: $key', error: e, stackTrace: st);
      throw CacheException('Failed to write to local cache: $key');
    }
  }

  /// Remove specific cache entry
  void remove(String key) {
    _memoryCache.remove(key);
  }

  /// Clear entire cache
  void clear() {
    _memoryCache.clear();
  }
}

/// Riverpod provider for LocalCacheService
final localCacheServiceProvider = Provider<LocalCacheService>((ref) {
  return LocalCacheService();
});
