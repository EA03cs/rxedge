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
    final rawType =
        (json['typeString'] as String?) ?? (json['type'] as String?) ?? '';
    final rawTargetScreen =
        (json['targetRoute'] as String?) ?? (json['targetScreen'] as String?);
    return NotificationDto(
      id: json['id'] as String? ?? '',
      typeString: _normalizeType(rawType),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      timestampIso: (json['timestampIso'] as String?) ??
          (json['createdAt'] as String?) ??
          DateTime.now().toIso8601String(),
      isRead: json['isRead'] as bool? ?? false,
      targetRoute: _normalizeRoute(rawTargetScreen, rawType),
      targetId: json['targetId'] as String?,
    );
  }

  static String _normalizeType(String raw) {
    switch (raw.toLowerCase()) {
      case 'newmaterial':
      case 'new_material':
        return 'newMaterial';
      case 'newchallenge':
      case 'new_challenge':
        return 'newChallenge';
      case 'feedbackreply':
      case 'feedback_reply':
        return 'feedbackReply';
      case 'quizreminder':
      case 'quiz_reminder':
      default:
        return 'quizReminder';
    }
  }

  static String? _normalizeRoute(String? rawScreen, String rawType) {
    if (rawScreen == null || rawScreen.trim().isEmpty) {
      switch (_normalizeType(rawType)) {
        case 'feedbackReply':
          return '/feedback';
        case 'newMaterial':
          return '/library';
        case 'newChallenge':
        case 'quizReminder':
          return '/challenges';
      }
      return null;
    }
    final cleaned = rawScreen.trim();
    if (cleaned.startsWith('/')) {
      if (cleaned == '/feedback/detail' || cleaned == '/feedback_detail') {
        return '/feedback/detail';
      }
      return cleaned;
    }
    switch (cleaned.toLowerCase()) {
      case 'feedback':
        return '/feedback';
      case 'feedback_detail':
      case 'feedback/detail':
        return '/feedback/detail';
      case 'library':
      case 'materials':
      case 'material_detail':
        return '/library';
      case 'challenges':
      case 'quizzes':
      case 'quiz':
        return '/challenges';
      case 'learn':
      case 'lesson':
        return '/learn';
      case 'home':
        return '/home';
      case 'profile':
        return '/profile';
      default:
        return '/$cleaned';
    }
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
