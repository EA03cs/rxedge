import '../../../../core/storage/local_cache_service.dart';
import '../models/profile_dto.dart';

/// Contract for Local Profile Datasource
abstract class ProfileLocalDatasource {
  Future<UserProfileDto?> getCachedProfile();
  Future<void> cacheProfile(UserProfileDto profile);
  Future<NotificationPreferencesDto?> getSavedPreferences();
  Future<void> savePreferences(NotificationPreferencesDto preferences);
  Future<void> clearDownloads();
  int getStorageUsage();
}

class ProfileLocalDatasourceImpl implements ProfileLocalDatasource {
  final LocalCacheService _cacheService;
  static const String _profileKey = 'user_profile_cache';
  static const String _prefKey = 'user_notification_prefs';
  static const String _storageKey = 'offline_storage_usage_bytes';

  ProfileLocalDatasourceImpl({required LocalCacheService cacheService})
      : _cacheService = cacheService;

  @override
  Future<UserProfileDto?> getCachedProfile() async {
    final raw = _cacheService.get<Map<String, dynamic>>(_profileKey);
    if (raw == null) return null;
    return UserProfileDto.fromJson(raw);
  }

  @override
  Future<void> cacheProfile(UserProfileDto profile) async {
    _cacheService.put<Map<String, dynamic>>(_profileKey, profile.toJson());
  }

  @override
  Future<NotificationPreferencesDto?> getSavedPreferences() async {
    final raw = _cacheService.get<Map<String, dynamic>>(_prefKey);
    if (raw == null) return null;
    return NotificationPreferencesDto.fromJson(raw);
  }

  @override
  Future<void> savePreferences(NotificationPreferencesDto preferences) async {
    _cacheService.put<Map<String, dynamic>>(_prefKey, preferences.toJson());
  }

  @override
  Future<void> clearDownloads() async {
    final savedPrefs = _cacheService.get<Map<String, dynamic>>(_prefKey);
    final cachedProfile = _cacheService.get<Map<String, dynamic>>(_profileKey);
    _cacheService.clear();
    _cacheService.put<int>(_storageKey, 0);
    if (savedPrefs != null) {
      _cacheService.put<Map<String, dynamic>>(_prefKey, savedPrefs);
    }
    if (cachedProfile != null) {
      _cacheService.put<Map<String, dynamic>>(_profileKey, cachedProfile);
    }
  }

  @override
  int getStorageUsage() {
    final stored = _cacheService.get<int>(_storageKey);
    if (stored != null) return stored;
    return _cacheService.estimateStoredBytes();
  }
}
