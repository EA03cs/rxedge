import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/profile_dto.dart';

/// Contract for Remote Profile Datasource
abstract class ProfileRemoteDatasource {
  Future<UserProfileDto> getProfile();
  Future<void> updateNotificationPreferences(NotificationPreferencesDto preferences);
  Future<void> updateLanguagePreference(String languageCode);
}

/// Pharma representative profile datasource backed by `GET /auth/me`
class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final Dio dio;
  final bool simulateError;

  ProfileRemoteDatasourceImpl({
    required this.dio,
    this.simulateError = false,
  });

  @override
  Future<UserProfileDto> getProfile() async {
    if (simulateError) {
      throw const ServerException('Failed to retrieve user profile');
    }

    final response = await dio.get<dynamic>(ApiEndpoints.me);
    final data = ApiResponseParser.unwrapMap(response.data);
    return UserProfileDto.fromJson(data);
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
