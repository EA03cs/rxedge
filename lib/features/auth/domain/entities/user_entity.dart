/// Authenticated Medical Representative User Entity
class UserEntity {
  final String id;
  final String email;
  final String employeeId;
  final String displayName;
  final String role;
  final String territory;
  final String token;
  final String? avatarUrl;
  final int totalPoints;
  final int currentStreak;

  const UserEntity({
    required this.id,
    required this.email,
    required this.employeeId,
    required this.displayName,
    required this.role,
    required this.territory,
    required this.token,
    this.avatarUrl,
    this.totalPoints = 0,
    this.currentStreak = 0,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? employeeId,
    String? displayName,
    String? role,
    String? territory,
    String? token,
    String? avatarUrl,
    int? totalPoints,
    int? currentStreak,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      employeeId: employeeId ?? this.employeeId,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      territory: territory ?? this.territory,
      token: token ?? this.token,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }
}
