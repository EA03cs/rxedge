import '../../../../core/error/exceptions.dart';
import '../models/profile_dto.dart';

/// Contract for Remote Profile Datasource
abstract class ProfileRemoteDatasource {
  Future<UserProfileDto> getProfile();
  Future<void> updateNotificationPreferences(NotificationPreferencesDto preferences);
}

/// Realistic pharma representative profile datasource
class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final bool simulateError;

  ProfileRemoteDatasourceImpl({this.simulateError = false});

  @override
  Future<UserProfileDto> getProfile() async {
    if (simulateError) {
      throw const ServerException('Failed to retrieve user profile');
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));

    return UserProfileDto(
      id: 'usr_alex_01',
      displayName: 'Alex Mercer',
      email: 'alex.mercer@rxedgepharma.com',
      employeeId: 'MR-7842',
      territory: 'Cairo North & Heliopolis District',
      role: 'Senior Medical Representative (Cardiology)',
      points: 1250,
      streakDays: 4,
      badges: [
        BadgeDto(
          id: 'badge_1',
          name: 'Spotlight Rep',
          description: 'Top 3 district performer in Q3 launch',
          earnedAtIso: DateTime(2026, 10, 15).toIso8601String(),
        ),
        BadgeDto(
          id: 'badge_2',
          name: 'Cardio Ace',
          description: 'Completed 100% of Cardura XL clinical modules',
          earnedAtIso: DateTime(2026, 10, 28).toIso8601String(),
        ),
        BadgeDto(
          id: 'badge_3',
          name: 'E-Detail Pro',
          description: 'Presented over 30 verified digital detailing sessions',
          earnedAtIso: DateTime(2026, 11, 2).toIso8601String(),
        ),
      ],
      notificationPreferences: const NotificationPreferencesDto(
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
}
