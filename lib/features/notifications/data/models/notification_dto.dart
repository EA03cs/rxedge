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
        json['typeString']?.toString() ?? json['type']?.toString() ?? '';
    final rawTargetScreen =
        json['targetRoute']?.toString() ?? json['targetScreen']?.toString();
    return NotificationDto(
      id: json['id']?.toString() ?? '',
      typeString: _normalizeType(rawType),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      timestampIso: json['timestampIso']?.toString() ??
          json['createdAt']?.toString() ??
          DateTime.now().toIso8601String(),
      isRead: json['isRead'] as bool? ?? false,
      targetRoute: _normalizeRoute(rawTargetScreen, rawType),
      targetId: json['targetId']?.toString(),
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
    final cleaned = rawScreen?.trim() ?? '';
    final normalized = cleaned.toLowerCase().replaceAll(RegExp(r'^/+'), '');

    // 1. Home / Dashboard: do NOT navigate away (informative notification)
    if (normalized == 'home' || normalized == 'dashboard') {
      return null;
    }

    // 2. Specific feature mapping to valid app routes
    switch (normalized) {
      case 'gamification':
      case 'gamification/challenges':
      case 'challenges':
      case 'quizzes':
      case 'quiz':
        return '/challenges';

      case 'media':
      case 'library':
      case 'materials':
      case 'material_detail':
      case 'marketing_hub':
        return '/library';

      case 'feedback':
      case 'rep_voice':
      case 'objection':
      case 'objections':
        return '/feedback';

      case 'feedback/detail':
      case 'feedback_detail':
        return '/feedback/detail';

      case 'learn':
      case 'lesson':
      case 'product':
      case 'products':
      case 'product_navigator':
        return '/learn';

      case 'profile':
        return '/profile';

      case 'search':
        return '/search';
    }

    // 3. Fallback based on notification type if screen was not directly matched
    switch (_normalizeType(rawType)) {
      case 'feedbackReply':
        return '/feedback';
      case 'newMaterial':
        return '/library';
      case 'newChallenge':
      case 'quizReminder':
        return '/challenges';
      default:
        return null;
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
