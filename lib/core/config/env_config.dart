import 'flavor_config.dart';

/// Environment Configuration resolving URLs and flags based on Flavor
abstract final class EnvConfig {
  static String get baseUrl =>
      FlavorConfig.isInitialized ? FlavorConfig.instance.apiBaseUrl : 'https://api-dev.rxedge.internal/v1';
  static String get appName =>
      FlavorConfig.isInitialized ? FlavorConfig.instance.appName : 'RxEdge (Test)';
  static bool get enableLogging =>
      FlavorConfig.isInitialized ? FlavorConfig.instance.enableLogging : true;
  static Duration get connectTimeout =>
      FlavorConfig.isInitialized ? FlavorConfig.instance.connectTimeout : const Duration(seconds: 15);
  static Duration get receiveTimeout =>
      FlavorConfig.isInitialized ? FlavorConfig.instance.receiveTimeout : const Duration(seconds: 15);
}
