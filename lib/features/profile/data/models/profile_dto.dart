import '../../domain/entities/profile_entities.dart';

/// DTO for Profile serialization
class NotificationPreferencesDto {
  final bool newMaterials;
  final bool monthlyChallenges;
  final bool feedbackReplies;
  final bool quizReminders;

  const NotificationPreferencesDto({
    required this.newMaterials,
    required this.monthlyChallenges,
    required this.feedbackReplies,
    required this.quizReminders,
  });

  Map<String, dynamic> toJson() => {
        'newMaterials': newMaterials,
        'monthlyChallenges': monthlyChallenges,
        'feedbackReplies': feedbackReplies,
        'quizReminders': quizReminders,
      };

  factory NotificationPreferencesDto.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesDto(
      newMaterials: json['newMaterials'] as bool? ?? true,
      monthlyChallenges: json['monthlyChallenges'] as bool? ?? true,
      feedbackReplies: json['feedbackReplies'] as bool? ?? true,
      quizReminders: json['quizReminders'] as bool? ?? true,
    );
  }

  NotificationPreferencesEntity toDomain() {
    return NotificationPreferencesEntity(
      newMaterials: newMaterials,
      monthlyChallenges: monthlyChallenges,
      feedbackReplies: feedbackReplies,
      quizReminders: quizReminders,
    );
  }

  factory NotificationPreferencesDto.fromDomain(NotificationPreferencesEntity entity) {
    return NotificationPreferencesDto(
      newMaterials: entity.newMaterials,
      monthlyChallenges: entity.monthlyChallenges,
      feedbackReplies: entity.feedbackReplies,
      quizReminders: entity.quizReminders,
    );
  }
}

class BadgeDto {
  final String id;
  final String name;
  final String description;
  final String earnedAtIso;

  const BadgeDto({
    required this.id,
    required this.name,
    required this.description,
    required this.earnedAtIso,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'earnedAtIso': earnedAtIso,
      };

  factory BadgeDto.fromJson(Map<String, dynamic> json) {
    final badgeObj = json['badge'] is Map ? json['badge'] as Map : json;
    final resolvedTitle = (badgeObj['title'] ??
            badgeObj['name'] ??
            json['name'] ??
            json['title'])
        ?.toString() ??
        '';
    final resolvedDesc =
        (badgeObj['description'] ?? json['description'])?.toString() ?? '';
    final resolvedDate = (json['awardedAt'] ??
            json['earnedAtIso'] ??
            json['createdAt'] ??
            badgeObj['createdAt'])
        ?.toString() ??
        DateTime.now().toIso8601String();

    return BadgeDto(
      id: (badgeObj['id'] ?? json['id'])?.toString() ?? '',
      name: resolvedTitle,
      description: resolvedDesc,
      earnedAtIso: resolvedDate,
    );
  }

  BadgeEntity toDomain() {
    return BadgeEntity(
      id: id,
      name: name,
      description: description,
      earnedAt: DateTime.tryParse(earnedAtIso) ?? DateTime.now(),
    );
  }
}

class UserProfileDto {
  final String id;
  final String displayName;
  final String email;
  final String employeeId;
  final String territory;
  final String role;
  final int points;
  final int streakDays;
  final List<BadgeDto> badges;
  final NotificationPreferencesDto notificationPreferences;
  final int storageUsageBytes;

  const UserProfileDto({
    required this.id,
    required this.displayName,
    required this.email,
    required this.employeeId,
    required this.territory,
    required this.role,
    required this.points,
    required this.streakDays,
    required this.badges,
    required this.notificationPreferences,
    required this.storageUsageBytes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'employeeId': employeeId,
        'territory': territory,
        'role': role,
        'points': points,
        'streakDays': streakDays,
        'badges': badges.map((b) => b.toJson()).toList(),
        'notificationPreferences': notificationPreferences.toJson(),
        'storageUsageBytes': storageUsageBytes,
      };

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    final userObj = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : json;
    final territoryRaw = userObj['territory'];
    final territoryStr = territoryRaw is Map
        ? (territoryRaw['name']?.toString() ?? '')
        : (territoryRaw?.toString() ?? '');

    return UserProfileDto(
      id: userObj['id']?.toString() ?? '',
      displayName: userObj['displayName']?.toString() ??
          userObj['name']?.toString() ??
          '',
      email: userObj['email']?.toString() ?? '',
      employeeId: userObj['employeeId']?.toString() ??
          userObj['employeeCode']?.toString() ??
          '',
      territory: territoryStr,
      role: userObj['role']?.toString() ?? 'MEDICAL_REP',
      points: ((userObj['totalChallengeMarks'] ??
                  userObj['challengeMarks'] ??
                  userObj['points'] ??
                  userObj['totalPoints']) as num?)
              ?.toInt() ??
          0,
      streakDays:
          ((userObj['streakDays'] ?? userObj['currentStreak']) as num?)?.toInt() ??
              0,
      badges: (userObj['badges'] as List<dynamic>? ?? [])
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => BadgeDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      notificationPreferences: NotificationPreferencesDto.fromJson(
        userObj['notificationPreferences'] is Map
            ? Map<String, dynamic>.from(userObj['notificationPreferences'] as Map)
            : {},
      ),
      storageUsageBytes:
          ((userObj['storageUsageBytes'] ?? userObj['storageUsage']) as num?)?.toInt() ?? 0,
    );
  }

  UserProfileEntity toDomain() {
    return UserProfileEntity(
      id: id,
      displayName: displayName,
      email: email,
      employeeId: employeeId,
      territory: territory,
      role: role,
      points: points,
      streakDays: streakDays,
      badges: badges.map((b) => b.toDomain()).toList(),
      notificationPreferences: notificationPreferences.toDomain(),
      storageUsageBytes: storageUsageBytes,
    );
  }
}
