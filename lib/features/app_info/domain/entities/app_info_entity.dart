/// Domain Entity representing system application information and environment metadata.
///
/// Follows Clean Architecture Dependency Rule:
/// "Domain has zero Flutter/Dio/Hive imports."
class AppInfoEntity {
  final String appName;
  final String version;
  final String buildNumber;
  final String environment;
  final String apiEndpoint;
  final String minSupportedVersion;
  final bool maintenanceMode;
  final DateTime serverTimestamp;

  const AppInfoEntity({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.environment,
    required this.apiEndpoint,
    required this.minSupportedVersion,
    required this.maintenanceMode,
    required this.serverTimestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppInfoEntity &&
          runtimeType == other.runtimeType &&
          appName == other.appName &&
          version == other.version &&
          buildNumber == other.buildNumber &&
          environment == other.environment &&
          apiEndpoint == other.apiEndpoint &&
          minSupportedVersion == other.minSupportedVersion &&
          maintenanceMode == other.maintenanceMode &&
          serverTimestamp == other.serverTimestamp;

  @override
  int get hashCode =>
      appName.hashCode ^
      version.hashCode ^
      buildNumber.hashCode ^
      environment.hashCode ^
      apiEndpoint.hashCode ^
      minSupportedVersion.hashCode ^
      maintenanceMode.hashCode ^
      serverTimestamp.hashCode;

  @override
  String toString() {
    return 'AppInfoEntity(appName: $appName, version: $version+$buildNumber, env: $environment)';
  }
}
