import '../../domain/entities/user_entity.dart';

/// Data Transfer Object for Authenticated User
/// Handles both `D:\Backend\rxedge` camelCase payloads and cached JSON maps.
class UserDto {
  final String id;
  final String email;
  final String employeeId;
  final String displayName;
  final String role;
  final String territory;
  final String token;
  final String? refreshToken;
  final String? avatarUrl;
  final int totalPoints;
  final int currentStreak;

  const UserDto({
    required this.id,
    required this.email,
    required this.employeeId,
    required this.displayName,
    required this.role,
    required this.territory,
    required this.token,
    this.refreshToken,
    this.avatarUrl,
    this.totalPoints = 0,
    this.currentStreak = 0,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    final rawTerritory = json['territory'];
    String resolvedTerritory = '';
    if (rawTerritory is Map) {
      resolvedTerritory = rawTerritory['name']?.toString() ??
          rawTerritory['region']?.toString() ??
          '';
    } else if (rawTerritory != null) {
      resolvedTerritory = rawTerritory.toString();
    }

    return UserDto(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      employeeId: json['employeeCode']?.toString() ??
          json['employeeId']?.toString() ??
          '',
      displayName: json['displayName']?.toString() ??
          json['name']?.toString() ??
          json['fullName']?.toString() ??
          '',
      role: json['role']?.toString() ?? 'medical_rep',
      territory: resolvedTerritory,
      token: json['accessToken']?.toString() ??
          json['token']?.toString() ??
          '',
      refreshToken: json['refreshToken']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'employeeId': employeeId,
      'displayName': displayName,
      'role': role,
      'territory': territory,
      'token': token,
      if (refreshToken != null) 'refreshToken': refreshToken,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
    };
  }

  UserEntity toDomain() {
    return UserEntity(
      id: id,
      email: email,
      employeeId: employeeId,
      displayName: displayName,
      role: role,
      territory: territory,
      token: token,
      avatarUrl: avatarUrl,
      totalPoints: totalPoints,
      currentStreak: currentStreak,
    );
  }

  factory UserDto.fromDomain(UserEntity entity) {
    return UserDto(
      id: entity.id,
      email: entity.email,
      employeeId: entity.employeeId,
      displayName: entity.displayName,
      role: entity.role,
      territory: entity.territory,
      token: entity.token,
      avatarUrl: entity.avatarUrl,
      totalPoints: entity.totalPoints,
      currentStreak: entity.currentStreak,
    );
  }
}
