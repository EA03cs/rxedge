import '../../domain/entities/app_info_entity.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/config/flavor_config.dart';

/// Data Transfer Object (DTO) for App Info & Backend Health (`/health`)
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
    final status = json['status']?.toString().toLowerCase();
    final defaultEnv = FlavorConfig.isInitialized
        ? FlavorConfig.instance.flavor.name
        : 'production';
    final rawTs = json['server_timestamp'] ?? json['timestamp'];

    return AppInfoDto(
      appName: json['app_name'] as String? ??
          json['appName'] as String? ??
          'RxEdge',
      version: json['version'] as String? ?? '1.0.0',
      buildNumber: json['build_number'] as String? ??
          json['buildNumber'] as String? ??
          '1',
      environment: json['environment'] as String? ??
          json['env'] as String? ??
          defaultEnv,
      apiEndpoint: json['api_endpoint'] as String? ??
          json['apiEndpoint'] as String? ??
          EnvConfig.baseUrl,
      minSupportedVersion: json['min_supported_version'] as String? ??
          json['minSupportedVersion'] as String? ??
          '1.0.0',
      maintenanceMode: json['maintenance_mode'] as bool? ??
          json['maintenanceMode'] as bool? ??
          (status == 'maintenance'),
      serverTimestamp: rawTs != null
          ? (DateTime.tryParse(rawTs.toString()) ?? DateTime.now())
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
