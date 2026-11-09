import '../../../../core/utils/result.dart';
import '../entities/notification_entities.dart';

/// Contract for Notifications Repository
abstract class NotificationsRepository {
  Future<Result<List<NotificationItemEntity>>> getNotifications();
  Future<Result<void>> markAsRead(String id);
  Future<Result<void>> markAllAsRead();
  Future<Result<int>> getUnreadCount();
}
