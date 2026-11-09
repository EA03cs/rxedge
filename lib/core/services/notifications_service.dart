import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'logger_service.dart';

/// Notification payload for deep linking
class NotificationPayload {
  final String id;
  final String title;
  final String body;
  final String? targetRoute;
  final Map<String, dynamic> extra;

  const NotificationPayload({
    required this.id,
    required this.title,
    required this.body,
    this.targetRoute,
    this.extra = const {},
  });
}

/// Service handling push notifications and deep-link routing
class NotificationsService {
  void handleNotificationTap(NotificationPayload payload, {void Function(String route)? navigateTo}) {
    AppLogger.i('Notification tapped: ${payload.title} -> target: ${payload.targetRoute}');
    if (payload.targetRoute != null && navigateTo != null) {
      navigateTo(payload.targetRoute!);
    }
  }
}

final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService();
});
