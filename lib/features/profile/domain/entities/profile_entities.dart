library;

/// Pure Dart Domain Entities for User Profile & Settings
///
/// Follows Clean Architecture Dependency Rule:
/// "presentation -> domain <- data. Domain has zero Flutter/Dio/Hive imports."

class NotificationPreferencesEntity {
  final bool newMaterials;
  final bool monthlyChallenges;
  final bool feedbackReplies;
  final bool quizReminders;

  const NotificationPreferencesEntity({
    this.newMaterials = true,
    this.monthlyChallenges = true,
    this.feedbackReplies = true,
    this.quizReminders = true,
  });

  NotificationPreferencesEntity copyWith({
    bool? newMaterials,
    bool? monthlyChallenges,
    bool? feedbackReplies,
    bool? quizReminders,
  }) {
    return NotificationPreferencesEntity(
      newMaterials: newMaterials ?? this.newMaterials,
      monthlyChallenges: monthlyChallenges ?? this.monthlyChallenges,
      feedbackReplies: feedbackReplies ?? this.feedbackReplies,
      quizReminders: quizReminders ?? this.quizReminders,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferencesEntity &&
          runtimeType == other.runtimeType &&
          newMaterials == other.newMaterials &&
          monthlyChallenges == other.monthlyChallenges &&
          feedbackReplies == other.feedbackReplies &&
          quizReminders == other.quizReminders;

  @override
  int get hashCode =>
      newMaterials.hashCode ^
      monthlyChallenges.hashCode ^
      feedbackReplies.hashCode ^
      quizReminders.hashCode;
}

class BadgeEntity {
  final String id;
  final String name;
  final String description;
  final DateTime earnedAt;

  const BadgeEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.earnedAt,
  });
}

class UserProfileEntity {
  final String id;
  final String displayName;
  final String email;
  final String employeeId;
  final String territory;
  final String role;
  final int points;
  final int streakDays;
  final List<BadgeEntity> badges;
  final NotificationPreferencesEntity notificationPreferences;
  final int storageUsageBytes;

  const UserProfileEntity({
    required this.id,
    required this.displayName,
    required this.email,
    required this.employeeId,
    required this.territory,
    required this.role,
    this.points = 1250,
    this.streakDays = 4,
    this.badges = const [],
    this.notificationPreferences = const NotificationPreferencesEntity(),
    this.storageUsageBytes = 25800000, // ~24.6 MB
  });

  String get formattedStorageSize {
    if (storageUsageBytes <= 0) return '0 MB';
    final mb = storageUsageBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  UserProfileEntity copyWith({
    String? id,
    String? displayName,
    String? email,
    String? employeeId,
    String? territory,
    String? role,
    int? points,
    int? streakDays,
    List<BadgeEntity>? badges,
    NotificationPreferencesEntity? notificationPreferences,
    int? storageUsageBytes,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      employeeId: employeeId ?? this.employeeId,
      territory: territory ?? this.territory,
      role: role ?? this.role,
      points: points ?? this.points,
      streakDays: streakDays ?? this.streakDays,
      badges: badges ?? this.badges,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      storageUsageBytes: storageUsageBytes ?? this.storageUsageBytes,
    );
  }
}
