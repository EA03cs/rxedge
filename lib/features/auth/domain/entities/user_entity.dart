/// Pure Dart User Domain Entity
///
/// Follows Clean Architecture Dependency Rule:
/// "Domain has zero Flutter/Dio/Hive imports."
class UserEntity {
  final String id;
  final String email;
  final String employeeId;
  final String displayName;
  final String role;
  final String territory;
  final String token;

  const UserEntity({
    required this.id,
    required this.email,
    required this.employeeId,
    required this.displayName,
    required this.role,
    required this.territory,
    required this.token,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          employeeId == other.employeeId &&
          displayName == other.displayName &&
          role == other.role &&
          territory == other.territory &&
          token == other.token;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      employeeId.hashCode ^
      displayName.hashCode ^
      role.hashCode ^
      territory.hashCode ^
      token.hashCode;

  @override
  String toString() => 'UserEntity(id: $id, name: $displayName, role: $role, territory: $territory)';
}
