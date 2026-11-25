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
  final Dio? dio;
  final bool simulateError;

  ProfileRemoteDatasourceImpl({
    this.dio,
    this.simulateError = false,
  });

  @override
  Future<List<BadgeDto>> getMyBadges() async {
    if (simulateError) {
      throw const ServerException('Failed to retrieve earned badges');
    }

    if (dio != null) {
      final response = await dio!.get<dynamic>(ApiEndpoints.myBadges);
      final list = ApiResponseParser.unwrapList(
        response.data,
        nestedKeys: const ['badges', 'items', 'results', 'records'],
      );
      return list
          .map(BadgeDto.fromJson)
          .where((badge) => badge.name.trim().isNotEmpty)
          .toList();
    }

    return const [];
  }

  @override
  Future<UserProfileDto> getProfile() async {
    if (simulateError) {
      throw const ServerException('Failed to retrieve user profile');
    }

    if (dio != null) {
      final response = await dio!.get<dynamic>(ApiEndpoints.me);
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

    await Future<void>.delayed(const Duration(milliseconds: 100));

    return const UserProfileDto(
      id: 'usr_ahmed_01',
      displayName: 'Ahmed Mostafa',
      email: 'ahmed.mostafa@rxedgepharma.com',
      employeeId: 'MR-7842',
      territory: 'Cairo North & Heliopolis District',
      role: 'Senior Medical Representative (Ophthalmology)',
      points: 1250,
      streakDays: 4,
      badges: [],
      notificationPreferences: NotificationPreferencesDto(
        newMaterials: true,
        monthlyChallenges: true,
        feedbackReplies: true,
        quizReminders: true,
      ),
      storageUsageBytes: 25800000,
    );
  }

  @override
  Future<void> updateNotificationPreferences(NotificationPreferencesDto preferences) async {
    if (simulateError) {
      throw const ServerException('Failed to update preferences on server');
    }
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }

  @override
  Future<void> updateLanguagePreference(String languageCode) async {
    if (simulateError) {
      throw const ServerException('Failed to update language preference');
    }
    if (dio != null) {
      await dio!.patch<dynamic>(
        ApiEndpoints.mePreferences,
        data: {'language': languageCode},
      );
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}
