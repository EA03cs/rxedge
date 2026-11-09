import '../../domain/entities/user_entity.dart';

/// Data Transfer Object for User details
class UserDto {
  final String id;
  final String email;
  final String employeeId;
  final String displayName;
  final String role;
  final String territory;
  final String token;

  const UserDto({
    required this.id,
    required this.email,
    required this.employeeId,
    required this.displayName,
    required this.role,
    required this.territory,
    required this.token,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      employeeId: json['employee_id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      role: json['role'] as String? ?? 'Medical Representative',
      territory: json['territory'] as String? ?? 'North District',
      token: json['token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'employee_id': employeeId,
      'display_name': displayName,
      'role': role,
      'territory': territory,
      'token': token,
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
    );
  }
}
