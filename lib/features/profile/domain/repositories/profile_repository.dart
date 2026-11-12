import '../../../../core/utils/result.dart';
import '../entities/profile_entities.dart';

/// Profile Repository Contract
abstract class ProfileRepository {
  Future<Result<UserProfileEntity>> getProfile({bool forceRefresh = false});
  Future<Result<void>> updateNotificationPreferences(NotificationPreferencesEntity preferences);
  Future<Result<void>> updateLanguagePreference(String languageCode);
  Future<Result<void>> clearCachedDownloads();
  Future<Result<int>> getStorageUsage();
}
