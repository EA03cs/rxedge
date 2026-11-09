import '../../../../core/error/exceptions.dart';
import '../models/notification_dto.dart';

abstract class NotificationsRemoteDatasource {
  Future<List<NotificationDto>> getNotifications();
}

class NotificationsRemoteDatasourceImpl implements NotificationsRemoteDatasource {
  final bool simulateError;

  NotificationsRemoteDatasourceImpl({this.simulateError = false});

  @override
  Future<List<NotificationDto>> getNotifications() async {
    if (simulateError) {
      throw const ServerException('Failed to load notifications');
    }
    await Future<void>.delayed(const Duration(milliseconds: 120));

    final now = DateTime.now();

    return [
      // 1. Feedback reply (Unread)
      NotificationDto(
        id: 'notif_01',
        typeString: 'feedbackReply',
        title: 'Marketing Reply Received',
        body: 'Dr. Kareem (Medical Affairs) replied to your Cardura XL dosing objection report.',
        timestampIso: now.subtract(const Duration(hours: 2)).toIso8601String(),
        isRead: false,
        targetRoute: '/feedback',
        targetId: 'fb_ans_01',
      ),

      // 2. New challenge (Unread)
      NotificationDto(
        id: 'notif_02',
        typeString: 'newChallenge',
        title: 'New Monthly Challenge Active',
        body: 'Cardiovascular Blitz: Q4 Master is now live. Complete all 3 quick quizzes before deadline.',
        timestampIso: now.subtract(const Duration(hours: 6)).toIso8601String(),
        isRead: false,
        targetRoute: '/challenges',
        targetId: 'ch_cardio_blitz',
      ),

      // 3. New material (Read)
      NotificationDto(
        id: 'notif_03',
        typeString: 'newMaterial',
        title: 'New Clinical Monograph Added',
        body: 'Cardura XL 2026 GITS Pharmacokinetics Study is now available in your Library.',
        timestampIso: now.subtract(const Duration(days: 1)).toIso8601String(),
        isRead: true,
        targetRoute: '/library',
        targetId: 'mat_cardura_mono',
      ),

      // 4. Quiz reminder (Read)
      NotificationDto(
        id: 'notif_04',
        typeString: 'quizReminder',
        title: 'Quiz Deadline Reminder',
        body: '2 days remaining to complete the Cardura XL ABPM Trial Quick Quiz to maintain your streak.',
        timestampIso: now.subtract(const Duration(days: 2)).toIso8601String(),
        isRead: true,
        targetRoute: '/challenges',
        targetId: 'quiz_1',
      ),
    ];
  }
}
