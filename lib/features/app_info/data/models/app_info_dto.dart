import '../../domain/entities/app_info_entity.dart';

/// Data Transfer Object (DTO) for App Info
///
/// Follows Architecture Contract:
/// "DTOs separate from domain entities with explicit mappers."
class AppInfoDto {
  final String appName;
  final String version;
  final String buildNumber;
  final String environment;
  final String apiEndpoint;
  final String minSupportedVersion;
  final bool maintenanceMode;
  final DateTime serverTimestamp;

  const AppInfoDto({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.environment,
    required this.apiEndpoint,
    required this.minSupportedVersion,
    required this.maintenanceMode,
    required this.serverTimestamp,
  });

  factory AppInfoDto.fromJson(Map<String, dynamic> json) {
    return AppInfoDto(
      appName: json['app_name'] as String? ?? 'RxEdge',
      version: json['version'] as String? ?? '1.0.0',
      buildNumber: json['build_number'] as String? ?? '1',
      environment: json['environment'] as String? ?? 'production',
      apiEndpoint: json['api_endpoint'] as String? ?? '',
      minSupportedVersion: json['min_supported_version'] as String? ?? '1.0.0',
      maintenanceMode: json['maintenance_mode'] as bool? ?? false,
      serverTimestamp: json['server_timestamp'] != null
          ? DateTime.parse(json['server_timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_name': appName,
      'version': version,
      'build_number': buildNumber,
      'environment': environment,
      'api_endpoint': apiEndpoint,
      'min_supported_version': minSupportedVersion,
      'maintenance_mode': maintenanceMode,
      'server_timestamp': serverTimestamp.toIso8601String(),
    };
  }

  /// Maps DTO to Domain Entity
  AppInfoEntity toDomain() {
    return AppInfoEntity(
      appName: appName,
      version: version,
      buildNumber: buildNumber,
      environment: environment,
      apiEndpoint: apiEndpoint,
      minSupportedVersion: minSupportedVersion,
      maintenanceMode: maintenanceMode,
      serverTimestamp: serverTimestamp,
    );
  }

  /// Creates DTO from Domain Entity
  factory AppInfoDto.fromDomain(AppInfoEntity entity) {
    return AppInfoDto(
      appName: entity.appName,
      version: entity.version,
      buildNumber: entity.buildNumber,
      environment: entity.environment,
      apiEndpoint: entity.apiEndpoint,
      minSupportedVersion: entity.minSupportedVersion,
      maintenanceMode: entity.maintenanceMode,
      serverTimestamp: entity.serverTimestamp,
    );
  }
}
