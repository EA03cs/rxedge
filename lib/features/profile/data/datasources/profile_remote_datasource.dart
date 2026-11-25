import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/profile_dto.dart';

/// Contract for Remote Profile Datasource
abstract class ProfileRemoteDatasource {
  Future<UserProfileDto> getProfile();
  Future<List<BadgeDto>> getMyBadges();
  Future<void> updateNotificationPreferences(NotificationPreferencesDto preferences);
  Future<void> updateLanguagePreference(String languageCode);
}

/// Pharma representative profile datasource backed by `GET /auth/me`
/// and `GET /gamification/badges/my-badges`.
class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final Dio dio;
  final bool simulateError;

  ProfileRemoteDatasourceImpl({
    required this.dio,
    this.simulateError = false,
  });

  @override
  Future<List<BadgeDto>> getMyBadges() async {
    if (simulateError) {
      throw const ServerException('Failed to retrieve earned badges');
    }

    final response = await dio.get<dynamic>(ApiEndpoints.myBadges);
    final list = ApiResponseParser.unwrapList(
      response.data,
      nestedKeys: const ['badges', 'items', 'results', 'records'],
    );
    return list
        .map(BadgeDto.fromJson)
        .where((badge) => badge.name.trim().isNotEmpty)
        .toList();
  }

  @override
  Future<UserProfileDto> getProfile() async {
    if (simulateError) {
      throw const ServerException('Failed to retrieve user profile');
    }

    final response = await dio.get<dynamic>(ApiEndpoints.me);
    final data = ApiResponseParser.unwrapMap(response.data);
    final profile = UserProfileDto.fromJson(data);
    List<BadgeDto> earnedBadges = profile.badges;
    try {
      earnedBadges = await getMyBadges();
    } catch (_) {
      // Keep badges from /auth/me if /gamification/badges/my-badges fails transiently.
    }
    return UserProfileDto(
      id: profile.id,
      displayName: profile.displayName,
      email: profile.email,
      employeeId: profile.employeeId,
      territory: profile.territory,
      role: profile.role,
      points: profile.points,
      streakDays: profile.streakDays,
      badges: earnedBadges,
      notificationPreferences: profile.notificationPreferences,
      storageUsageBytes: profile.storageUsageBytes,
    );
  }

  @override
  Future<void> updateNotificationPreferences(NotificationPreferencesDto preferences) async {
    if (simulateError) {
      throw const ServerException('Failed to update preferences on server');
    }
    await dio.patch<dynamic>(
      ApiEndpoints.mePreferences,
      data: <String, dynamic>{
        'notificationPreferences': preferences.toJson(),
      },
    );
  }

  @override
  Future<void> updateLanguagePreference(String languageCode) async {
    if (simulateError) {
      throw const ServerException('Failed to update language preference');
    }
    await dio.patch<dynamic>(
      ApiEndpoints.mePreferences,
      data: {'language': languageCode},
    );
  }
}
