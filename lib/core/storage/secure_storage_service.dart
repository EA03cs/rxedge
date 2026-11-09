import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../error/exceptions.dart';
import '../services/logger_service.dart';

/// Secure Storage wrapper for tokens and sensitive credentials
class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService({
    FlutterSecureStorage storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  }) : _storage = storage;

  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e, st) {
      AppLogger.e('Failed to read key: $key from secure storage', error: e, stackTrace: st);
      throw CacheException('Failed to read secure data: $key');
    }
  }

  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e, st) {
      AppLogger.e('Failed to write key: $key to secure storage', error: e, stackTrace: st);
      throw CacheException('Failed to save secure data: $key');
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e, st) {
      AppLogger.e('Failed to delete key: $key from secure storage', error: e, stackTrace: st);
      throw CacheException('Failed to delete secure data: $key');
    }
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e, st) {
      AppLogger.e('Failed to clear secure storage', error: e, stackTrace: st);
      throw const CacheException('Failed to clear secure storage');
    }
  }
}

/// Riverpod provider for SecureStorageService
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return const SecureStorageService();
});
