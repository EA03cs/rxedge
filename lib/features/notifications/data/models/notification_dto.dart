import '../../domain/entities/notification_entities.dart';

class NotificationDto {
  final String id;
  final String typeString;
  final String title;
  final String body;
  final String timestampIso;
  final bool isRead;
  final String? targetRoute;
  final String? targetId;

  const NotificationDto({
    required this.id,
    required this.typeString,
    required this.title,
    required this.body,
    required this.timestampIso,
    this.isRead = false,
    this.targetRoute,
    this.targetId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'typeString': typeString,
        'title': title,
        'body': body,
        'timestampIso': timestampIso,
        'isRead': isRead,
        'targetRoute': targetRoute,
        'targetId': targetId,
      };

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as String,
      typeString: json['typeString'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timestampIso: json['timestampIso'] as String,
      isRead: json['isRead'] as bool? ?? false,
      targetRoute: json['targetRoute'] as String?,
      targetId: json['targetId'] as String?,
    );
  }

  NotificationItemEntity toDomain() {
    NotificationType type;
    switch (typeString) {
      case 'newMaterial':
        type = NotificationType.newMaterial;
        break;
      case 'newChallenge':
        type = NotificationType.newChallenge;
        break;
      case 'feedbackReply':
        type = NotificationType.feedbackReply;
        break;
      case 'quizReminder':
      default:
        type = NotificationType.quizReminder;
        break;
    }

    return NotificationItemEntity(
      id: id,
      type: type,
      title: title,
      body: body,
      timestamp: DateTime.tryParse(timestampIso) ?? DateTime.now(),
      isRead: isRead,
      targetRoute: targetRoute,
      targetId: targetId,
    );
  }

  factory NotificationDto.fromDomain(NotificationItemEntity entity) {
    return NotificationDto(
      id: entity.id,
      typeString: entity.type.name,
      title: entity.title,
      body: entity.body,
      timestampIso: entity.timestamp.toIso8601String(),
      isRead: entity.isRead,
      targetRoute: entity.targetRoute,
      targetId: entity.targetId,
    );
  }
}
