import 'dart:convert';
import '../../../../core/config/app_constants.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_dto.dart';

abstract class AuthLocalDatasource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();

  Future<void> saveRefreshToken(String refreshToken);
  Future<String?> getRefreshToken();
  Future<void> clearRefreshToken();

  Future<void> saveUser(UserDto user);
  Future<UserDto?> getUser();
  Future<void> clearUser();

  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted();

  Future<bool> isBiometricEnabled();
  Future<void> setBiometricEnabled(bool enabled);
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  static const String _keyOnboardingCompleted = 'rxedge_onboarding_completed';
  static const String _keyBiometricEnabled = 'rxedge_biometric_enabled';
  static const String _keyUserCache = 'rxedge_cached_user_profile';

  final SecureStorageService _secureStorage;
  final LocalCacheService _cacheService;

  AuthLocalDatasourceImpl({
    required SecureStorageService secureStorage,
    required LocalCacheService cacheService,
  })  : _secureStorage = secureStorage,
        _cacheService = cacheService;

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.write(AppConstants.keyAuthToken, token);
  }

  @override
  Future<String?> getToken() async {
    return _secureStorage.read(AppConstants.keyAuthToken);
  }

  @override
  Future<void> clearToken() async {
    await _secureStorage.delete(AppConstants.keyAuthToken);
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(AppConstants.keyRefreshToken, refreshToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(AppConstants.keyRefreshToken);
  }

  @override
  Future<void> clearRefreshToken() async {
    await _secureStorage.delete(AppConstants.keyRefreshToken);
  }

  @override
  Future<void> saveUser(UserDto user) async {
    final jsonStr = jsonEncode(user.toJson());
    await _secureStorage.write(_keyUserCache, jsonStr);
    _cacheService.put(_keyUserCache, user.toJson());
  }

  @override
  Future<UserDto?> getUser() async {
    final cached = _cacheService.get<Map<String, dynamic>>(_keyUserCache);
    if (cached != null) {
      return UserDto.fromJson(cached);
    }
    final raw = await _secureStorage.read(_keyUserCache);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _cacheService.put(_keyUserCache, decoded);
        return UserDto.fromJson(decoded);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await _secureStorage.delete(_keyUserCache);
    _cacheService.remove(_keyUserCache);
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    final val = await _secureStorage.read(_keyOnboardingCompleted);
    return val == 'true';
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await _secureStorage.write(_keyOnboardingCompleted, 'true');
  }

  @override
  Future<bool> isBiometricEnabled() async {
    final val = await _secureStorage.read(_keyBiometricEnabled);
    return val == 'true';
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(_keyBiometricEnabled, enabled.toString());
  }
}
