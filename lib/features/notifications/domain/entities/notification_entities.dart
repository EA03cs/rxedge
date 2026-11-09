library;

/// Pure Dart Domain Entities for Notifications Center
///
/// Follows Clean Architecture Dependency Rule:
/// "presentation -> domain <- data. Domain has zero Flutter/Dio/Hive imports."

enum NotificationType {
  newMaterial,
  newChallenge,
  feedbackReply,
  quizReminder,
}

class NotificationItemEntity {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? targetRoute;
  final String? targetId;

  const NotificationItemEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.targetRoute,
    this.targetId,
  });

  NotificationItemEntity copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    String? targetRoute,
    String? targetId,
  }) {
    return NotificationItemEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      targetRoute: targetRoute ?? this.targetRoute,
      targetId: targetId ?? this.targetId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationItemEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isRead == other.isRead;

  @override
  int get hashCode => id.hashCode ^ isRead.hashCode;
}
